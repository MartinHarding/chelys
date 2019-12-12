#!/usr/bin/env zsh

d() {
    case $1 in
        "stop")
            docker stop $(docker ps -a -q)
        ;;
        "remove")
            docker stop $(docker ps -a -q)
            docker rm $(docker ps -a -q)
        ;;
        "clean")
            docker stop $(docker ps -a -q)
            docker rm $(docker ps -a -q)
            docker system prune --all --volumes
        ;;
        *) docker $@;;
    esac
}

ds() {
    case $1 in
        "restart")
            docker-sync stop
            docker-sync clean
            docker-sync start
        ;;
        *) docker-sync $@;;
    esac
}
alias dss="docker-sync-stack"

dc() {
    case $1 in
        "restart")
            docker-compose restart
        ;;
        "services")
            docker-compose up -d database elasticsearch redis
        ;;
        *) docker-compose $@;;
    esac
}
