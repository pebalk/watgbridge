FROM golang:1.22.3-alpine3.19 AS build

RUN apk --no-cache add gcc g++ make git libwebp-dev libwebp-tools ffmpeg imagemagick
WORKDIR /go/src/watgbridge
COPY go.mod go.sum entry.sh ./
RUN go mod download

COPY . ./
RUN go build

FROM alpine:3.19
RUN apk --no-cache add tzdata libwebp-tools ffmpeg imagemagick bash
WORKDIR /app
COPY /go/src/watgbridge/watgbridge .
COPY --from=build /go/src/watgbridge/entry.sh /entry.sh
RUN chmod +x /entry.sh
ENTRYPOINT ["/entry.sh"]
