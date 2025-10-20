# ======================================
# Stage 1: Build Flutter Web
# ======================================
FROM ghcr.io/cirruslabs/flutter:3.24.3 AS build

# ARG chỉ tồn tại trong thời gian build
ARG API_BASE_URL
ENV API_BASE_URL=$API_BASE_URL


WORKDIR /app

# Tạo user không root
RUN useradd -ms /bin/bash appuser

# Tạo pub-cache và fix quyền Flutter SDK
RUN mkdir -p /tmp/.pub-cache \
    && chown -R appuser:appuser /tmp/.pub-cache /sdks/flutter \
    && git config --global --add safe.directory /sdks/flutter

# Copy pubspec trước để tận dụng cache
COPY pubspec.* ./

# Xoá cache Flutter/Dart cũ (tuỳ chọn)
RUN flutter clean
RUN flutter pub cache repair

# Cài dependencies
RUN flutter pub get

# Copy toàn bộ source code
COPY . .

# Cho phép appuser ghi/xóa trong project và pub-cache
RUN chown -R appuser:appuser /app /tmp/.pub-cache

# Chuyển sang user appuser
USER appuser

ENV PUB_CACHE=/tmp/.pub-cache

# Build web release với API_BASE_URL
RUN flutter build web --release --dart-define=API_BASE_URL=${API_BASE_URL}

# ======================================
# Stage 2: Build final image Nginx
# ======================================
FROM nginx:alpine

# Copy build web từ stage trước
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy custom nginx.conf nếu cần
# COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Chạy nginx
CMD ["nginx", "-g", "daemon off;"]
