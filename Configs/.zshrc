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

# fzf directories
fzf_cd() {
  local dir
  dir=$(
    fd -t d -H -E .git -E .cache . "$HOME" \
    | rg '^(\.config|\.local|[^.])|^\.\./' \
    | sed "s|^$HOME|~|; s|/$||" \
    | fzf
  ) || return
  dir="${dir/#\~/$HOME}"
  cd -- "$dir" || return
  zle accept-line
}
zle -N fzf_cd

# Keybindings
bindkey -v
bindkey '^H' fzf_history_search
bindkey '^F' fzf_cd
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
setopt NO_BEEP
# unsetopt hist_verify # uncoment for direct exec of expansions

# Completion styling
_comp_options+=(globdots)
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1a --icons=auto --color=always $realpath'
zstyle ':fzf-tab:complete:cpg:*' fzf-preview 'eza -1a --icons=auto --color=always $realpath'
zstyle ':fzf-tab:complete:mvg:*' fzf-preview 'eza -1a --icons=auto --color=always $realpath'
zstyle ':fzf-tab:complete:nvim:*' fzf-preview 'eza -1a --icons=auto --color=always $realpath'
zstyle ':fzf-tab:complete:rm:*' fzf-preview 'eza -1a --icons=auto --color=always $realpath'
zstyle ':fzf-tab:complete:z:*' fzf-preview 'eza -1a --icons=auto --color=always $realpath'

# General Aliases
alias c='clear'
alias ff='c && fastfetch'
alias ffn='c && fastfetch --config ~/.config/fastfetch/base_config.jsonc'
alias ffa='c && ff -c all'
alias com='nvim ~/code/arch\ commands'
# alias nvcfg='find ~/.config/nvim \( -path "*/.git/*" \) -prune -o -printf "%P\n" | fzf | xargs -rI {} nvim ~/.config/nvim/"{}"'
alias ng='~/.config/nvim'
alias hycfg='find ~/.config/hypr \( -path "*/.git/*" \) -prune -o -printf "%P\n" | fzf | xargs -rI {} nvim ~/.config/hypr/"{}"'
alias hg='~/.config/hypr'
alias cp='/usr/bin/cpg -g'
alias mv='/usr/bin/mvg -g'
alias open='open_command'
# alias cp='rsync -h --info=progress2'
alias shell='nvim ~/.zshrc'
alias his='nvim ~/.zsh_history'
alias anime='ani-cli'
alias fvim='fzf --preview "cat {}" | xargs -rI {} nvim "{}"'
alias fevim='fzf -e --preview "cat {}" | xargs -rI {} nvim "{}"'
alias pyenv='source ~/venv/bin/activate'
alias lvim='NVIM_APPNAME=lazyvim nvim'

# System related
alias off='shutdown now'
alias re='reboot'
alias charge='lenopow -d'
alias dont='lenopow -e'

# Listing files and directories
alias ls='eza --icons=auto' # grid
alias la='eza -a --icons=auto' # grid all
alias l='eza -lha --icons=auto' # long list
alias ll='l'
alias lt='eza --icons=auto --tree' # list folder as tree

# Power modes
psave() {
  for cpu in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
    echo power | sudo tee "$cpu" >/dev/null
  done

  echo 0 | sudo tee /sys/devices/system/cpu/cpufreq/boost
}

perf() {
  for cpu in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
    echo performance | sudo tee "$cpu" >/dev/null
  done

  echo 1 | sudo tee /sys/devices/system/cpu/cpufreq/boost
}

# Git Aliases
alias g='git'
alias ga='g add'
alias gaa='g add --all' # adds new and old files
alias gc='g clone'
alias gcm='g commit -m' # commit message
alias gcam='g commit -am' # commits old files
alias gaacm='g add -A && g commit -m' # commits new and old files
alias gp='g push'
alias gpm='g push -u origin master'
alias gst='g status'
alias gs='gst'
alias grs='g restore'
alias grst='g restore --staged'

# Packages
alias pl='$aurhelper -Qs' # list installed package
alias pa='$aurhelper -Ss' # list available package
alias pc='yes | $aurhelper -Sc' # remove unused cache
alias po='$aurhelper -Qtdq | xargs -ro $aurhelper -Rns' # remove unused packages, also try > $aurhelper -Qqd | $aurhelper -Rsu --print -
alias in='sudo pacman -Sy'
alias yin='yay -Sy'
alias un='sudo pacman -Rns'
alias up='in -u && yin -u'

# Always mkdir a path
alias mkdir='mkdir -p'

# Shell integrations
export PATH="$HOME/.cargo/bin:$PATH"
# export PATH="$HOME/.zig:$PATH"
# export PATH="$CUDA_PATH:$PATH"
# export INPUT_METHOD='fcitx'  # might not need all this
# export GTK_IM_MODULE='fcitx'
# export QT_IM_MODULE='fcitx'
# export XMODIFIERS='@im=fcitx'
export LANG='en_US.UTF-8'
export FZF_DEFAULT_COMMAND='fd -HI -t f -E .git'
export EDITOR='nvim'
eval "$(zoxide init --cmd cd zsh)"
