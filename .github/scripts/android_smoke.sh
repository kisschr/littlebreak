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

# Every adb call is time-boxed so a stuck emulator cannot eat the job's minutes.
timeout 180 adb install -r build/app/outputs/flutter-apk/app-release.apk 2>&1 | tee smoke/install.txt
timeout 20 adb logcat -c
timeout 30 adb shell am start -n com.kleinepause.app/com.kleinepause.kleine_pause.MainActivity 2>&1 | tee smoke/am_start.txt
sleep 25
timeout 60 adb logcat -d > smoke/logcat.txt
timeout 30 adb exec-out screencap -p > smoke/start.png
pid=$(timeout 10 adb shell pidof com.kleinepause.app | tr -d '\r')

annotate notice "device" "install: $(tail -3 smoke/install.txt)
am start: $(cat smoke/am_start.txt)
pid: ${pid:-none}
logcat lines: $(wc -l < smoke/logcat.txt)"

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
