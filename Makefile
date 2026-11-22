.PHONY: clean run apk apk-run install build

# Serial perangkat untuk `make apk RUN=1` / `make install` bila ada lebih dari satu HP.
DEVICE ?=
INSTALL_ARGS = $(if $(DEVICE),-s $(DEVICE),)

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
	dart run tool/build_release.dart apk --analyze-size --target-platform=android-arm64
ifdef RUN
	dart run tool/install_apk.dart $(INSTALL_ARGS)
endif

# Build APK release lalu langsung pasang dan jalankan di HP (sama dengan `make apk RUN=1`).
apk-run:
	$(MAKE) apk RUN=1 DEVICE=$(DEVICE)

# Pasang dan jalankan APK hasil build terakhir tanpa build ulang.
install:
	dart run tool/install_apk.dart $(INSTALL_ARGS)

build:
	flutter clean
	flutter pub get
	dart run tool/add_version.dart
	dart run tool/build_release.dart appbundle --release
