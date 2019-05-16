FROM golang:1.10.1-alpine3.7
WORKDIR /app
ADD src .
RUN go test
RUN CGO_ENABLED=0 GOOS=linux go build -o app .
RUN chmod +x /app
CMD ["./app"]