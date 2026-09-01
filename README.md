# MobileDevice

A minimal GitHub Actions example that tests a mobile layout in cloud-hosted runners using Playwright's Pixel 5 and iPhone 13 device profiles.

## Run locally

```bash
npm install
npx playwright install chromium
npm test
```

Every push and pull request runs the mobile checks in `.github/workflows/mobile.yml`. The runner is ephemeral and cloud-hosted by GitHub; Playwright emulates the device viewport, touch behavior, and user agent.

## Real cloud phones

For tests on physical Android/iOS devices, add a provider such as Firebase Test Lab, BrowserStack, Sauce Labs, or AWS Device Farm. Store provider credentials in GitHub Actions Secrets, then upload the APK/IPA and invoke the provider CLI from the workflow. This repository intentionally needs no paid provider account or secrets, so its check runs immediately.
