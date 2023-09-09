source_dir() {
    local dir=$1
    local ext=$2

    # Check if the folder exists
    if [[ ! -d $dir ]]; then
        echo "Error: Directory '${dir}' does not exist."
        return 1
    fi

    # If an extension is provided, append it to the directory path
    local files=("$dir"/*)
    [[ -n $ext ]] && files=("$dir"/*."$ext")

    # Iterate over all files in the folder with the specified extension and source them
    for file in "${files[@]}"; do
        # Check if the pattern resulted in an actual file
        if [[ -f $file ]]; then
            echo $file
            source "$file"
        fi
    done
}


