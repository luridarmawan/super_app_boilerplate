.PHONY: clean run apk build

clean:
	flutter clean

run:
	flutter run

apk:
	flutter clean
	flutter pub get
	flutter build apk --analyze-size --target-platform=android-arm64

build:
	flutter clean
	flutter pub get
	dart run tool/add_version.dart
	flutter build appbundle --release
