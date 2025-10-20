# Stage 1: Build Flutter Web
FROM ghcr.io/cirruslabs/flutter:3.24.3 AS build

ARG API_BASE_URL
WORKDIR /app

COPY pubspec.* ./
RUN flutter pub get

COPY . .
RUN flutter build web --release --dart-define=API_BASE_URL=${API_BASE_URL}

# Stage 2: Nginx
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
