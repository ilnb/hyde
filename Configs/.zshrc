export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  zsh-syntax-highlighting
  zsh-completions
  zsh-autosuggestions
  fzf-tab
  zsh-fzf-history-search
  sudo
  command-not-found
)
source $ZSH/oh-my-zsh.sh
autoload -Uz compinit && compinit

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# In case a command is not found, try to find the package that has it
function command_not_found_handler {
  local purple='\e[1;35m' bright='\e[0;1m' green='\e[1;32m' reset='\e[0m'
  printf 'zsh: command not found: %s\n' "$1"
  local entries=( ${(f)"$(/usr/bin/pacman -F --machinereadable -- "/usr/bin/$1")"} )
  if (( ${#entries[@]} )) ; then
    printf "${bright}$1${reset} may be found in the following packages:\n"
    local pkg
    for entry in "${entries[@]}" ; do
      local fields=( ${(0)entry} )
      if [[ "$pkg" != "${fields[2]}" ]]; then
        printf "${purple}%s/${bright}%s ${green}%s${reset}\n" "${fields[1]}" "${fields[2]}" "${fields[3]}"
      fi
      printf '    /%s\n' "${fields[4]}"
      pkg="${fields[2]}"
    done
  fi
  return 127
}

# Detect AUR wrapper
if pacman -Qi yay &>/dev/null; then
  aurhelper="yay"
elif pacman -Qi paru &>/dev/null; then
  aurhelper="paru"
fi

# Keybindings
bindkey -v
bindkey '^H' fzf_history_search
# bindkey '^p' history-search-backward
# bindkey '^n' history-search-forward

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1a --icons=auto --color=always $realpath'

# General Aliases
alias hy='hyprland'
alias c='clear'
alias ff='c && fastfetch'
alias ffn='c && fastfetch --load-config ~/.config/fastfetch/base_config.jsonc'
alias ffa='c && ff -c all'
alias com='nvim ~/code/arch\ commands'
#alias nvcfg='find ~/.config/nvim \( -path "*/.git/*" \) -prune -o -printf "%P\n" | fzf | xargs -rI {} nvim ~/.config/nvim/"{}"'
alias ng='~/.config/nvim'
alias hycfg='find ~/.config/hypr \( -path "*/.git/*" \) -prune -o -printf "%P\n" | fzf | xargs -rI {} nvim ~/.config/hypr/"{}"'
alias hg='~/.config/hypr'
alias cpr='rsync -h --info=progress2'
alias shell='nvim ~/.zshrc'
alias his='nvim ~/.zsh_history'
alias anime='ani-cli'
alias lutris='/opt/lutris.sh'
alias nvfz='fzf | xargs -r nvim'
alias nvfze='fzf -e | xargs -r nvim'
alias pyenv='source ~/venv/bin/activate'

# System related
alias off='shutdown now'
alias re='reboot'
alias charge='lenopow -d'
alias dont='lenopow -e'

# Listing files and directories
alias ls='eza --icons=auto' # grid
alias la='eza -a --icons=auto' # grid all
alias l='eza -lh --icons=auto' # long list
alias ll='eza -lha --icons=auto --sort=name --group-directories-first' # long list all
alias ld='eza -lhaD --icons=auto' # long list dirs
alias lt='eza --icons=auto --tree' # list folder as tree

# Power modes
psave() {
  for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
    echo powersave | sudo tee "$cpu/cpufreq/scaling_governor"
  done
}

perf() {
  for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
    echo performance | sudo tee "$cpu/cpufreq/scaling_governor"
  done
}

# Git Aliases
alias g='git'
alias ga='git add'
alias gaa='git add --all' # adds new and old files
alias gcm='git commit -m' # commit message
alias gcam='git commit -am' # commits old files
alias gaacm='git add -A && git commit -m' # commits new and old files
alias gp='git push'
alias gpm='git push --set-upstream origin main'
alias gst='git status'
alias grs='git restore'
alias grst='git restore --staged'

# Packages
alias pl='$aurhelper -Qs' # list installed package
alias pa='$aurhelper -Ss' # list available package
alias pc='yes | $aurhelper -Sc' # remove unused cache
alias po='$aurhelper -Qtdq | $aurhelper -Rns -' # remove unused packages, also try > $aurhelper -Qqd | $aurhelper -Rsu --print -
alias in='sudo pacman -Sy'
alias yin='yay -Sy'
alias un='sudo pacman -Rns'
alias up='in -u && yin -u'

# Directory navigation shortcuts
alias yz='yazi'
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'

# Always mkdir a path (this doesn't inhibit functionality to make a single dir)
alias mkdir='mkdir -p'

# Shell integrations
export QT_IM_MODULE='fcitx'
export XMODIFIERS='@im=fcitx'
export LANG='en_US.UTF-8'
