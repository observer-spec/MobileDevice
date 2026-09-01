# MobileDevice

GitHub Actions mobile testing with Playwright and an Android Emulator.

## Checks included

- **Mobile browser emulation:** Pixel 5 and iPhone 13 profiles via Playwright.
- **Android ADB smoke test:** Boots a cloud-hosted Android API 35 emulator, verifies the ADB connection, reads Android properties, checks screen size, and sends an input event.

The Android job is in `.github/workflows/mobile.yml` and uses [`reactivecircus/android-emulator-runner`](https://github.com/ReactiveCircus/android-emulator-runner). It runs on every push, pull request, or manual dispatch.

## Native scrcpy over Tailscale

For low-latency native streaming, add a repository Actions secret named `TAILSCALE_AUTHKEY` containing an **ephemeral, tagged Tailscale auth key** permitted by your tailnet ACL. Install Tailscale and [scrcpy](https://github.com/Genymobile/scrcpy) on your computer. Each live workflow writes the private endpoint to `CURRENT_SCRCPY_ENDPOINT.md`; connect with:

```bash
adb connect <tailscale-ip>:5556
scrcpy -s <tailscale-ip>:5556
```

The endpoint is reachable only from your Tailscale network and expires when the Actions job ends. Without the secret, browser noVNC access still works normally.

## Access the live Android emulator

To get a browser URL, start the **Mobile device test** workflow with **Run workflow** (not a normal push or pull-request run). The workflow only creates the public tunnel for manual runs. Open the workflow run's **Summary** page and click **Open** under **Android emulator browser session**. The URL is also printed as an `Android emulator URL` notice and included in the failure logs if startup fails.

Log in with the `VNC_PASSWORD` repository secret. The URL is temporary and changes on each run.

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
