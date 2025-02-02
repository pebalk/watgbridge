FROM golang:1.23.5-bookworm AS build

RUN apk --no-cache add gcc g++ make git libwebp-tools ffmpeg imagemagick
WORKDIR /go/src/watgbridge
COPY go.mod go.sum entry.sh ./
RUN go mod download all

COPY . ./
RUN go build

FROM bookworm-slim
RUN apk --no-cache add tzdata libwebp-tools ffmpeg imagemagick bash
WORKDIR /app
COPY --from=build /go/src/watgbridge/watgbridge .
COPY --from=build /go/src/watgbridge/entry.sh /entry.sh
RUN chmod +x /entry.sh
ENTRYPOINT ["/entry.sh"]
