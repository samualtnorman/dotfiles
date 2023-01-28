# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt autocd beep extendedglob nomatch notify
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename ~/.zshrc

autoload -Uz compinit
compinit
# End of lines added by compinstall

if [ -d /run/host/usr/share/zsh/plugins/ ]; then
	for PLUGIN in /run/host/usr/share/zsh/plugins/*; do
		source $PLUGIN/`basename $PLUGIN`.zsh
	done
fi

if [ -d /usr/share/zsh/plugins/ ]; then
	for PLUGIN in /usr/share/zsh/plugins/*; do
		source $PLUGIN/`basename $PLUGIN`.zsh
	done
fi

alias pacman="pacman --color auto"
alias ls="ls --color --human-readable --classify --sort=extension"
alias lsh="ls --almost-all"

# pnpm
export PNPM_HOME=~/.local/share/pnpm
export PATH=$PNPM_HOME:$PATH
# pnpm end

run() {
	if which $1 &> /dev/null; then
        command $@ &> /dev/null &!
	else
		$1
	fi
}

alias kwrite="run kwrite"

PROMPT="%F{cyan}%m%f%# "
RPROMPT="%F{blue}%~ %(?.%F{green}.%B%F{red})%?%f%b %F{yellow}%D{%H:%M:%S}%f"

TMOUT=1

TRAPALRM() {
    zle reset-prompt
}

cd() {
	builtin cd $@ && ls
}

alias ll="ls -l"
alias llh="lsh -l"
alias cat=bat

# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
typeset -g -A key

key[Home]="${terminfo[khome]}"
key[End]="${terminfo[kend]}"
key[Insert]="${terminfo[kich1]}"
key[Backspace]="${terminfo[kbs]}"
key[Delete]="${terminfo[kdch1]}"
key[Up]="${terminfo[kcuu1]}"
key[Down]="${terminfo[kcud1]}"
key[Left]="${terminfo[kcub1]}"
key[Right]="${terminfo[kcuf1]}"
key[PageUp]="${terminfo[kpp]}"
key[PageDown]="${terminfo[knp]}"
key[Shift-Tab]="${terminfo[kcbt]}"

# setup key accordingly
[[ -n "${key[Home]}"      ]] && bindkey -- "${key[Home]}"       beginning-of-line
[[ -n "${key[End]}"       ]] && bindkey -- "${key[End]}"        end-of-line
[[ -n "${key[Insert]}"    ]] && bindkey -- "${key[Insert]}"     overwrite-mode
[[ -n "${key[Backspace]}" ]] && bindkey -- "${key[Backspace]}"  backward-delete-char
[[ -n "${key[Delete]}"    ]] && bindkey -- "${key[Delete]}"     delete-char
[[ -n "${key[Up]}"        ]] && bindkey -- "${key[Up]}"         up-line-or-history
[[ -n "${key[Down]}"      ]] && bindkey -- "${key[Down]}"       down-line-or-history
[[ -n "${key[Left]}"      ]] && bindkey -- "${key[Left]}"       backward-char
[[ -n "${key[Right]}"     ]] && bindkey -- "${key[Right]}"      forward-char
[[ -n "${key[PageUp]}"    ]] && bindkey -- "${key[PageUp]}"     beginning-of-buffer-or-history
[[ -n "${key[PageDown]}"  ]] && bindkey -- "${key[PageDown]}"   end-of-buffer-or-history
[[ -n "${key[Shift-Tab]}" ]] && bindkey -- "${key[Shift-Tab]}"  reverse-menu-complete

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
	autoload -Uz add-zle-hook-widget
	function zle_application_mode_start { echoti smkx }
	function zle_application_mode_stop { echoti rmkx }
	add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
	add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi

alias \$="bash -c"
alias \#=sudo
alias search-package="pacman -Ss"
alias sp=search-package
alias add-package="# pacman -S --needed"
alias ap=add-package
alias arch="distrobox enter arch"
alias debian="distrobox enter debian"
alias dolphin="run dolphin"
alias upgrade-package="# pacman -Syu"
alias up=upgrade-package
alias remove-package="# pacman -Rs"
alias rp=remove-package

rm() {
	echo "Did you mean \`trash\`? If you really mean \`rm\`, use \`\\\rm\`."
}

if which pacman &> /dev/null; then
    function command_not_found_handler {
        local purple='\e[1;35m' bright='\e[0;1m' green='\e[1;32m' reset='\e[0m'
        printf 'zsh: command not found: %s\n' "$1"
        local entries=(
            ${(f)"$(/usr/bin/pacman -F --machinereadable -- "/usr/bin/$1")"}
        )
        if (( ${#entries[@]} ))
        then
            printf "${bright}$1${reset} may be found in the following packages:\n"
            local pkg
            for entry in "${entries[@]}"
            do
                # (repo package version file)
                local fields=(
                    ${(0)entry}
                )
                if [[ "$pkg" != "${fields[2]}" ]]
                then
                    printf "${purple}%s/${bright}%s ${green}%s${reset}\n" "${fields[1]}" "${fields[2]}" "${fields[3]}"
                fi
                printf '    /%s\n' "${fields[4]}"
                pkg="${fields[2]}"
            done
        fi
        return 127
    }
fi

precmd() {
    precmd() {
        echo
    }
}

VISUAL=nvim
EDITOR=nvim

# if which neofetch &> /dev/null; then
# 	neofetch
# fi

ls
echo
