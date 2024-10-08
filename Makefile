.PHONY: help

APP_NAME = twitterclone
APP_VSN ?= $(shell grep 'version:' mix.exs | cut -d '"' -f2)
BUILD ?= $(shell git rev-parse --short HEAD)

help:
    @echo "$APP_NAME:$APP_VSN-$BUILD"
    @perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build: ## Build the Docker image
    docker build --build-arg APP_NAME=$APP_NAME \
        --build-arg APP_VSN=$APP_VSN \
        -t $APP_NAME:$APP_VSN-$BUILD \
        -t $APP_NAME:latest .

run: ## Run the app in Docker
    docker run --env-file config/docker.env \
        --expose 4000 -p 4000:4000 \
        --rm -it $APP_NAME:latest
