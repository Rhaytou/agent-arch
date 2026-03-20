FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
  libboost-all-dev \
  libssl-dev \
  libevent-dev \
  libzmq3-dev \
  libprotobuf-dev \
  protobuf-compiler \
  curl \
  ca-certificates \
  wget \
  zstd \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Ollama
RUN curl -fsSL https://ollama.com/install.sh | sh

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose Ollama API port
EXPOSE 11434

ENTRYPOINT ["/entrypoint.sh"]



