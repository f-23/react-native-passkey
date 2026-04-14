# PasskeyExample

This example app demonstrates passkey registration and authentication using `react-native-passkey`.

## Prerequisites

You need a running passkey backend. An example backend can be found at [f-23/passkey-server-example](https://github.com/f-23/passkey-server-example).

The backend must be reachable from the device/emulator. [ngrok](https://ngrok.com/) is a convenient way to expose a local server.

## Setup

### 1. Set the backend URL

In [src/App.tsx](src/App.tsx), replace the placeholder with your backend URL:

```ts
const url = 'https://<your-domain>';
```

This domain is also your **rpId** — it must match what the backend uses as the relying party identifier.

### 2. iOS — associated domain

In [ios/PasskeyExample/PasskeyExample.entitlements](ios/PasskeyExample/PasskeyExample.entitlements), replace `example.com` with your domain:

```xml
<string>webcredentials:<your-domain></string>
```

### 3. Android — Digital Asset Links

Your backend must serve an `assetlinks.json` at `https://<your-domain>/.well-known/assetlinks.json`.

For the debug build, use the following SHA-256 fingerprint of the debug keystore:

```
FA:C6:17:45:DC:09:03:78:6F:B9:ED:E6:2A:96:2B:39:9F:73:48:F0:BB:6F:89:9B:83:32:66:75:91:03:3B:9C
```

Example `assetlinks.json`:

```json
[{
  "relation": ["delegate_permission/common.get_login_creds"],
  "target": {
    "namespace": "android_app",
    "package_name": "com.passkeyexample",
    "sha256_cert_fingerprints": [
      "FA:C6:17:45:DC:09:03:78:6F:B9:ED:E6:2A:96:2B:39:9F:73:48:F0:BB:6F:89:9B:83:32:66:75:91:03:3B:9C"
    ]
  }
}]
```

## Running the app

```sh
# From the repo root
yarn example start

# iOS
yarn example ios

# Android
yarn example android
```
