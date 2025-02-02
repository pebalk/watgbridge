FROM golang:1.23.5-bookworm AS build

RUN apt-get update && apt-get install -y --no-install-recommends gcc g++ make git libwebp-tools ffmpeg imagemagick
WORKDIR /go/src/watgbridge
COPY go.mod go.sum entry.sh ./
RUN go mod download all

COPY . ./
RUN go build

FROM bookworm-20250113-slim
RUN apt-get update && apt-get install -y --no-install-recommends tzdata libwebp-tools ffmpeg imagemagick bash
WORKDIR /app
COPY --from=build /go/src/watgbridge/watgbridge .
COPY --from=build /go/src/watgbridge/entry.sh /entry.sh
RUN chmod +x /entry.sh
ENTRYPOINT ["/entry.sh"]
