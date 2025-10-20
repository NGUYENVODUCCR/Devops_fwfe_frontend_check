FROM ghcr.io/cirruslabs/flutter:3.24.3 AS build

WORKDIR /app

# Tạo user appuser
RUN useradd -ms /bin/bash appuser

# Tạo pub-cache
RUN mkdir -p /tmp/.pub-cache \
    && chown -R appuser:appuser /tmp/.pub-cache \
    && git config --global --add safe.directory /sdks/flutter \
    && chown -R appuser:appuser /sdks/flutter

# Copy pubspec trước để tận dụng cache
COPY pubspec.* ./
RUN flutter pub get

# Copy toàn bộ source code
COPY . .

# Sử dụng user appuser
USER appuser

# Đặt pub-cache
ENV PUB_CACHE=/tmp/.pub-cache

# Build web release
RUN flutter build web --release
