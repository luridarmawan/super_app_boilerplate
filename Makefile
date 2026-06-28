.PHONY: clean run apk build

clean:
	flutter clean

doctor:
	flutter doctor

analyze:
	flutter analyze
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
