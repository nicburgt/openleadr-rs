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

WORKDIR /dist

COPY --from=builder /app/openleadr-vtn-dist /dist/openleadr-vtn-dist

RUN chmod 777 /dist/openleadr-vtn-dist

EXPOSE 3000

ENTRYPOINT ["/dist/openleadr-vtn-dist"]

# # get the pre-built binary from builder so that we don't have to re-build every time
# COPY --from=1 /app/openleadr-vtn/openleadr-vtn
# COPY --from=1 --chown=nonroot:nonroot /app/openleadr-vtn/openleadr-vtn /home/nonroot/openleadr-vtn
# RUN chmod 777 /home/nonroot/openleadr-vtn
# RUN chmod +x /home/nonroot/openleadr-vtn
# USER $user

# WORKDIR /home/nonroot

# ENTRYPOINT ["/app/openleadr-vtn"]
