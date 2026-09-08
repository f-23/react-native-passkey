

## [3.6.2](https://github.com/f-23/react-native-passkey/compare/v3.6.1...v3.6.2) (2026-09-08)


### Bug Fixes

* **android:** skip explicit Kotlin plugin when AGP registers the kotlin extension ([a1f6e81](https://github.com/f-23/react-native-passkey/commit/a1f6e81c3c2ce9d5dd5c8b350894332b3baf5372))
* **ios:** detect no-credential from the error's failure reason ([42875d2](https://github.com/f-23/react-native-passkey/commit/42875d24e8ede1ab9397fae3d41bcd6260dd79a9))

## [3.6.1](https://github.com/f-23/react-native-passkey/compare/v3.6.0...v3.6.1) (2026-08-03)


### Bug Fixes

* **ios:** distinguish user cancel from no-credential in getImmediate ([3c01421](https://github.com/f-23/react-native-passkey/commit/3c01421ccdb35ebb3782faa45411d2dd077b569d)), closes [#107](https://github.com/f-23/react-native-passkey/issues/107)

# [3.6.0](https://github.com/f-23/react-native-passkey/compare/v3.5.0...v3.6.0) (2026-08-01)


### Bug Fixes

* **android:** return stable error codes instead of localized messages ([ff144b1](https://github.com/f-23/react-native-passkey/commit/ff144b1f391de65d44451602d4499baf59a372fa))
* normalize cancellation / no-credential errors on Android & iOS ([89a4c03](https://github.com/f-23/react-native-passkey/commit/89a4c039598ef03dc17318c67da062278086e834)), closes [#106](https://github.com/f-23/react-native-passkey/issues/106) [#107](https://github.com/f-23/react-native-passkey/issues/107)
* propagate native error message instead of discarding it ([724c7fd](https://github.com/f-23/react-native-passkey/commit/724c7fd36d15bf5cade7e8ffc138df0012f22216))


### Features

* add WebAuthn Signal API (signalUnknownCredential, signalAllAcceptedCredentials) ([b000d4b](https://github.com/f-23/react-native-passkey/commit/b000d4b73f3d6a6d5d57d97077df35eb81e31490))

# [3.5.0](https://github.com/f-23/react-native-passkey/compare/v3.4.0...v3.5.0) (2026-06-12)


### Features

* add Passkey.getImmediate for silent credential checks ([e8eb940](https://github.com/f-23/react-native-passkey/commit/e8eb9407affa856d56af7f4ee33749aa94fee4a2)), closes [#91](https://github.com/f-23/react-native-passkey/issues/91)

# [3.4.0](https://github.com/f-23/react-native-passkey/compare/v3.3.3...v3.4.0) (2026-05-22)


### Bug Fixes

* **ios:** base64url-encode userHandle in assertion responses ([2f62d5b](https://github.com/f-23/react-native-passkey/commit/2f62d5b29e8201ec71e91577ffbb0a3f38019319)), closes [#90](https://github.com/f-23/react-native-passkey/issues/90) [#102](https://github.com/f-23/react-native-passkey/issues/102)


### Features

* add CredentialAlreadyExists error for matched excludeCredentials ([c45e0c9](https://github.com/f-23/react-native-passkey/commit/c45e0c90b1237e91c12e87ff0e6b602d8b5b3887)), closes [#86](https://github.com/f-23/react-native-passkey/issues/86)

## [3.3.3](https://github.com/f-23/react-native-passkey/compare/v3.3.2...v3.3.3) (2026-04-07)


### Bug Fixes

* align TypeScript types with native iOS/Android implementations ([5cb2bb0](https://github.com/f-23/react-native-passkey/commit/5cb2bb09235c579aff875288a2bcaa64c86f6134))
* optional prf ([e1cb283](https://github.com/f-23/react-native-passkey/commit/e1cb28345a5ea6d4fb84b8e7735ae2d7fe60e248))
* return largeBlob.blob as a plain array instead of a string-keyed dict ([ba1ff44](https://github.com/f-23/react-native-passkey/commit/ba1ff444ca8ef8aca6d80e50ffbd39a0b0f8ed77))
* undo swift changes ([52d6c7d](https://github.com/f-23/react-native-passkey/commit/52d6c7d0efe0ddaff8ed107442bc38302b6a4fa0))

## [3.3.2](https://github.com/f-23/react-native-passkey/compare/v3.3.1...v3.3.2) (2025-11-17)

## [3.3.1](https://github.com/f-23/react-native-passkey/compare/v3.3.0...v3.3.1) (2025-10-02)

# [3.3.0](https://github.com/f-23/react-native-passkey/compare/v3.2.0...v3.3.0) (2025-10-02)

# [3.2.0](https://github.com/f-23/react-native-passkey/compare/v3.1.0...v3.2.0) (2025-10-01)

# [3.1.0](https://github.com/f-23/react-native-passkey/compare/v3.0.0...v3.1.0) (2025-01-14)

# [3.0.0](https://github.com/f-23/react-native-passkey/compare/v3.0.0-rc2...v3.0.0) (2024-10-30)

# [3.0.0-rc2](https://github.com/f-23/react-native-passkey/compare/v3.0.0-rc...v3.0.0-rc2) (2024-09-11)

# [3.0.0-rc](https://github.com/f-23/react-native-passkey/compare/v3.0.0-beta2...v3.0.0-rc) (2024-09-09)

# [3.0.0-beta2](https://github.com/f-23/react-native-passkey/compare/v3.0.0-beta...v3.0.0-beta2) (2024-08-04)

# [3.0.0-beta](https://github.com/f-23/react-native-passkey/compare/v2.1.1...v3.0.0-beta) (2024-07-29)

## [2.1.1](https://github.com/f-23/react-native-passkey/compare/v2.1.0...v2.1.1) (2023-09-13)

# [2.1.0](https://github.com/f-23/react-native-passkey/compare/v2.0.0...v2.1.0) (2023-09-12)

# [2.0.0](https://github.com/f-23/react-native-passkey/compare/v1.1.3...v2.0.0) (2023-05-24)

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0](https://github.com/mTRx0/react-native-passkey/compare/v1.0.3...v1.1.0) (2022-11-13)

### Added

- Added Security Key support

### Fixed

- README typos

## [1.1.1](https://github.com/mTRx0/react-native-passkey/compare/v1.1.0...v1.1.1) (2022-12-22)

### Change

- README update

## [1.1.2](https://github.com/mTRx0/react-native-passkey/compare/v1.1.1...v1.1.2) (2023-01-20)

### Fixes

- Fixed an importing issue for React Native (PR #6)

## [1.1.3](https://github.com/mTRx0/react-native-passkey/compare/v1.1.2...v1.1.3) (2023-01-28)

### Added

- Added installation support for iOS 11+

### Fixes

- README fixes