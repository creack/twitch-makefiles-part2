FROM golang:1.15.1 as builder

ENV CGO_ENABLED=0
RUN go build -a std

WORKDIR /app

ADD vendor ./vendor
ADD go.mod go.sum ./
RUN go build all

ADD . .

RUN go build -ldflags '-w -s' -v -o /svc

FROM scratch
COPY --from=builder /svc /svc

ENTRYPOINT ["/svc"]
