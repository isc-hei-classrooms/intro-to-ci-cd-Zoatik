# Build stage
FROM debian:bookworm AS builder

RUN apt-get update \
  && apt-get install -y --no-install-recommends build-essential ca-certificates \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .

#RUN make clean -- Break docker build
RUN make test
RUN make release

# Runtime stage
FROM debian:bookworm-slim

RUN useradd --uid 10001 --create-home --shell /usr/sbin/nologin appuser

COPY --from=builder /app/build/main /usr/local/bin/dummydb
RUN chown appuser:appuser /usr/local/bin/dummydb

USER appuser
ENTRYPOINT ["dummydb"]
