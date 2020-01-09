#!/bin/zsh

# A set of minimal utilities and scripts which hold up my world.
#
# Usage:
#     chelys <COMMAND>
#     chelys help <BIN | INCLUDE>
#     chelys (-h | --help)
#
# Commands:
#     doctor  Checks Chelys for potential problems.
#     help    Show help on a specific bin or include file.
#     fix     Attempts to fix problems found by the doctor command.
#     reload  Runs 'source ~/.chelys/chelys.sh' to reload all files without restarting your shell.
#     update  Does a git pull against the default remote repository for Chelys.
#
# Options:
#     -h --help  Show this screen.

set -o pipefail

CHELYS_PATH=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
CHELYS_SOURCED_COMMIT=$(cd $CHELYS_PATH; git rev-parse HEAD)

# TODO: make bin linking optional
export PATH="$CHELYS_PATH/bin:$PATH"

COLOR_CLEAR='\e[0m'
COLOR_WARN='\e[1;33mWARNING:'
COLOR_ERROR='\e[1;31mERROR:'

for include_file in $CHELYS_PATH/includes/*; do
    source $include_file
done

for env_file in $CHELYS_PATH/bin/*.env; do
    source $env_file
done

chelys() {
    local _cmd=$1
    [[ $_cmd ]] && shift

    case $_cmd in
        'doctor'|d) chelys_doctor;;
        'reload'|r) chelys_reload;;
        'update'|u) chelys_update;;
        'edit'|e) chelys_edit;;
        'fix'|f) chelys_fix;;
        'help'|'--help'|-h|h|'') chelys_help $@;;
        *) echo "$COLOR_ERROR $_cmd is not a valid command $COLOR_CLEAR" && return 1;;
    esac
}

chelys_help() {
    local _cmd=$1 _file_path _runner _help_text

    if [[ $_cmd ]]; then
        _file_path="$CHELYS_PATH/bin/$_cmd"
    else
        printf "\e[1;32m"
        cat "$CHELYS_PATH/turtle.txt"
        echo $COLOR_CLEAR
        _file_path="$CHELYS_PATH/chelys.sh"
    fi

    _runner=$(head -n1 $_file_path)

    if [[ "$_runner" == '#!'*sh ]] || [[ "$_runner" == '#!'*ruby ]]; then
        _help_text=$(sed '/^#\!.*/d' $_file_path | sed '/^$/d' | sed -n '/^[^#]*$/!p;//q' | sed 's/^# //g;s/^#//g')
        [[ $_help_text ]] && echo "$_help_text" || echo "$COLOR_WARN $_file_path appears to have no help text."
    else
        echo "$COLOR_ERROR $_file_path '$_runner' help headers are not supported."
    fi
}

chelys_reload() {
    echo "Reloading Chelys..."
    source $CHELYS_PATH/chelys.sh
}

chelys_doctor() {
    local _current_commit="$(cd $CHELYS_PATH; git rev-parse HEAD)" _help_text
    if [[ $CHELYS_SOURCED_COMMIT != $_current_commit ]]; then
        echo "$COLOR_WARN sourced commit is $CHELYS_SOURCED_COMMIT but current commit is $_current_commit $COLOR_CLEAR"
    fi

    if [[ $(git status | grep 'working tree clean') ]] || echo "$COLOR_WARN $CHELYS_PATH has uncomitted changes $COLOR_CLEAR"""

    for bin_file in $CHELYS_PATH/bin/*; do
        [[ $bin_file = *.env ]] && continue
        [[ -x "$bin_file" ]] || echo "$COLOR_ERROR $bin_file is not executable $COLOR_CLEAR"
        _help_text=$(chelys_help `basename $bin_file`)
        case $_help_text in
        *WARNING:*) echo $_help_text;;
        *ERROR:*) echo $_help_text;;
        *);;
        esac
    done
}

chelys_fix() {
    for bin_file in $CHELYS_PATH/bin/*; do
        [[ $bin_file = *.env ]] && continue
        [[ -x "$bin_file" ]] || echo "Making '$bin_file' executable $COLOR_CLEAR" && chmod +x $bin_file
    done
}

chelys_update() {
    ( cd $CHELYS_PATH; git pull )
}

chelys_edit() {
    if [[ -f $CHELYS_PATH/EDITOR ]]; then
        EDITOR=$(cat $CHELYS_PATH/EDITOR)
    else
        while true; do
cat <<EOF
No default editor set, please choose one:
1) VS Code: 'code -w'
2) Nano 'nano'
3) VIM 'vim'
4) Enter your own
EOF
            printf "Choice: "
            read -r CHOICE
            case $CHOICE in
                "1") EDITOR="code -w"; break;;
                "2") EDITOR="nano"; break;;
                "3") EDITOR="vim"; break;;
                "4") printf "Enter command: "; read -r EDITOR; break;;
                *) echo "$COLOR_ERROR invalid option '$CHOICE'$COLOR_CLEAR";;
            esac
        done
        echo "Do you want to make '$EDITOR' the default command for editing Chelys?"
        echo "You can always change this by modifying $CHELYS_PATH/EDITOR"
        while true; do
            printf "y/n: "
            read -r CONFIRM
            case $CONFIRM in
                "y") echo "$EDITOR" > $CHELYS_PATH/EDITOR; break;;
                "n") break;;
                *) echo "$COLOR_ERROR invalid option '$CONFIRM'$COLOR_CLEAR";;
            esac
        done
    fi
    eval $EDITOR $CHELYS_PATH
}
