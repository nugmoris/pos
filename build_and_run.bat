@echo off
echo Building APK...
flutter build apk --debug
echo.
echo Installing APK...
adb install android\app\build\outputs\apk\debug\app-debug.apk
echo.
echo Starting app...
adb shell am start -n com.yourcompany.pos/com.yourcompany.pos.MainActivity
echo.
echo Done! App is running on device.
pause 