# Use the official Flutter image as base
FROM ghcr.io/cirruslabs/flutter:stable AS build

# Set the working directory
WORKDIR /app

# Copy pubspec.yaml and pubspec.lock first for better caching
COPY pubspec.yaml pubspec.lock ./

# Get dependencies first (cached layer)
RUN flutter pub get

# Copy source code (excluding build artifacts and cache)
COPY lib/ lib/
COPY web/ web/
COPY assets/ assets/
COPY analysis_options.yaml ./

# Build the Flutter web app with configurable API
ARG API_BASE_URL
RUN flutter build web --release \
    --dart-define=API_BASE_URL="${API_BASE_URL}" \
    --dart-define=Dart2jsOptimization=O4 \
    --source-maps

# Use nginx to serve the built web app
FROM nginx:alpine

# Copy the built web app to nginx html directory
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 8080 (fly.io default)
EXPOSE 8080

# Start nginx
CMD ["nginx", "-g", "daemon off;"]