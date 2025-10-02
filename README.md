# react-native-passkey

[![Build](https://img.shields.io/github/actions/workflow/status/mTRx0/react-native-passkey/main.yml?branch=stable)](https://img.shields.io/github/workflow/status/mTRx0/react-native-passkey/Build) [![Version](https://img.shields.io/npm/v/react-native-passkey)](https://img.shields.io/npm/v/react-native-passkey) [![License](https://img.shields.io/npm/l/react-native-passkey)](https://img.shields.io/npm/l/react-native-passkey)

Native Passkeys on iOS 15.0+ and Android API 28+ using React Native.

> You can find an example backend for testing [here](https://github.com/f-23/passkey-server-example).

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

There are iOS specific steps you need to go through in order to configure Passkey support. If you have already set up an associated domain for your application you can skip this step.

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
      "apps": ["XXXXXXXXXX.YYY.YYYYY.YYYYYYYYYYYYYY"]
    },
    "appclips": {}
  }
  ```

- In XCode under `Signing & Capabilities` add a new Capability of type `Associated Domains`.
  Now add this and replace XXXXXX with your domain (e.g. `apple.com`)
  ```
  webcredentials:XXXXXX
  ```
### Android

The Android specific configuration is similar to iOS. If you have already set up Digital Asset Links for your application you can skip this step.

#### Associate your app with a domain ([More info](https://developer.android.com/training/sign-in/passkeys#add-support-dal))
- You need to associate a domain with your application. On your webserver set up this route:

  ```
  GET https://<yourdomain>/.well-known/assetlinks.json
  ```

- This route should serve a static JSON object containing the following information.
  Example (replace with your data, replace SHA_HEX_VALUE with the SHA256 fingerprints of your Android signing certificate)

  ```json
  [{
    "relation": ["delegate_permission/common.get_login_creds"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.example",
      "sha256_cert_fingerprints": [
        SHA_HEX_VALUE
      ]
    }
  }]
  ```

> If you are having issues with your backend setup you can look at an example [here](https://github.com/f-23/passkey-server-example).

---

## Usage

#### Check if Passkeys are supported

```ts
import { Passkey } from 'react-native-passkey';

// Use this method to check if passkeys are supported on the device

const isSupported: boolean = Passkey.isSupported();
```

#### Creating a new Passkey

```ts
import { Passkey, PasskeyRegistrationResult } from 'react-native-passkey';

// Retrieve a valid FIDO2 attestation request from your server
// The challenge inside the request needs to be a base64URL encoded string
// There are plenty of libraries which can be used for this (e.g. fido2-lib)

try {
  // Call the `create` method with the retrieved request in JSON format
  // A native overlay will be displayed
  const result: PasskeyRegistrationResult = await Passkey.create(requestJson);

  // The `create` method returns a FIDO2 attestation result
  // Pass it to your server for verification
} catch (error) {
  // Handle Error...
}
```

#### Authenticating with existing Passkey

```ts
import { Passkey, PasskeyAuthenticationResult } from 'react-native-passkey';

// Retrieve a valid FIDO2 assertion request from your server 
// The challenge inside the request needs to be a base64URL encoded string
// There are plenty of libraries which can be used for this (e.g. fido2-lib)

try {
  // Call the `get` method with the retrieved request in JSON format 
  // A native overlay will be displayed
  const result: PasskeyAuthResult = await Passkey.get(requestJson);

  // The `get` method returns a FIDO2 assertion result
  // Pass it to your server for verification
} catch (error) {
  // Handle Error...
}
```

### Force Platform or Security Key (iOS-specific)

You can force users to register and authenticate using either a platform key, a security key (like [Yubikey](https://www.yubico.com/)) or allow both using the following methods. This only works on iOS, Android will ignore these instructions.

#### Create Passkey

- `Passkey.create()` - Allow the user to choose between platform and security passkey
- `Passkey.createPlatformKey()` - Force the user to create a platform passkey
- `Passkey.createSecurityKey()` - Force the user to create a security passkey

#### Get Passkey

- `Passkey.get()` - Allow the user to choose between platform and security passkey
- `Passkey.getPlatformKey()` - Force the user to authenticate using a platform passkey
- `Passkey.getSecurityKey()` - Force the user to authenticate using a security passkey

### Extensions

#### largeBlob

As of version 3.0 the largeBlob extension will work on iOS 17+ only.

##### Example

You can use the largeBlob extension to store a small amount of opaque data associated with the stored passkey.

###### Check for largeBlob support

During registration you can check for largeBlob extension support on the selected authenticator.

```ts
// Request
{
  ...
  extensions: {
    largeBlob: {
      support: true
    }
  }
}

// Response
{
  ...
  clientExtensionResults: {
      supported: boolean
  }
}
```

###### Write data

If the largeBlob extension is supported you can write data to it during the assertion process (this does NOT work during registration).

```ts
// Request
{
  ...
  extensions: {
    largeBlob: {
      write: Uint8Array<ArrayBuffer>
    }
  }
}

// Response
{
  ...
  clientExtensionResults: { 
    largeBlob: { 
      written: true 
    } 
  }
}
```

###### Read data

After writing you can read the data on any following assertion.

```ts
// Request
{
  ...
  extensions: {
    largeBlob: {
      read: true
    }
  }
}

// Response
{
  ...
  clientExtensionResults: { l
    largeBlob: { 
      blob: Uint8Array<ArrayBuffer>
    } 
  }
}
```

You can find information on the largeBlob extension in the WebAuthn specification [here](https://w3c.github.io/webauthn/#sctn-large-blob-extension).

#### Pseudo-Random Function (PRF)

As of version 3.3 the PRF extension will work for Android and iOS 18+.

##### Example

You can use the PRF extension to retrieve a secret which allows for various use cases like encryption of user data.

During registration you can either pass in an empty object (this will check for PRF support) or a salt (with an optional second) to retrieve the secret.

###### Check for PRF support
```ts
// Request
{
  ...
  extensions: {
    prf: {}
  }
}

// Response
{
  ...
  clientExtensionResults: {
    prf: {
      enabled: boolean
      results: {}
    }
  }
}
```

###### Retrieve secret

You can do this either when creating or when asserting the passkey.

```ts
// Request
{
  ...
  extensions: {
    prf: {
      eval: {
        first: Uint8Array<ArrayBuffer>
        second: Uint8Array<ArrayBuffer> // optional
      }
    }
  }
}

// Response
{
  ...
  clientExtensionResults: { 
    prf: { 
      enabled: true 
      results: { 
          first: 'Be3rf7AK8fwisd9vO13uqaP92XA24jKMSUaEaMclWIk=',
          second: 'jbVCsIGJvtSWv6LRG3fHpUaG/BvT75b8ZLRAuLBNUpk='
      },
    } 
  }
}
```

You can also use `evalByCredential` to retrieve secrets for specific credentials. You can read more in the WebAuthn specification [here](https://w3c.github.io/webauthn/#prf-extension).

---

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

---

## License

MIT
