FROM golang:1.10.1-alpine3.7 as builder
WORKDIR /build
ADD . .
RUN go test 
RUN CGO_ENABLED=0 GOOS=linux go build -o app . 

FROM alpine:latest  
RUN apk --no-cache add ca-certificates
WORKDIR /app
COPY --from=builder /build/app .
RUN chmod +x /app
CMD ["./app"]