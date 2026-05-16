#!/usr/bin/env python3
"""Validate VSCode settings.json against extension schemas and core bundle enums."""

import json
import re
import sys
from pathlib import Path

SETTINGS_FILE = Path.home() / "Library/Application Support/Code/User/settings.json"
EXTENSIONS_DIRS = [
    Path.home() / ".vscode/extensions",
    Path("/Applications/Visual Studio Code.app/Contents/Resources/app/extensions"),
]
BUNDLE = Path(
    "/Applications/Visual Studio Code.app/Contents/Resources/app"
    "/out/vs/workbench/workbench.desktop.main.js"
)


def load_extension_schemas():
    schemas = {}
    for ext_dir in EXTENSIONS_DIRS:
        if not ext_dir.exists():
            continue
        for pkg in ext_dir.glob("*/package.json"):
            try:
                data = json.loads(pkg.read_text())
                config = data.get("contributes", {}).get("configuration", {})
                configs = config if isinstance(config, list) else [config]
                for c in configs:
                    for key, schema in c.get("properties", {}).items():
                        schemas[key] = schema
            except Exception:
                pass
    return schemas


def load_bundle_schemas():
    """Extract enum schemas from the minified VSCode workbench bundle.

    The bundle encodes settings as:
        "setting.name":{type:"string",<...>,enum:["v1","v2"],<...>}
    """
    if not BUNDLE.exists():
        return {}

    bundle = BUNDLE.read_text(encoding="utf-8", errors="ignore")
    p = (
        r'"([\w.]+)":\{type:"(\w+)",'
        r'(?:[^{}]|\{[^{}]*\}){0,400}?'
        r'enum:\[("(?:[^"\\]|\\.)*"(?:,"(?:[^"\\]|\\.)*")*)\]'
    )
    schemas = {}
    for m in re.finditer(p, bundle):
        name, typ, enum_content = m.group(1), m.group(2), m.group(3)
        if "." not in name:
            continue
        try:
            enum_vals = json.loads(f"[{enum_content}]")
            if isinstance(enum_vals, list) and 1 < len(enum_vals) <= 30:
                schemas[name] = {"type": typ, "enum": enum_vals}
        except Exception:
            pass
    return schemas


def validate_value(key, value, schema):
    errors = []
    s_type = schema.get("type")
    enum = schema.get("enum")
    deprecation = schema.get("deprecationMessage")

    if deprecation:
        errors.append(("DEPRECATED", deprecation))
        return errors

    if enum is not None and value not in enum:
        errors.append(("ERROR", f"Invalid value {value!r}. Allowed: {enum}"))
        return errors

    if s_type == "string" and not isinstance(value, str):
        errors.append(("ERROR", f"Expected string, got {type(value).__name__}"))
    elif s_type == "boolean" and not isinstance(value, bool):
        errors.append(("ERROR", f"Expected boolean, got {type(value).__name__}"))
    elif s_type == "number" and not isinstance(value, (int, float)):
        errors.append(("ERROR", f"Expected number, got {type(value).__name__}"))
    elif s_type == "integer" and not isinstance(value, int):
        errors.append(("ERROR", f"Expected integer, got {type(value).__name__}"))
    elif s_type == "array" and not isinstance(value, list):
        errors.append(("ERROR", f"Expected array, got {type(value).__name__}"))
    elif s_type == "object" and not isinstance(value, dict):
        errors.append(("ERROR", f"Expected object, got {type(value).__name__}"))

    if s_type in ("number", "integer") and isinstance(value, (int, float)):
        if "minimum" in schema and value < schema["minimum"]:
            errors.append(("ERROR", f"Value {value} below minimum {schema['minimum']}"))
        if "maximum" in schema and value > schema["maximum"]:
            errors.append(("ERROR", f"Value {value} above maximum {schema['maximum']}"))

    return errors


def main():
    settings_path = SETTINGS_FILE.resolve()
    try:
        settings = json.loads(settings_path.read_text())
    except json.JSONDecodeError as e:
        print(f"ERROR: settings.json is not valid JSON: {e}")
        sys.exit(1)

    # Extension schemas are authoritative; bundle fills in core settings
    bundle_schemas = load_bundle_schemas()
    ext_schemas = load_extension_schemas()
    all_schemas = {**bundle_schemas, **ext_schemas}

    errors = []
    deprecations = []
    unknown = []

    for key, value in settings.items():
        if key.startswith("["):
            continue
        if key not in all_schemas:
            unknown.append(key)
            continue
        for tag, msg in validate_value(key, value, all_schemas[key]):
            if tag == "DEPRECATED":
                deprecations.append((key, msg))
            else:
                errors.append((key, value, msg))

    if errors:
        print("=== ERRORS ===")
        for key, value, msg in errors:
            print(f"  {key}: {msg}")

    if deprecations:
        print("\n=== DEPRECATED ===")
        for key, msg in deprecations:
            print(f"  {key}: {msg}")

    if unknown:
        print(f"\n=== UNKNOWN ({len(unknown)} — VSCode core or uninstalled extension) ===")
        for k in unknown:
            print(f"  {k}")

    if not errors and not deprecations:
        print(f"OK: no errors or deprecations found ({len(all_schemas)} schemas loaded, "
              f"{sum(1 for k in settings if not k.startswith('[') and k in all_schemas)} settings validated)")


if __name__ == "__main__":
    main()
