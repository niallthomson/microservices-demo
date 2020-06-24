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
FROM alpine
WORKDIR /app
COPY --from=build-env /src/main /app/
COPY images/ /app/images/
COPY db/ /app/db/
ENTRYPOINT /app/main