#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [ "$(sudo -v)" = "0" ]; then
  echo "This install script reqires sudo privileges"
  exit 1
fi

execTask() {
  local title="$1"
  shift
  "$@" &> /dev/null &
  local pid=$!
  trap "kill $pid 2> /dev/null" EXIT
  local steps=("-" "\\" "|" "/")
  local step=0
  while kill -0 "$pid" 2> /dev/null; do
    echo -ne "\r${steps[$step]} $title"
    local step=$(($step + 1))
    local step=$(($step % ${#steps[@]}))
    sleep .15
  done
  trap - EXIT
  echo -ne "\r$title done\r\n"
}

# Usage: "<question>" "[(yYnN) as default]" "[indecisive msg]" 
confirm() {
  case "$2" in
    [Yy]*) read -p "$1 [Y/n] " yn;;
    [Nn]*) read -p "$1 [y/N] " yn;;
    *) read -p "$1 [y/n] " yn;;
  esac
  case $yn in
    [Yy]* ) return 0;;
    [Nn]* ) return 1;;
    * )
      case "$2" in
        [Yy]*) return 0;;
        [Nn]*) return 1;;
        *)
          echo "${2:-Please answer yes or no.}"
          confirm "$@"
        ;;
      esac
    ;;
  esac
}

isHardLink() {
  echo $(stat -c %h -- $1) $1
  if [ $(stat -c %h -- $1) -gt 1 ]; then
    return 0
  else
    return 1
  fi
}

# Usage: "<local file>" "<actual path / link path>"
installFile() {
  if [ -e "$1" ]; then
    if [ -e "$2" ]; then
      if isHardLink "$2"; then
        >&2 echo "$2: Skipped as it is already a link"
        return 1
      else
        if confirm "'$2' already exists. Overwrite?" "n"; then
          rm "$2"
          ln "$1" "$2"
          return 0
        else
        # >&2 echo "$2: Skipped as it is already a file"
          return 1
        fi
      fi
    else
      ln "$1" "$2"
      #echo "$2: Done"
      return 0
    fi
  else
    echo "ERROR: local file '$1' does not exist"
    echo "Executed in context: $(pwd)"
    return 1
  fi
}

installPackage() {
  local add=()
  if local VERB="$( which apt-get )" 2> /dev/null; then
    add += "install"
    add += "-y"
  elif local VERB="$( which yum )" 2> /dev/null; then
    add += "install"
    add += "-y"
  elif local VERB="$( which pacman )" 2> /dev/null; then
    add += "-S"
  else
    echo "I have no idea what I'm doing." >&2
    return 1
  fi
  $VERB "${add[@]}" "$@"
  return $?
}

addPPA() {
  if which apt-add-repository 2> /dev/null; then
    apt-add-repository -yu "$1"
    return $?
  fi
  return 0
}

if [ -e "$HOME/.bashrc" ]; then
  mainFile="$HOME/.bashrc";
else
  mainFile="$HOME/.profile";
fi

if [ -z "$(which vim)" ]; then
  if confirm "Install vim?" 'y'; then
    execTask "Installing vim" installPackage "vim";
  fi
fi
if [ -z "$(which vim)" ]; then
  if installFile "$DIR/vimrc" "$HOME/.vimrc"; then
    mkdir -p "$HOME/.vim/bundle"
    if [ ! -d "$HOME/.vim/bundle/Vundle.vim" ]; then
      cd "$HOME/.vim/bundle"
      execTask "Insalling Vundle" git clone https://github.com/VundleVim/Vundle.vim.git
      cd - > /dev/null
      echo "run ':PluginInstall' in vim to install plugins"
    fi
  fi
fi

installFile "$DIR/.bash_aliases" "$HOME/.bash_aliases"

grep ". $DIR/bash_config" "$mainFile" > /dev/null || cat >> "$mainFile" <<END

# Added by dotfiles install
if [ -f "$DIR/bash_config" ]; then
  . $DIR/bash_config
fi
END

if [ -z "$(which i3)" ]; then
  if confirm "Install i3?" 'y'; then
    addPPA "ppa:kgilmer/speed-ricer"
    execTask "Installing i3" installPackage "i3-gaps dmenu i3lock-fancy";
  fi
fi

if [ -z "$(which i3)" ]; then
  mkdir -p "$HOME/.config/i3"
  installFile "$DIR/i3/config" "$HOME/.config/i3/config"
  installFile "$DIR/i3/i3blocks" "$HOME/.config/i3/i3blocks"
  installFile "$DIR/i3/blocks" "$HOME/.config/i3/blocks"
  installFile "$DIR/i3/fix-input" "$HOME/.config/i3/fix-input"
fi

install-i3() {
  if [ ! `command -v i3` ]; then
    if confirm "i3 was not found on your system. Install?" "y"; then
      local I3PACKAGES=("i3")
      if [ ! `command -v git` ]; then I3PACKAGES += "git"; fi
      if [ ! `command -v i3lock` ]; then I3PACKAGES += "i3lock"; fi
      if [ ! `command -v i3lock-fancy` ]; then I3PACKAGES += "i3lock-fancy"; fi
      if [ ! `command -v dmenu` ]; then I3PACKAGES += "dmenu"; fi
      if [ ! `command -v rofi` ]; then I3PACKAGES += "rofi"; fi
      if [ ! `command -v i3status` ]; then I3PACKAGES += "i3status"; fi
      if [ ! `command -v i3blocks` ]; then I3PACKAGES += "i3blocks"; fi
      
      installPackage "${I3PACKAGES[@]}"

      
    else
      return 1
    fi
  fi
  mkdir -p "$HOME/.config/i3"
  installFile "$DIR/i3/config" "$HOME/.config/i3/config"
  installFile "$DIR/i3/i3blocks" "$HOME/.config/i3/i3blocks"
  installFile "$DIR/i3/blocks" "$HOME/.config/i3/blocks"
  installFile "$DIR/i3/fix-input" "$HOME/.config/i3/fix-input"
}
