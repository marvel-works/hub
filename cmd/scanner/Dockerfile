# Build scanner
FROM golang:1.15-alpine AS scanner-builder
WORKDIR /go/src/github.com/artifacthub/scanner
COPY go.* ./
COPY cmd/scanner cmd/scanner
COPY internal internal
RUN cd cmd/scanner && CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /scanner .

# Trivy installer
FROM alpine:latest AS trivy-installer
RUN apk --no-cache add curl
RUN curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/master/contrib/install.sh | sh -s -- -b /usr/local/bin

# Final stage
FROM alpine:latest
RUN apk --no-cache add ca-certificates rpm && addgroup -S scanner && adduser -S scanner -G scanner
USER scanner
WORKDIR /home/scanner
COPY --from=scanner-builder /scanner ./
COPY --from=trivy-installer /usr/local/bin/trivy /usr/local/bin
CMD ["./scanner"]
