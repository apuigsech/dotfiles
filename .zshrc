DOTFILES_DIR="${HOME}/.dotfiles"

BASE_DIR=$DOTFILES_DIR
LIB_DIR="${BASE_DIR}/lib"

for file in ${LIB_DIR}/*.sh; do
    if [ -f $file ]; then
        source $file
    fi
done

ZSH_THEME="powerlevel10k/powerlevel10k"
source_dir "${BASE_DIR}/zsh" zsh

source_dir "${BASE_DIR}/aliases"
source_dir "${BASE_DIR}/env"

return

[[ ! -f ~/.zsh/basics.zsh ]] || source ~/.zsh/basics.zsh


# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )
[[ ! -f ~/.zsh/p10k.zsh ]] || source ~/.zsh/p10k.zsh


[[ ! -f ~/.zsh/oh-my-zsh.zsh ]] || source ~/.zsh/oh-my-zsh.zsh


[ -f ~/.fzf.zsh ] && source ~/.zsh/fzf.zsh



[[ ! -f ~/.zsh/aliases.zsh ]] || source ~/.zsh/aliases.zsh

# Hook direnv into ZSH
eval "$(direnv hook zsh)"

# Using tab size 4 spaces by default (instead of 8)
tabs -4

# Setup Brew
havebrew=$(which brew)
if [ -x $havebrew ] ; then
  eval "$(${havebrew} shellenv)"
  if [ -d $(${havebrew} --prefix)/opt/coreutils/libexec/gnubin ] ; then
    PATH="$(${havebrew} --prefix)/opt/coreutils/libexec/gnubin:$PATH"
  fi
fi

# GPG PIN Entry in CLI using NCURSES
export GPG_TTY=$(tty)
export PINENTRY_USER_DATA="USE_CURSES=0"


PATH=${HOME}/bin:${PATH}