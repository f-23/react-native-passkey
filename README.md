# react-native-passkey

[![Build](https://img.shields.io/github/actions/workflow/status/mTRx0/react-native-passkey/main.yml?branch=stable)](https://img.shields.io/github/workflow/status/mTRx0/react-native-passkey/Build) [![Version](https://img.shields.io/npm/v/react-native-passkey)](https://img.shields.io/npm/v/react-native-passkey) [![License](https://img.shields.io/npm/l/react-native-passkey)](https://img.shields.io/npm/l/react-native-passkey)

Native Passkeys on iOS (and soon android) using React Native.

> Please note that this package only supports iOS 15.0+.
> Native android support will follow as soon as an API becomes available. ([More info](https://github.com/mTRx0/react-native-passkey/issues/2))

## Installation

#### Javascript

For the javascript part of the installation you need to run

```sh
npm install react-native-passkey
```

or

```sh
yarn add react-native-passkey
```

#### Native

For the native part of the installation you need to run

```sh
cd ios && pod install
```

in the root of your React Native project.

---

## Configuration

### iOS

There are iOS specific steps you need to go through in order to configure Passkey support.

#### Set up an associated domain for your application ([More info](https://developer.apple.com/documentation/xcode/supporting-associated-domains))

- You need to associate a domain with your application. On your webserver set up this route:

  ```
  GET https://<yourdomain>/.well-known/apple-app-site-association
  ```

- This route should serve a static JSON object containing your team id and bundle identifier.
  Example (replace XXXXXXXXXX with your team identifier and the rest with your bundle id, e.g. "H123456789.com.mtrx0.passkeyExample"):

  ```json
  {
    "applinks": {},
    "webcredentials": {
      "apps": [
        "XXXXXXXXXX.YYY.YYYYY.YYYYYYYYYYYYYY"
      ]
    },
    "appclips": {}
  }
  ```

- In XCode under `Signing & Capabilities` add a new Capability of type `Associated Domains`.
  Now add this and replace XXXXXX with your domain (e.g. `apple.com`)
  ```
  webcredentials:XXXXXX
  ```

---

## Usage

### Configuration

Create a new Passkey Instance by passing in your previously configured `associated domain` and a `display name` for your app.

```ts
const passkey = new Passkey('example.com', 'Passkey Test App');
```

After configuration there are two methods used for creating new passkeys and authenticating with existing ones.

#### Creating a new Passkey

```ts
import { Passkey, PasskeyRegistrationResult } from 'react-native-passkey';

// Retrieve a valid FIDO2 attestation challenge
// and a newly generated user ID from your backend
// There are plenty of libraries which can be used for this (e.g. fido2-lib)

try {
  // Call the `register` method with the retrieved challenge and userID
  // A native overlay will be displayed
  const result: PasskeyRegistrationResult = await passkey.register(
    challenge,
    userID
  );

  // The registration result object will look like this:
  //  result = {
  //    credentialID: string;
  //     response: {
  //       clientDataJSON: string;
  //       attestationObject: string;
  //     }
  //  }

  // All strings inside this object are base64 encoded values.
  // Pass the result to your backend for verification...
} catch (error) {
  // Handle Error...
}
```

#### Authenticating with existing Passkey

```ts
import { Passkey, PasskeyAuthResult } from 'react-native-passkey';

// Retrieve a valid FIDO2 assertion challenge
// There are plenty of libraries which can be used for this (e.g. fido2-lib)

try {
  // Call the `auth` method with the retrieved challenge
  // A native overlay will be displayed
  const result: PasskeyAuthResult = await passkey.auth(challenge);

  // The authentication result object will look like this:
  //  result = {
  //    credentialID: string;
  //    userID: string;
  //     response: {
  //       clientDataJSON: string;
  //       authenticatorData: string;
  //       signature: string;
  //     }
  //  }

  // The userID string contains the id of the user associated with the retrieved passkey.

  // All strings inside this object are base64 encoded values
  // except the userID which is provided as a plain string.
  // Pass the result to your backend for verification...
} catch (error) {
  // Handle Error...
}
```

### Security Keys

You can allow users to register and authenticate using a Security Key (like [Yubikey](https://www.yubico.com/)).

For this just pass an options object containing `{ withSecurityKey: true }` to the `Passkey.auth()` or `Passkey.register()` calls.

```ts
const result: PasskeyAuthResult = await passkey.auth(challenge, { withSecurityKey: true });
```

or

```ts
const result: PasskeyRegistrationResult = await passkey.register(
  challenge,
  userID,
  { withSecurityKey: true }
);
```

---

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

---

## License

MIT
