case $- in
    *i*) ;;
      *) return;;
esac

color_prompt=yes
PATH=$PATH:~nchambers/mini-bin
cc=
cxx=
HISTCONTROL="erasedups:ignoreboth"
HISTSIZE=1000
HISTFILESIZE=2000

[[ -t 2 ]] && {
#    alt=$(tput smcup || tput ti)
#    ealt=$(     tput rmcup  || tput te      ) # End   alt display
    hide=$(     tput civis  || tput vi      ) # Hide cursor
    show=$(     tput cnorm  || tput ve      ) # Show cursor
    save=$(     tput sc                     ) # Save cursor
    load=$(     tput rc                     ) # Load cursor
    bold=$(     tput bold   || tput md      ) # Start bold
    stout=$(    tput smso   || tput so      ) # Start stand-out
    estout=$(   tput rmso   || tput se      ) # End stand-out
    under=$(    tput smul   || tput us      ) # Start underline
    eunder=$(   tput rmul   || tput ue      ) # End   underline
    reset=$(    tput sgr0   || tput me      ) # Reset cursor
    blink=$(    tput blink  || tput mb      ) # Start blinking
    italic=$(   tput sitm   || tput ZH      ) # Start italic
    eitalic=$(  tput ritm   || tput ZR      ) # End   italic
[[ $TERM != *-m ]] && { 
    red=$(      tput setaf 1|| tput AF 1    )
    green=$(    tput setaf 2|| tput AF 2    )
    yellow=$(   tput setaf 3|| tput AF 3    )
    blue=$(     tput setaf 4|| tput AF 4    )
    magenta=$(  tput setaf 5|| tput AF 5    )
    cyan=$(     tput setaf 6|| tput AF 6    )
}
    white=$(    tput setaf 7|| tput AF 7    )
    default=$(  tput op                     )                                                                                                                                                                   
    eed=$(      tput ed     || tput cd      )   # Erase to end of display
    eel=$(      tput el     || tput ce      )   # Erase to end of line
    ebl=$(      tput el1    || tput cb      )   # Erase to beginning of line
    ewl=$eel$ebl                                # Erase whole line
    draw=$(     tput -S <<< '   enacs
                                smacs
                                acsc
                                rmacs' || { \
                tput eA; tput as;
                tput ac; tput ae;         } )   # Drawing characters
    back=$'\b'
} 2>/dev/null ||:

shopt -s histappend
shopt -s checkwinsize
shopt -s globstar
shopt -s cmdhist

[[ -x /usr/bin/lesspipe ]] && eval "$(SHELL=/bin/sh lesspipe)"
[[ -f ~/.git-prompt.sh ]] && . ~/.git-prompt.sh
[[ -f ~/.bash_aliases ]] && . ~/.bash_aliases

if [[ -z "${debian_chroot:-}" ]] && [[ -r /etc/debian_chroot ]]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

if [[ -n "$force_color_prompt" ]]; then
    if [[ -x /usr/bin/tput ]] && tput setaf 1 >&/dev/null; then
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [[ "$color_prompt" = yes ]]; then
    PS1='\[$bold$green\]\u@\h:\[$reset\]\[$bold$blue\]\w\[$reset\]\[$bold$red\]$(if [[ ! -z $(__git_ps1 "(%s)") ]]; then __git_ps1 " [%s]"; fi)\[$reset\]\$ '
else
    PS1='\u@\h:\w$(if [[ ! -z $(__git_ps1 "(%s)") ]]; then __git_ps1 " [%s]"; fi)\$ '
fi

unset color_prompt force_color_prompt

if [[ -x /usr/bin/dircolors ]]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

if ! shopt -oq posix; then
  if [[ -f /usr/share/bash-completion/bash_completion ]]; then
    . /usr/share/bash-completion/bash_completion
  elif [[ -f /etc/bash_completion ]]; then
    . /etc/bash_completion
  fi
fi

case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\$(print_title)\a\]$PS1"
    __el_LAST_EXECUTED_COMMAND=""

    print_title() {
        __el_FIRSTPART=""
        __el_SECONDPART=""

        if [[ "$PWD" == "$HOME" ]]; then
            __el_FIRSTPART=$(gettext --domain="pantheon-files" "Home")
        else
            if [[ "$PWD" == "/" ]]; then
                __el_FIRSTPART="/"
            else
                __el_FIRSTPART="${PWD##*/}"
            fi
        fi

        if [[ "$__el_LAST_EXECUTED_COMMAND" == "" ]]; then
            echo "$__el_FIRSTPART"
            return
        fi

        if [[ "$__el_LAST_EXECUTED_COMMAND" == sudo* ]]; then
            __el_SECONDPART="${__el_LAST_EXECUTED_COMMAND:5}"
            __el_SECONDPART="${__el_SECONDPART%% *}"
        else
            __el_SECONDPART="${__el_LAST_EXECUTED_COMMAND%% *}"
        fi

        printf "%s: %s" "$__el_FIRSTPART" "$__el_SECONDPART"
    }

    put_title() {
        __el_LAST_EXECUTED_COMMAND="${BASH_COMMAND}"
        printf "\033]0;%s\007" "$1"
    }

    update_tab_command() {
        case "$BASH_COMMAND" in
            *\033]0*|update_*|echo*|printf*|clear*|cd*)
            __el_LAST_EXECUTED_COMMAND=""
                ;;
            *)
            put_title "${BASH_COMMAND}"
            ;;
        esac
    }
    preexec_functions+=(update_tab_command)
    ;;
*)
    ;;
esac

bind tab:menu-complete

extract() {
     if [[ -f $1 ]] ; then
         case $1 in
             *.tar.bz2)   tar xjf $1        ;;
             *.tar.gz)    tar xzf $1     ;;
             *.bz2)       bunzip2 $1       ;;
             *.rar)       rar x $1     ;;
             *.gz)        gunzip $1     ;;
             *.tar)       tar xf $1        ;;
             *.tbz2)      tar xjf $1      ;;
             *.tgz)       tar xzf $1       ;;
             *.zip)       unzip $1     ;;
             *.Z)         uncompress $1  ;;
             *.7z)        7z x $1    ;;
             *)           echo "'$1' cannot be extracted via extract()" ;;
         esac
     else
         echo "'$1' is not a valid file"
     fi
}

sprunge() {
    OPTIND=1
    lang=
    lineno=

    while getopts "l:n:" opt; do
        case "$opt" in
        l) lang="?$OPTARG";
           ;;
        n) lineo="#n-$OPTARG";
           ;;
        esac
    done

    shift "$((OPTIND-1))"
    echo $(tail -n +1 -- "$@" | curl -F 'sprunge=<-' http://sprunge.us 2> /dev/null)"$lang$lineno";
}


ix() {
    local opts
    local OPTIND
    [ -f "$HOME/.netrc" ] && opts='-n'
    while getopts ":hd:i:n:" x; do
        case $x in
            h) echo "ix [-d ID] [-i ID] [-n N] [opts]"; return;;
            d) $echo curl $opts -X DELETE ix.io/$OPTARG; return;;
            i) opts="$opts -X PUT"; local id="$OPTARG";;
            n) opts="$opts -F read:1=$OPTARG";;
        esac
    done
    shift $(($OPTIND - 1))
    [ -t 0 ] && {
        local filename="$1"
        shift
        [ "$filename" ] && {
            curl $opts -F f:1=@"$filename" $* ix.io/$id
            return
        }
        echo "^C to cancel, ^D to send."
    }
    curl $opts -F f:1='<-' $* ix.io/$id
}

function myip {
    ip=`curl http://checkip.dyndns.org:8245/ 2> /dev/null | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'`
    echo "${ip}"
}

§() { curl -s http://cs.au.dk/~sortie/ssss/ssss.txt | ([ $# = 1 ] && sed -n "/^§$1\\./,/^§/{x;p}" || cat) } 
ssss() { §; }
mkcdr() { mkdir $1 && cd $1; }
topcmd() { history | awk 'BEGIN {FS="[ \t]+|\\|"} {print $3}' | sort | uniq -c | sort -nr | head; }
lnhelp() { echo 'ln -s existing_file new_file'; }

export NVM_DIR="/home/nchambers/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh"  # This loads nvm
HISTCONTROL="erasedups:ignoreboth"

if [[ -x /usr/games/fortune && -x /usr/games/cowsay ]]; then
    if [[ -x /usr/games/lolcat ]]; then
        fortune | cowsay | lolcat
    else
        fortune | cowsay
    fi
fi

echo $blue$bold"uptime: "$reset$green$(uptime | grep -o "up [^,]*") $reset
echo $blue$bold"Number of the day: "$reset$green$RANDOM$reset
echo ""
