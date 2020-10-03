FROM golang:1.13-alpine as build-env

RUN apk update && apk upgrade && \
    apk add --no-cache bash git openssh

RUN mkdir /src
WORKDIR /src

COPY go.mod .
COPY go.sum .

# Add this go mod download command to pull in any dependencies
RUN go mod download

COPY . .

# Our project will now successfully build with the necessary go libraries included.
RUN go build -o main main.go

# Final stage
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
COPY --chown=appuser:appuser db/ /app/db/

ENTRYPOINT /app/main