# Stage 1: Build the app
FROM cirrusci/flutter:3.24.3 AS build

WORKDIR /app
COPY pubspec.* ./
RUN flutter pub get

COPY . .

# ⚠️ Chạy build dưới user non-root
RUN useradd -ms /bin/bash appuser
USER appuser

RUN flutter build web --release

# Stage 2: Serve using nginx
FROM nginx:stable-alpine
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
