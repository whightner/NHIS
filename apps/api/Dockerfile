FROM dart:3.7

WORKDIR /app

COPY pubspec.* ./
RUN dart pub get

COPY . .
RUN dart pub get --offline

EXPOSE 8080

CMD ["dart", "run", "bin/server.dart"]
