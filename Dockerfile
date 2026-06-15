# Build a self-contained ephemeris server image for Cloud Run.
#   docker build -t yomi-ephemeris .
#   docker run -p 8080:8080 -e EPHEMERIS_API_KEY=... yomi-ephemeris
FROM dart:stable AS build
WORKDIR /app
COPY pubspec.* ./
RUN dart pub get
COPY . .
# Generated freezed/json files are gitignored, so a clean checkout (CI,
# `gcloud run deploy --source`) doesn't have them — always regenerate.
RUN dart pub get --offline \
    && dart run build_runner build --delete-conflicting-outputs \
    && dart compile exe bin/server.dart -o bin/server

FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/bin/server /app/bin/server
EXPOSE 8080
CMD ["/app/bin/server"]
