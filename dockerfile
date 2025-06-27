FROM golang:1.23 AS builder

ENV CGO_ENABLED=0 \
 GOOS=linux \
 GOARCH=amd64

WORKDIR /app
COPY . .

RUN go mod tidy && go build -o rivenbot-api-service ./cmd/rivenbot-api-service/main.go

FROM alpine:latest

RUN apk add --no-cache curl
WORKDIR /root/

COPY --from=builder /app/rivenbot-api-service .
EXPOSE 8080

ENTRYPOINT ["/root/rivenbot-api-service"]
