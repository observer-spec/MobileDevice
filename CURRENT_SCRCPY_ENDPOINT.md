# Active Android scrcpy endpoint

This endpoint is private to your Tailscale tailnet and expires with this workflow.

```powershell
$env:ADB_SERVER_SOCKET = "tcp:100.99.41.53:5037"
adb devices
scrcpy -s emulator-5554
```
