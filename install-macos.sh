havebrew=$(which brew)
if [ ! -x $havebrew ] ; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

xargs brew install < brew/packages.lst
xargs brew install --cask < brew/packages-cask.lst

cp -rT bin ~/bin
chmod +x ~/bin/*

cp -rT zsh ~/.zsh
mv ~/.zshrc ~/.zshrc.old
ln -s ~/.zsh/zshrc ~/.zshrc

cp -rT hammerspoon ~/.hammerspoon

cp -rT envrc ~/.envrc

cp config/iterm2/com.googlecode.iterm2.plist ~/Library/Preferences/com.googlecode.iterm2.plist
mkdir -p ~/.bluereset/
cp config/bluereset/bluereset.conf ~/.bluereset/bluereset.conf