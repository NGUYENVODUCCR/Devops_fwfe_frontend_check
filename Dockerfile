# -------------------------------
# Stage 1: Build Flutter Web
# -------------------------------
    FROM ghcr.io/cirruslabs/flutter:3.24.3 AS build

    # Set working directory
    WORKDIR /app
    
    # Copy pubspec & fetch dependencies first (cache layer)
    COPY pubspec.* ./
    RUN flutter pub get
    
    # Copy toàn bộ source code
    COPY . .
    
    # Fix Git dubious ownership
    RUN git config --global --add safe.directory /sdks/flutter
    
    # Tạo pub-cache writable và set quyền cho user appuser (nếu muốn)
    ENV PUB_CACHE=/tmp/.pub-cache
    RUN mkdir -p $PUB_CACHE \
        && chown -R root:root /sdks/flutter $PUB_CACHE
    
    # Build Flutter web release (dưới root để tránh lỗi quyền)
    RUN flutter build web --release
    
    # -------------------------------
    # Stage 2: Serve with Nginx
    # -------------------------------
    FROM nginx:stable-alpine
    
    # Remove default nginx content
    RUN rm -rf /usr/share/nginx/html/*
    
    # Copy build output từ stage trước
    COPY --from=build /app/build/web /usr/share/nginx/html
    
    # Expose port 80
    EXPOSE 80
    
    # Start Nginx
    CMD ["nginx", "-g", "daemon off;"]
    