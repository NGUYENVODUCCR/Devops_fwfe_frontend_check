# -------------------------------
# Stage 1: Build Flutter Web
# -------------------------------
    FROM ghcr.io/cirruslabs/flutter:3.24.3 AS build

    # Set working directory
    WORKDIR /app
    
    # Tạo user không phải root (nếu muốn)
    RUN useradd -ms /bin/bash appuser
    
    # Copy pubspec & fetch dependencies first (tận dụng cache layer)
    COPY pubspec.* ./
    RUN flutter pub get
    
    # Copy toàn bộ source code
    COPY . .
    
    # Fix Git dubious ownership để tránh lỗi khi build web
    RUN git config --global --add safe.directory /sdks/flutter
    
    # Cho phép user 'appuser' truy cập SDK và pub-cache
    RUN chown -R appuser:appuser /sdks/flutter /tmp/.pub-cache
    
    # Sử dụng user appuser để build
    USER appuser
    
    # Đặt PUB_CACHE writable cho user
    ENV PUB_CACHE=/tmp/.pub-cache
    
    # Build Flutter web release
    RUN flutter build web --release
    
    # -------------------------------
    # Stage 2: Serve with Nginx
    # -------------------------------
    FROM nginx:stable-alpine
    
    # Xóa nội dung mặc định của Nginx
    RUN rm -rf /usr/share/nginx/html/*
    
    # Copy build output từ stage trước
    COPY --from=build /app/build/web /usr/share/nginx/html
    
    # Expose port 80
    EXPOSE 80
    
    # Start Nginx
    CMD ["nginx", "-g", "daemon off;"]
    