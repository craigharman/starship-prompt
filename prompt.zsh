# Tokyo Night powerline prompt — zsh setup
# Source this from your ~/.zshrc:   source /path/to/prompt.zsh
# Requires: starship + a Nerd Font (see README.md).

# starship (powerline10k replacement for fancy prompts)
eval "$(starship init zsh)"

# Blank line between the command line and its output (runs after you hit enter,
# before the command executes). Uses add-zsh-hook so starship's own hooks stay intact.
autoload -Uz add-zsh-hook
_prompt_blank_line() { print "" }
add-zsh-hook preexec _prompt_blank_line

# Transient prompt: once a command is submitted, collapse its (now-past) prompt
# to a minimal "❯ <cmd>" and clear that line's right-side modules. The active
# prompt always stays full. Mirrors powerlevel10k's transient_prompt.
# starship 1.25.1 has no built-in transience, so do it with a zle widget:
# wrap line-init, and on accept redraw the finished line with a minimal prompt.
_transient_zle_line_init() {
  emulate -L zsh
  [[ $CONTEXT == start ]] || return 0
  while true; do
    zle .recursive-edit
    local -i ret=$?
    [[ $ret == 0 && $KEYS == $'\4' ]] || break
    [[ -o ignore_eof ]] || exit 0
  done
  local saved_prompt=$PROMPT saved_rprompt=$RPROMPT
  PROMPT=$'%F{green}❯%f '   # collapsed prompt: green ❯
  RPROMPT=''                      # drop right-side modules on past lines
  zle .reset-prompt
  PROMPT=$saved_prompt RPROMPT=$saved_rprompt
  if (( ret )); then
    zle .send-break
  else
    zle .accept-line
  fi
  return ret
}
zle -N zle-line-init _transient_zle_line_init
