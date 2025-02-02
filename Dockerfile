FROM golang:1.22.11-alpine3.21 AS build

RUN apk --no-cache add gcc g++ make git libwebp-tools ffmpeg imagemagick
WORKDIR /go/src/watgbridge
COPY go.mod go.sum entry.sh ./
RUN go mod download all

COPY . ./
RUN go build

FROM alpine:3.21
RUN apk --no-cache add tzdata libwebp-tools ffmpeg imagemagick bash
WORKDIR /app
COPY --from=build /go/src/watgbridge/watgbridge .
COPY --from=build /go/src/watgbridge/entry.sh /entry.sh
RUN chmod +x /entry.sh
ENTRYPOINT ["/entry.sh"]
