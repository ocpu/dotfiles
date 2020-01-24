USE_EDITOR="test ! -e ~/.selected_editor && select-editor; test -f ~/.selected_editor && . ~/.selected_editor && \$SELECTED_EDITOR"

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias edit-i3="$USE_EDITOR ~/.config/i3/config"
alias edit-alias="$USE_EDITOR ~/.bash_aliases"
alias edit-bash="$USE_EDITOR ~/.bashrc"
alias edit-ssh="$USE_EDITOR ~/.ssh/config"
alias edit-git="$USE_EDITOR ~/.gitconfig"
alias reload-bash="source ~/.bashrc"
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

