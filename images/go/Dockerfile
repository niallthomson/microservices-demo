FROM golang:1.12.0-alpine3.9 as build-env

ARG MAIN_PATH

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
RUN go build -o main $MAIN_PATH

# Final stage
FROM alpine
WORKDIR /app
COPY --from=build-env /src/main /app/
ENTRYPOINT /app/main