DOTFILES_DIR="${HOME}/.dotfiles"

. ${DOTFILES_DIR}/lib/utils

ZSH_THEME="powerlevel10k/powerlevel10k"
[[ -f ~/.zsh/p10k.conf ]] && . ~/.zsh/p10k.conf
[[ -f ~/.zsh/oh-my-zsh.conf ]] && . ~/.zsh/oh-my-zsh.conf

[[ -f ~/.shellrc ]] && . ~/.shellrc
# pnpm
export PNPM_HOME="/Users/albert.puigsech/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# bun completions
[ -s "/Users/albert.puigsech/.bun/_bun" ] && source "/Users/albert.puigsech/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
