FROM golang:1.15-alpine3.12 AS builder

ENV GO111MODULE=on           

WORKDIR /app

COPY go.mod .
COPY go.sum .

RUN go mod download

COPY . .

RUN apk --no-cache add bash ca-certificates git gcc g++ libc-dev
RUN CGO_ENABLED=1 GOOS=linux GOARCH=amd64 go build -ldflags "-extldflags \"-static\" -linkmode=external -s -w" .

FROM alpine:3.12

MAINTAINER fciocchetti <fciocchetti@mintel.com>

COPY --from=builder /app/consul-sidekick /usr/local/bin/consul-sidekick

USER 65534

ENTRYPOINT ["/usr/local/bin/consul-sidekick"]
