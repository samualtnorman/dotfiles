command-exists() which $1 &> /dev/null

# fix neovim in tmux
[ "$TERM" = "tmux-256color" ] && export TERM=xterm-256color

! [ "$TERM_PROGRAM" = "vscode" ] && command-exists tmux && ! [ -n "$TMUX" ] && exec sh -c "tmux attach || tmux || sh"

[ -d /run/host/usr/share/zsh/plugins/ ] && for plugin in /run/host/usr/share/zsh/plugins/*; do
	source $plugin/`basename $plugin`.zsh
done

[ -d /usr/share/zsh/plugins/ ] && for plugin in /usr/share/zsh/plugins/*; do
	source $plugin/`basename $plugin`.zsh
done

setopt extendedglob

for plugin in /usr/share/zsh-*(#qN); do
	source $plugin/`basename $plugin`.zsh
done

command-exists direnv && eval "$(direnv hook zsh)"
VSCODE_SUGGEST=1
HISTFILE=~/.zsh-history
HISTSIZE=10000
SAVEHIST=10000
PROMPT="%F{cyan}%m%f%# "
RPROMPT="%F{blue}%~ %(?.%F{green}.%B%F{red})%?%f%b %F{yellow}%D{%H:%M}%f"
setopt beep extendedglob nomatch notify
bindkey -e
zstyle :compinstall filename ~/.zshrc
autoload -Uz compinit
compinit
precmd() echo

del-prompt-accept-line() {
    zle reset-prompt
    zle accept-line
}

zle -N del-prompt-accept-line
bindkey "^M" del-prompt-accept-line

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
(( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )) && {
	autoload -Uz add-zle-hook-widget
	zle_application_mode_start() echoti smkx
	zle_application_mode_stop() echoti rmkx
	add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
	add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
}

alias-for() {
	local search=${1}
	local found="$( alias $search )"

	if [[ -n $found ]]; then
		found=${found//\\//}
		found=${found%\'}
		found=${found#"$search="}
		found=${found#"'"}
		echo "${found} ${2}" | xargs
	else
		echo ""
	fi
}

extend-alias() if alias $1 &> /dev/null; then
    alias $1="`alias-for $1`; $2"
else
    alias $1=$2
fi

command-exists doas && ! command-exists sudo && alias sudo=doas
alias \#=sudo

if command-exists pacman; then
	alias pacman="pacman --color auto"
	alias search-package="pacman -Ss"
	alias add-package="# pacman -S --needed"
	extend-alias upgrade-package "# pacman -Syu"
	alias remove-package="# pacman -Rs"

	command_not_found_handler() {
		local purple='\e[1;35m'
		local bright='\e[0;1m'
		local green='\e[1;32m'
		local reset='\e[0m'
		printf 'zsh: command not found: %s\n' "$1"
		local entries=(${(f)"$(/usr/bin/pacman -F --machinereadable -- "/usr/bin/$1")"})

		(( ${#entries[@]} )) && {
			printf "${bright}$1${reset} may be found in the following packages:\n"
			local pkg

			for entry in "${entries[@]}"
			do
				local fields=(${(0)entry})

				[[ "$pkg" != "${fields[2]}" ]] &&
					printf "${purple}%s/${bright}%s ${green}%s${reset}\n" "${fields[1]}" "${fields[2]}" "${fields[3]}"

				printf '    /%s\n' "${fields[4]}"
				pkg="${fields[2]}"
			done
		}

		return 127
	}
elif command-exists dnf; then
	alias add-package="# dnf install"
elif command-exists apt; then
	alias search-package="apt search"
	alias add-package="# apt install"
	alias upgrade-package="# apt update && # apt upgrade"
	alias remove-package="# apt remove"
fi

export VISUAL=nvim
export EDITOR=nvim

extend-path() case :$PATH: in
	*:$1:*) ;;
	*) export PATH=$1:$PATH ;;
esac

extend-path /usr/local/sbin
extend-path /usr/local/bin
extend-path /bin
extend-path /sbin
extend-path /usr/sbin
extend-path /usr/bin

if [ -n "$IN_NIX_SHELL" ]; then
	PROMPT="nix $PROMPT"
else
	export PNPM_HOME=~/.local/share/pnpm
	extend-path $PNPM_HOME
	extend-path ~/.cargo/bin
fi

command-exists npm && extend-path `npm config get prefix`/bin
alias ls="ls --color --human-readable --classify --sort=extension"
alias lsh="ls --almost-all"
alias ll="ls -l"
alias llh="lsh -l"
alias df="df -h"
alias du="du -shc"
alias grep="grep --color"
command-exists batcat && alias bat=batcat
command-exists bat && alias cat=bat
command-exists konsole && alias konsole="run konsole"
command-exists kwrite && alias kwrite="run kwrite"
command-exists dolphin && alias dolphin="run dolphin"
alias \$="bash -c"
command-exists rua && extend-alias upgrade-package "rua upgrade"
command-exists nix-env && extend-alias upgrade-package "nix-env --upgrade"
command-exists cargo && extend-alias upgrade-package "cargo install-update -a"
command-exists bun && extend-alias upgrade-package "bun upgrade"
command-exists pnpm && extend-alias upgrade-package "pnpm update -g"
command-exists search-package && alias sp=search-package
command-exists add-package && alias ap=add-package
command-exists upgrade-package && alias up=upgrade-package
command-exists remove-package && alias rp=remove-package

cd() {
	builtin cd $@ && ls
}

rm() {
	echo "Did you mean \`trash\`? If you really mean \`rm\`, use \`command rm\`."
	return 1
}

command-exists docker && {
	alias arch="docker run -it --rm --name arch archlinux:latest"
	alias debian="docker run -it --rm --name arch debian:latest"
}

run() if command-exists $1; then
    command $@ &> /dev/null &|
else
    $1
fi

file-info() for FILE in $@; do
	file $FILE
	file --mime-type $FILE
	file --extension $FILE
	echo
done

old() {
    test -f $1.old && old $1.old
    mv $1 $1.old
}

see() {
	ll -d $1
	file $1

	if [[ -d $1 ]]; then
		ls $1
	else
		bat $1
	fi
}

path() {
	echo $PATH | tr : "\n"
}

command-exists remarshal && command-exists xxd && 2cbor() {
	{
		echo D9D9F7 | xxd -r -p
		remarshal $1 --of cbor
	} > $2
}

ls
