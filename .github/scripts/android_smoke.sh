#!/usr/bin/env bash
# Installs the release APK on the emulator, starts it and checks that the
# app got through its start. Screenshot and log end up as build artifacts.
set -uo pipefail
mkdir -p smoke
adb install -r build/app/outputs/flutter-apk/app-release.apk
adb logcat -c
adb shell am start -W -n com.kleinepause.app/com.kleinepause.kleine_pause.MainActivity
sleep 25
adb exec-out screencap -p > smoke/start.png
adb logcat -d > smoke/logcat.txt
grep -E "KleinePause|flutter|FATAL|AndroidRuntime|Impeller" smoke/logcat.txt | tail -80
if grep -q "FATAL EXCEPTION" smoke/logcat.txt; then echo "App crashed"; exit 1; fi
if grep -q "\[KleinePause\] Start failed" smoke/logcat.txt; then echo "Start failed"; exit 1; fi
if ! grep -q "\[KleinePause\] preferences ready" smoke/logcat.txt; then echo "Start did not finish"; exit 1; fi
echo "Start OK"
