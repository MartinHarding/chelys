#!/usr/bin/env zsh

search() {
    local _query _engine _arg
    _engine='google'
    for _arg in $@; do
        if [ $_arg = '-e' ]; then
            _engine="$2"
            shift; shift
        fi
    done

    case $_engine in
        'google') _engine='https://www.google.com/search?q=';;
        'duckduckgo') _engine='https://duckduckgo.com/?q=';;
        'stackoverflow') _engine='https://stackoverflow.com/search?q=';;
    esac

    _query=`echo "$*" | sed -e 's/\ /+/g'`
    [[ $_query ]] || _query=$(basename `pwd`)

    case "`uname -s`" in
        "Darwin") open "$_engine$_query";;
        "Linux") xdg-open "$_engine$_query";;
        "CYGWIN"|"MINGW") start chrome "$_engine$_query";;
    esac
}

# Quick search aliases
alias ggl="search -e google"        # Google
alias ddg="search -e duckduckgo"    # DuckDuckGo
alias sov="search -e stackoverflow" # Stack Overflow
