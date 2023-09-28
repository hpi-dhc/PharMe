FROM instrumentisto/flutter:3.7.6
COPY . /app
RUN rm -rf /app/build
WORKDIR /app
RUN dart pub get
RUN flutter pub get
RUN flutter pub run build_runner build --delete-conflicting-outputs
