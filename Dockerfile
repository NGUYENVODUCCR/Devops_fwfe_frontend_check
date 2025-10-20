FROM ghcr.io/cirruslabs/flutter:3.24.3 AS build

WORKDIR /app

# Tạo user không root
RUN useradd -ms /bin/bash appuser

# Tạo pub-cache và fix quyền Flutter SDK
RUN mkdir -p /tmp/.pub-cache \
    && chown -R appuser:appuser /tmp/.pub-cache /sdks/flutter \
    && git config --global --add safe.directory /sdks/flutter

# Copy pubspec trước để tận dụng cache
COPY pubspec.* ./
RUN flutter pub get

# Copy toàn bộ source code
COPY . .

# Cho phép appuser ghi/xóa trong project
RUN chown -R appuser:appuser /app

# Chuyển sang user appuser
USER appuser

ENV PUB_CACHE=/tmp/.pub-cache

# Build web release
RUN flutter build web --release
