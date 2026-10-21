#!/usr/bin/env bash
# Installs the release APK on the emulator, starts it and checks that the
# app got through its start. Screenshot and log end up as build artifacts;
# the relevant log lines are also posted as annotations on the check.
set -uo pipefail
mkdir -p smoke

# Annotation text must be one line: encode %, CR and LF.
annotate() {
  local level=$1 title=$2 text=$3
  text=${text//'%'/'%25'}
  text=${text//$'\r'/'%0D'}
  text=${text//$'\n'/'%0A'}
  echo "::${level} title=${title}::${text}"
}

adb install -r build/app/outputs/flutter-apk/app-release.apk 2>&1 | tee smoke/install.txt
adb logcat -c
adb shell am start -W -n com.kleinepause.app/com.kleinepause.kleine_pause.MainActivity
sleep 25
adb exec-out screencap -p > smoke/start.png
adb logcat -d > smoke/logcat.txt

relevant=$(grep -E "KleinePause|flutter|FATAL|AndroidRuntime|Impeller|kleinepause|LiquidGlass" smoke/logcat.txt | cut -c1-300 | tail -70)
echo "$relevant"
annotate notice "logcat" "$relevant"

verdict="Start OK"
if grep -q "FATAL EXCEPTION" smoke/logcat.txt; then
  verdict="App crashed"
elif grep -q "\[KleinePause\] Start failed" smoke/logcat.txt; then
  verdict="Start failed"
elif ! grep -q "\[KleinePause\] preferences ready" smoke/logcat.txt; then
  verdict="Start did not finish"
fi
if [ "$verdict" != "Start OK" ]; then
  annotate error "android start" "$verdict"
  exit 1
fi
annotate notice "android start" "$verdict"
