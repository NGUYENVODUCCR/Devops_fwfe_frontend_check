# ================================
# Stage 1: Build Flutter Web App
# ================================
FROM debian:bookworm-slim AS build

# Cài dependencies cần cho Flutter SDK
RUN apt update && apt install -y \
    curl git unzip xz-utils zip libglu1-mesa ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Tải và cài đặt Flutter SDK
RUN curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.3-stable.tar.xz \
    && tar xf flutter_linux_3.24.3-stable.tar.xz -C /opt \
    && rm flutter_linux_3.24.3-stable.tar.xz

# Thêm Flutter vào PATH
ENV PATH="$PATH:/opt/flutter/bin"

RUN git config --global --add safe.directory /opt/flutter

# Kiểm tra Flutter hoạt động
RUN flutter --version

# Bật hỗ trợ web và tải package
RUN flutter config --enable-web

WORKDIR /app

# Chỉ copy pubspec trước để tận dụng cache dependency
COPY pubspec.* ./
RUN flutter pub get

# Sau đó copy toàn bộ source code
COPY . .

# Build Flutter web release
RUN flutter build web --release

# ================================
# Stage 2: Serve with Nginx
# ================================
FROM nginx:stable-alpine

# Copy web build sang Nginx
COPY --from=build /app/build/web /usr/share/nginx/html

# (Tùy chọn) Nếu app Flutter dùng route, cần file này để tránh lỗi 404 khi refresh
# COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
