# build
FROM golang:1.26-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

RUN apk add --no-cache gcc musl-dev sqlite-dev

COPY --parents controllers database models main.go ./
RUN CGO_ENABLED=1 GOOS=linux go build -a -installsuffix cgo -o main .

# final
FROM alpine:3.23.4

RUN apk add --no-cache sqlite \
    && addgroup -S appgroup && adduser -S appuser -G appgroup \
    && mkdir -p /app && chown -R appuser:appgroup /app

WORKDIR /app

COPY --from=builder /app/main .

USER appuser

EXPOSE 8080

CMD ["./main"]
