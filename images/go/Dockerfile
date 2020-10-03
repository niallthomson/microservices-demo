# Build Stage
FROM golang:1.13.0-alpine as build-env

ARG MAIN_PATH

RUN apk update && apk upgrade && \
    apk add --no-cache bash git openssh

RUN mkdir /src
WORKDIR /src

COPY go.mod .
COPY go.sum .

RUN go mod download

COPY . .

RUN go build -o main $MAIN_PATH

# Package Stage
FROM alpine:3.12

ENV APPUSER=appuser
ENV APPUID=1000
ENV APPGID=1000

RUN addgroup --gid $APPGID "$APPUSER" \
    && adduser \
    --disabled-password \
    --gecos "" \
    --home "/app" \
    --ingroup "$APPUSER" \
    --uid "$APPUID" \
    "$APPUSER"

RUN apk update && apk upgrade && \
    apk add --no-cache curl

WORKDIR /app
USER appuser

COPY --chown=appuser:appuser --from=build-env /src/main /app/
ENTRYPOINT /app/main