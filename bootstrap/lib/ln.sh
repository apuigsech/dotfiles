function ln_file() {
    local org="$1"
    local dst="$2"

    # Check if the original file exists
    if [[ ! -f "$org" ]]; then
        echo "Error: Original file '${org}' does not exist."
        return 1
    fi

    ln -s "$org" "$dst"
}

function ln_dir() {
    local org="$1"
    local dst="$2"

    # Check if the original directory exists
    if [[ ! -d "$org" ]]; then
        echo "Error: Original directory '${org}' does not exist."
        return 1
    fi

    ln -s "$org" "$dst"
}

function ln_dir_files() {
    local org="$1"
    local dst="$2"

    # Check if the source directory exists
    if [[ ! -d "$org" ]]; then
        echo "Error: Source directory '${org}' does not exist."
        return 1
    fi

    # Check if the destination directory exists, if not create it
    if [[ ! -d "$dst" ]]; then
        mkdir -p "$dst"
    fi

    # Iterate over all files in the source directory and create symbolic links in the destination directory
    for file in "$org"/*; do
        if [[ -f "$file" ]]; then
            ln -s "$file" "$dst"/"$(basename "$file")"
        fi
    done
}


function create_symlinks_from_file() {
    local file="$1"

    # Check if the input file exists
    if [[ ! -f "$file" ]]; then
        echo "Error: File '${file}' does not exist."
        return 1
    fi

    # Read the file line by line
    while IFS=: read -r org dst || [[ -n "$org" ]]; do
        # Check if the original path is a file or directory and create the symlink accordingly
        if [[ -f "$org" ]]; then
            echo "f"
            ln_file "$org" "$dst"
        elif [[ -d "$org" ]]; then
            echo "z"
            ln_dir_files "$org" "$dst"
        else
            echo "d"
            ln_dir "$org" "$dst"
        fi
    done < "$file"
}
