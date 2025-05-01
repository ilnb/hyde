
# p10k
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# use p10k theme

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
# Oh-my-zsh installation path
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME='powerlevel10k/powerlevel10k'

# Disable insecure directories
ZSH_DISABLE_COMPFIX=true

# List of plugins used
plugins=(
zsh-syntax-highlighting zsh-completions
zsh-autosuggestions
fzf-tab
zsh-fzf-history-search
	)
source $ZSH/oh-my-zsh.sh

autoload -Uz compinit && compinit

source ~/.p10k.zsh

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
   aurhelper={$aurhelper:-"yay"}
fi

function in {
    local -a inPkg=("$@")
    local -a arch=()
    local -a aur=()

    for pkg in "${inPkg[@]}"; do
        if pacman -Si "${pkg}" &>/dev/null; then
            arch+=("${pkg}")
        else
            aur+=("${pkg}")
        fi
    done

    if [[ ${#arch[@]} -gt 0 ]]; then
        sudo pacman -S "${arch[@]}"
    fi

    if [[ ${#aur[@]} -gt 0 ]]; then
        ${aurhelper} -S "${aur[@]}"
    fi
}

# Vim bindings
bindkey -v
bindkey '^H' fzf_history_search

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1a --icons=auto --color=always $realpath'

# Helpful aliases
alias c='clear' # clear terminal
alias l='eza -lh --icons=auto' # long list
alias la='eza -a --icons=auto' # grid all
alias ls='eza --icons=auto' # grid
alias ll='eza -lha --icons=auto --sort=name --group-directories-first' # long list all
alias ld='eza -lhD --icons=auto' # long list dirs
alias lt='eza --icons=auto --tree' # list folder as tree
alias un='$aurhelper -Rns' # uninstall package
alias up='$aurhelper -Syu' # update system/package/aur
alias pl='$aurhelper -Qs' # list installed package
alias pa='$aurhelper -Ss' # list available package
alias pc='yes | $aurhelper -Sc' # remove unused cache
alias po='$aurhelper -Qtdq | $aurhelper -Rns -' # remove unused packages, also try > $aurhelper -Qqd | $aurhelper -Rsu --print -
alias his='nvim ~/.zsh_history'
alias shell='nvim ~/.zshrc'
alias nvcfg='find ~/.config/nvim \( -path "*/.git/*" \) -prune -o -printf "%P\n" | fzf | xargs -rI {} nvim ~/.config/nvim/"{}"'
alias re='reboot'
alias off='shutdown now'
alias ff='fastfetch'
alias ffa='fastfetch --all'

# Directory navigation shortcuts
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'

# Always mkdir a path (this doesn't inhibit functionality to make a single dir)
alias mkdir='mkdir -p'

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Environment variable
export QT_IM_MODULE='fcitx'
export XMODIFIERS='@im=fcitx'
export ZSH_FZF_TMP_DIR='$HOME/.cache/zsh-fzf-tab'

# Display Pokemon
pokemon-colorscripts --no-title -r 1,3,6
