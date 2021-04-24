# 1. builder stage
#   - run unit tests 
#   - build executable
#
FROM rust:1.51 AS builder

WORKDIR /app

# get cargo to update the index at this layer so it's cached
RUN cargo search

COPY rust_tonic_mt_bench /app
COPY proto /app/proto

RUN rustup component add rustfmt
RUN cargo build --release

# 2. runtime stage
#   - start from clean debian container
#   - copy built executable 
# 
FROM debian:buster-slim AS runtime
WORKDIR /app

# app and configuration
COPY --from=builder /app/target/release/helloworld-server helloworld-server
ENTRYPOINT [ "./helloworld-server" ]
