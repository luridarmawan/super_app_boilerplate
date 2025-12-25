

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# windows
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android

# windows generate
keytool -genkey -v -keystore "%USERPROFILE%\.android\debug.keystore" -storepass android -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 -validity 10000

```


Tambahkan SHA-1 ke OAuth Client Android:
file: `android/app/src/main/AndroidManifest.xml`

