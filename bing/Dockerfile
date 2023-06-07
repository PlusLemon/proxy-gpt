FROM golang:alpine AS builder

RUN apk update && \
    apk add git && \
    git config --global http.version HTTP/1.1 && \
    git config --global http.sslVerify "false"
    
RUN git clone https://github.com/adams549659584/go-proxy-bingai.git /app
WORKDIR /app
COPY . .
RUN go build -ldflags="-s -w" -tags netgo -trimpath -o go-proxy-bingai main.go

EXPOSE 7860
ENV PORT 7860

CMD ["./go-proxy-bingai"]
