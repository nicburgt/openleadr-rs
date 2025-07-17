FROM rust:1.85-alpine AS base

# Install build dependencies
RUN apk add --no-cache alpine-sdk openssl-dev openssl-libs-static

FROM base AS builder

ADD . /app
WORKDIR /app
COPY . .

# Don't depend on live sqlx during build use cached .sqlx
RUN SQLX_OFFLINE=true cargo build --release --bin openleadr-vtn
RUN cp /app/target/release/openleadr-vtn /app/openleadr-vtn-dist

FROM alpine:latest AS final

ARG user=nonroot
ARG group=nonroot
ARG uid=2000
ARG gid=2000
RUN addgroup -g ${gid} ${group} && \
    adduser -u ${uid} -G ${group} -s /bin/sh -D ${user}

WORKDIR /dist

COPY --from=builder --chown=nonroot:nonroot /app/openleadr-vtn-dist /dist/openleadr-vtn-dist

RUN chmod 777 /dist/openleadr-vtn-dist

USER $user

EXPOSE 3000

ENTRYPOINT ["/dist/openleadr-vtn-dist"]