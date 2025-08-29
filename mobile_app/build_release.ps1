# === Настройки ===
$projectPath = "D:\work\PlantRecognitionSystem\mobile_app"
$keyAlias = "Serhievich"
$storePassword = "123456"
$keyPassword = "123456"
$keyFile = "$projectPath\android\my-release-key.jks"
$keyProperties = "$projectPath\android\key.properties"

# === 1. Создание ключа (если ещё не создан) ===
if (-Not (Test-Path $keyFile)) {
    Write-Host "Создаю keystore..."
    & keytool -genkey -v `
        -keystore $keyFile `
        -keyalg RSA -keysize 2048 -validity 10000 `
        -alias $keyAlias `
        -storepass $storePassword `
        -keypass $keyPassword `
        -dname "CN=$keyAlias, OU=Dev, O=PlantRecognition, L=Moscow, S=Moscow, C=RU"
} else {
    Write-Host "Keystore уже существует"
}

# === 2. Создание key.properties ===
Write-Host "Создаю key.properties..."
@"
storePassword=$storePassword
keyPassword=$keyPassword
keyAlias=$keyAlias
storeFile=../my-release-key.jks
"@ | Set-Content $keyProperties -Encoding UTF8

# === 3. Сборка APK ===
Write-Host "Собираю APK (release)..."
cd $projectPath
flutter clean
flutter pub get
flutter build apk --release

Write-Host "✅ APK собран!"
Write-Host "Файл: $projectPath\build\app\outputs\flutter-apk\app-release.apk"
 
