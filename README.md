# MobileDevice

GitHub Actions mobile testing with Playwright and an Android Emulator.

## Checks included

- **Mobile browser emulation:** Pixel 5 and iPhone 13 profiles via Playwright.
- **Android ADB smoke test:** Boots a cloud-hosted Android API 35 emulator, verifies the ADB connection, reads Android properties, checks screen size, and sends an input event.

The Android job is in `.github/workflows/mobile.yml` and uses [`reactivecircus/android-emulator-runner`](https://github.com/ReactiveCircus/android-emulator-runner). It runs on every push, pull request, or manual dispatch.

## Run browser tests locally

```bash
npm install
npx playwright install chromium
npm test
```

## Add an APK later

Inside the emulator runner's `script`, add commands such as:

```bash
adb install path/to/app.apk
adb shell am start -n com.example.app/.MainActivity
adb logcat -d
```

This uses a cloud-hosted emulator, not a physical phone. For real devices, integrate Firebase Test Lab, BrowserStack, Sauce Labs, or AWS Device Farm with GitHub Actions Secrets.
