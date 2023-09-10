DOTFILES_DIR="${HOME}/.dotfiles"

. ${DOTFILES_DIR}/lib/utils

ZSH_THEME="powerlevel10k/powerlevel10k"
[[ -f ~/.zsh/p10k.conf ]] && . ~/.zsh/p10k.conf
[[ -f ~/.zsh/oh-my-zsh.conf ]] && . ~/.zsh/oh-my-zsh.conf

[[ -f ~/.shellrc ]] && . ~/.shellrc