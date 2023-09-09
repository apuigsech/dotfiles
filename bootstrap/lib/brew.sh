function brew_is_installed() {
    if command -v brew >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

function brew_install() {
    if brew_is_installed; then
        echo "Homebrew is already installed."
        return 0
    else
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                
        if [[ $? -eq 0 ]]; then
            echo "Homebrew installed successfully."
            return 0
        else
            echo "Failed to install Homebrew."
            return 1
        fi
    fi
}

function brew_install_packages() {
    local package_file=$1
    local type=$2

    if ! brew_is_installed; then
        echo "Homebrew is not installed. Please install it first."
        return 1
    fi

    if [[ ! -f $package_file ]]; then
        echo "File not found: $package_file"
        return 1
    fi

    if [[ $type == "cask" ]]; then
        xargs brew install < $package_file
    else
        xargs brew install --cask < $package_file
    fi
}