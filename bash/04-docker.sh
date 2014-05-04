#!/bin/bash 

alias doc-mr="docker-container-most-recent"
alias doc-dmr="docker-container-diff-most-recent"
alias doc-i="docker-container-ip"
alias doc-imr="docker-container-inspect-most-recent"
alias doc-ra="docker-container-remove-all"
alias doc-ranr="docker-container-remove-all-non-running"
alias doi-mr="docker-image-most-recent"
alias doi-ra="docker-image-remove-all"
alias doi-ro="docker-image-remove-orphan"
alias dor="docker-run"
alias dob="docker-build"

function docker-run() {
	local $img=$1 $path=$2
	docker run -i -t $img $path 
}

function docker-build() {
	local $img=$1 $path=$2
	docker build -t $img $path 
}

function docker-container-most-recent() {
    docker ps | grep -v ^CONTAINER | head -n1 | awk '{print $1}'
}

function docker-container-diff-most-recent() {
    LAST_CONTAINER=$(docker-container-most-recent)

    if [ ! -z "$LAST_CONTAINER" ]
    then
        docker diff $LAST_CONTAINER
    else
        echo "There are no running containers!"
    fi
}

function docker-container-ip() {
    CONTAINER_ID=$1
    if [ -z "$CONTAINER_ID" ]
    then
        CONTAINER_ID=$(docker-container-most-recent)
    fi
    if [ ! -z "$CONTAINER_ID" ]
    then
        docker inspect --format '{{ .NetworkSettings.IPAddress }}' $CONTAINER_ID
    else
        echo "There are no running containers!"
    fi
}

function docker-container-inspect-most-recent() {
    LAST_CONTAINER=$(docker-container-most-recent)
    if [ ! -z "$LAST_CONTAINER" ]
    then
        docker inspect $LAST_CONTAINER
    else
        echo "There are no running containers!"
    fi
}

function docker-container-remove-all() {
    docker ps -a | grep -v ^CONTAINER | awk '{print $1}' | xargs -rI % sh -c "docker kill %; docker rm %"
}

function docker-container-remove-all-non-running() {
    docker ps -a | grep -v ^CONTAINER | grep Exit | awk '{print $1}' | xargs -rI % sh -c "docker kill %; docker rm %"
}

function docker-image-most-recent() {
    docker images | grep -v ^REPOSITORY | head -n1 | awk '{print $3}'
}

function docker-image-remove-all() {
    docker-container-remove-all
    docker images -a | grep -v ^REPOSITORY | awk '{print $3}' | xargs -r docker rmi
}

function docker-image-remove-orphan() {
    docker images | grep "<none>" | awk '{print $3}' | xargs -r docker rmi
}

