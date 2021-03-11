# Build Stage
FROM alpine:3.12 as build-env

ARG MAIN_PATH

RUN apk update && apk upgrade && \
    apk add --no-cache bash git openssh make musl-dev go

# Configure Go
ENV GOROOT /usr/lib/go
ENV GOPATH /go
ENV PATH /go/bin:$PATH

RUN mkdir -p ${GOPATH}/src ${GOPATH}/bin

# App
RUN mkdir /src
WORKDIR /src

COPY go.mod .
COPY go.sum .

RUN go mod download

COPY . .

RUN go build -o main $MAIN_PATH

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

ENTRYPOINT ["/app/main"]