# -------------------------------
# Stage 1: Build Flutter Web
# -------------------------------
    FROM ghcr.io/cirruslabs/flutter:3.24.3 AS build

    # Set working directory
    WORKDIR /app
    
    # Copy pubspec & fetch dependencies first (cache layer)
    COPY pubspec.* ./
    RUN flutter pub get
    
    # Copy the rest of the source code
    COPY . .
    
    # Optional: nếu bạn muốn user không phải root
    # USER appuser
    
    # Fix Git dubious ownership (an extra layer of safety)
    RUN git config --global --add safe.directory /sdks/flutter
    
    # Build Flutter web in release mode
    RUN flutter build web --release
    
    # -------------------------------
    # Stage 2: Serve with Nginx
    # -------------------------------
    FROM nginx:stable-alpine
    
    # Remove default nginx content
    RUN rm -rf /usr/share/nginx/html/*
    
    # Copy built Flutter web output
    COPY --from=build /app/build/web /usr/share/nginx/html
    
    # Expose port 80
    EXPOSE 80
    
    # Start Nginx
    CMD ["nginx", "-g", "daemon off;"]
    