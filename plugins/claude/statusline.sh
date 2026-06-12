#!/usr/bin/env bash
# Claude Code status line.
# Receives a JSON payload on stdin (see `statusLine` in settings.json) and
# prints a single line: bedrock profile · model · effort · dir · git branch.

input=$(cat)

model=$(printf '%s' "$input" | jq -r '.model.display_name // empty')
cwd=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // empty')

# Active profile. The `claude --profile` wrapper exports CLAUDE_PROFILE, which
# is authoritative. Fall back to inferring from env for sessions started some
# other way; show nothing when no profile can be determined.
profile="${CLAUDE_PROFILE:-}"
if [[ -z "$profile" ]]; then
  if [[ "${CLAUDE_CODE_USE_BEDROCK:-}" == "0" ]]; then
    profile="ollama"
  else
    case "${ANTHROPIC_MODEL:-}" in
      *490863270076*) profile="default" ;;
      *416153530160*) profile="shadow" ;;
      *) [[ "${CLAUDE_CODE_USE_BEDROCK:-}" == "1" ]] && profile="bedrock" ;;
    esac
  fi
fi

effort="${CLAUDE_EFFORT:-}"

dir=$(basename "${cwd:-$PWD}")

branch=""
if git -C "${cwd:-$PWD}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "${cwd:-$PWD}" branch --show-current 2>/dev/null)
fi

# ANSI dim/colored segments joined by a middle dot.
sep=" \033[2m·\033[0m "
out=""
[[ -n "$profile" ]] && out+="\033[35m${profile}\033[0m"
[[ -n "$model"   ]] && out+="${out:+$sep}\033[36m${model}\033[0m"
[[ -n "$effort"  ]] && out+="${out:+$sep}\033[33m${effort}\033[0m"
[[ -n "$dir"     ]] && out+="${out:+$sep}\033[2m${dir}\033[0m"
[[ -n "$branch"  ]] && out+="${out:+$sep}\033[32m⎇ ${branch}\033[0m"

printf "%b" "$out"
