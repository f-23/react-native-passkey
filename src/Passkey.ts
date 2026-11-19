import {
  handleNativeError,
  NotSupportedError,
  TNativeError,
} from './PasskeyError';
import { Platform } from 'react-native';
import type {
  PasskeyCreateRequest,
  PasskeyCreateRestoreCredentialOptions,
  PasskeyCreateResult,
  PasskeyGetRequest,
  PasskeyGetResult,
  PasskeySignalUnknownCredentialRequest,
  PasskeySignalAllAcceptedCredentialsRequest,
} from './PasskeyTypes';
import { stringifyPasskeyRequest } from './PasskeyRequest';
import { NativePasskey } from './NativePasskey';

export class Passkey {
  /**
   * Creates a new Passkey
   *
   * @param request The FIDO2 Attestation Request in JSON format
   * @param options An object containing options for the registration process
   * @returns The FIDO2 Attestation Result in JSON format
   * @throws
   */
  public static async create(
    request: PasskeyCreateRequest
  ): Promise<PasskeyCreateResult> {
    if (!Passkey.isSupported()) {
      throw NotSupportedError;
    }

    try {
      const response = await NativePasskey.create(
        stringifyPasskeyRequest(request, Platform.OS),
        false, // forcePlatformKey
        false // forceSecurityKey
      );

      if (typeof response === 'string') {
        return JSON.parse(response) as PasskeyCreateResult;
      }
      return response as PasskeyCreateResult;
    } catch (error: unknown) {
      throw handleNativeError(error as TNativeError);
    }
  }

  /**
   * Creates a new Passkey
   * Forces the usage of a platform authenticator on iOS
   *
   * @param request The FIDO2 Attestation Request in JSON format
   * @param options An object containing options for the registration process
   * @returns The FIDO2 Attestation Result in JSON format
   * @throws
   */
  public static async createPlatformKey(
    request: PasskeyCreateRequest
  ): Promise<PasskeyCreateResult> {
    if (!Passkey.isSupported()) {
      throw NotSupportedError;
    }

    try {
      const response = await NativePasskey.create(
        stringifyPasskeyRequest(request, Platform.OS),
        true, // forcePlatformKey
        false // forceSecurityKey
      );

      if (typeof response === 'string') {
        return JSON.parse(response) as PasskeyCreateResult;
      }
      return response as PasskeyCreateResult;
    } catch (error: unknown) {
      throw handleNativeError(error as TNativeError);
    }
  }

  /**
   * Creates a new Passkey
   * Forces the usage of a security authenticator on iOS
   *
   * @param request The FIDO2 Attestation Request in JSON format
   * @param options An object containing options for the registration process
   * @returns The FIDO2 Attestation Result in JSON format
   * @throws
   */
  public static async createSecurityKey(
    request: PasskeyCreateRequest
  ): Promise<PasskeyCreateResult> {
    if (!Passkey.isSupported()) {
      throw NotSupportedError;
    }

    try {
      const response = await NativePasskey.create(
        stringifyPasskeyRequest(request, Platform.OS),
        false, // forcePlatformKey
        true // forceSecurityKey
      );

      if (typeof response === 'string') {
        return JSON.parse(response) as PasskeyCreateResult;
      }
      return response as PasskeyCreateResult;
    } catch (error: unknown) {
      throw handleNativeError(error as TNativeError);
    }
  }

  /**
   * Authenticates using an existing Passkey
   *
   * @param request The FIDO2 Assertion Request in JSON format
   * @param options An object containing options for the authentication process
   * @returns The FIDO2 Assertion Result in JSON format
   * @throws
   */
  public static async get(
    request: PasskeyGetRequest
  ): Promise<PasskeyGetResult> {
    if (!Passkey.isSupported()) {
      throw NotSupportedError;
    }

    try {
      const response = await NativePasskey.get(
        stringifyPasskeyRequest(request, Platform.OS),
        false, // forcePlatformKey
        false, // forceSecurityKey
        false // preferImmediatelyAvailable
      );

      if (typeof response === 'string') {
        return JSON.parse(response) as PasskeyGetResult;
      }
      return response as PasskeyGetResult;
    } catch (error: unknown) {
      throw handleNativeError(error as TNativeError);
    }
  }

  /**
   * Authenticates using an existing Passkey, but only if a credential is
   * immediately available on the device. On iOS 16+ this uses
   * `ASAuthorizationController.preferImmediatelyAvailableCredentials` and on
   * Android the `preferImmediatelyAvailableCredentials` flag of
   * `GetCredentialRequest`. When no credential is available the request fails
   * silently (no modal) with a `NoCredentials` error, making this suitable for
   * silent / opportunistic checks.
   *
   * @param request The FIDO2 Assertion Request in JSON format
   * @returns The FIDO2 Assertion Result in JSON format
   * @throws
   */
  public static async getImmediate(
    request: PasskeyGetRequest
  ): Promise<PasskeyGetResult> {
    if (!Passkey.isSupported()) {
      throw NotSupportedError;
    }

    try {
      const response = await NativePasskey.get(
        stringifyPasskeyRequest(request, Platform.OS),
        true, // forcePlatformKey (immediate is platform-only)
        false, // forceSecurityKey
        true // preferImmediatelyAvailable
      );

      if (typeof response === 'string') {
        return JSON.parse(response) as PasskeyGetResult;
      }
      return response as PasskeyGetResult;
    } catch (error: unknown) {
      throw handleNativeError(error as TNativeError);
    }
  }

  /**
   * Authenticates using an existing Passkey
   * Forces the usage of a platform authenticator on iOS
   *
   * @param request The FIDO2 Assertion Request in JSON format
   * @param options An object containing options for the authentication process
   * @returns The FIDO2 Assertion Result in JSON format
   * @throws
   */
  public static async getPlatformKey(
    request: PasskeyGetRequest
  ): Promise<PasskeyGetResult> {
    if (!Passkey.isSupported()) {
      throw NotSupportedError;
    }

    try {
      const response = await NativePasskey.get(
        stringifyPasskeyRequest(request, Platform.OS),
        true, // forcePlatformKey
        false, // forceSecurityKey
        false // preferImmediatelyAvailable
      );

      if (typeof response === 'string') {
        return JSON.parse(response) as PasskeyGetResult;
      }
      return response as PasskeyGetResult;
    } catch (error: unknown) {
      throw handleNativeError(error as TNativeError);
    }
  }

  /**
   * Authenticates using an existing Passkey
   * Forces the usage of a security authenticator on iOS
   *
   * @param request The FIDO2 Assertion Request in JSON format
   * @param options An object containing options for the authentication process
   * @returns The FIDO2 Assertion Result in JSON format
   * @throws
   */
  public static async getSecurityKey(
    request: PasskeyGetRequest
  ): Promise<PasskeyGetResult> {
    if (!Passkey.isSupported()) {
      throw NotSupportedError;
    }

    try {
      const response = await NativePasskey.get(
        stringifyPasskeyRequest(request, Platform.OS),
        false, // forcePlatformKey
        true, // forceSecurityKey
        false // preferImmediatelyAvailable
      );

      if (typeof response === 'string') {
        return JSON.parse(response) as PasskeyGetResult;
      }
      return response as PasskeyGetResult;
    } catch (error: unknown) {
      throw handleNativeError(error as TNativeError);
    }
  }

  /**
   * Cancels the create or get request in flight, if any, and dismisses its
   * system sheet. The request's promise rejects with an `Aborted` error.
   *
   * Android cancels the Credential Manager call; iOS 16+ calls
   * `ASAuthorizationController.cancel()`. iOS 15 has no way to dismiss the
   * sheet, so there the promise rejects but the sheet stays up until the user
   * dismisses it. A no-op when no request is in flight.
   */
  public static cancel(): void {
    NativePasskey.cancel();
  }

  /**
   * Reports a credential the relying party no longer recognizes so OS credential
   * managers can remove / hide it (WebAuthn Signal API).
   *
   * Use this when **unauthenticated** (e.g. after a failed sign-in): it takes a
   * single credential id and no user handle, so it reveals nothing about the user.
   * For the authenticated full-set reconcile, use `signalAllAcceptedCredentials`
   * instead.
   *
   * This is best-effort and resolves once the request is accepted. It no-ops on OS
   * versions without Signal API support (iOS < 26).
   *
   * @param request The relying party id and the base64URL encoded credential id
   * @returns A Promise that resolves once the signal has been delivered
   * @throws
   */
  public static async signalUnknownCredential(
    request: PasskeySignalUnknownCredentialRequest
  ): Promise<void> {
    return NativePasskey.signalUnknownCredential(
      request.rpId,
      request.credentialId
    );
  }

  /**
   * Reports the complete set of credential ids the relying party still accepts for
   * a given user (WebAuthn Signal API). OS credential managers remove / hide any
   * stored credentials not in the list (reversible — re-add an id to restore; an
   * empty list hides all).
   *
   * Use this when **authenticated** (after login, or after adding / deleting a
   * passkey): it needs the user handle and the full accepted set, so it
   * authoritatively prunes. For a single credential when unauthenticated, use
   * `signalUnknownCredential` instead.
   *
   * This is best-effort and resolves once the request is accepted. It no-ops on OS
   * versions without Signal API support (iOS < 26).
   *
   * @param request The relying party id, the base64URL encoded user handle and the
   * base64URL encoded credential ids still accepted by the server
   * @returns A Promise that resolves once the signal has been delivered
   * @throws
   */
  public static async signalAllAcceptedCredentials(
    request: PasskeySignalAllAcceptedCredentialsRequest
  ): Promise<void> {
    return NativePasskey.signalAllAcceptedCredentials(
      request.rpId,
      request.userId,
      JSON.stringify(request.allAcceptedCredentialIds)
    );
  }

  /**
   * Creates an Android Restore Credential (`CreateRestoreCredentialRequest`) so the
   * user's account can be silently restored when setting up a new Android device via
   * cloud backup or device-to-device (D2D) transfer.
   *
   * By default (`isCloudBackupEnabled = true`), if cloud backup or end-to-end
   * encryption (screen lock) is not enabled on the device (`E2eeUnavailableException`),
   * the native module automatically falls back to `isCloudBackupEnabled = false` so
   * local D2D transfers remain supported.
   *
   * Android 9 (API 28)+ only; rejects with `NotSupported` on iOS or older Android versions.
   *
   * @param request The FIDO2 Attestation Request in JSON format
   * @param options Optional settings (`isCloudBackupEnabled`, defaults to `true`)
   * @returns The FIDO2 Attestation Result in JSON format
   * @throws
   */
  public static async createRestoreCredential(
    request: PasskeyCreateRequest,
    options?: PasskeyCreateRestoreCredentialOptions
  ): Promise<PasskeyCreateResult> {
    if (!Passkey.isRestoreCredentialSupported()) {
      throw NotSupportedError;
    }

    try {
      const response = await NativePasskey.createRestoreCredential(
        stringifyPasskeyRequest(request, Platform.OS),
        options?.isCloudBackupEnabled ?? true
      );

      if (typeof response === 'string') {
        return JSON.parse(response) as PasskeyCreateResult;
      }
      return response as PasskeyCreateResult;
    } catch (error: unknown) {
      throw handleNativeError(error as TNativeError);
    }
  }

  /**
   * Retrieves an Android Restore Credential (`GetRestoreCredentialOption`) transferred
   * from a previous device to silently sign in the user on a new device.
   *
   * Rejects with `NoCredentials` when no restore credential exists on the device.
   * Android 9 (API 28)+ only; rejects with `NotSupported` on iOS or older Android versions.
   *
   * @param request The FIDO2 Assertion Request in JSON format
   * @returns The FIDO2 Assertion Result in JSON format
   * @throws
   */
  public static async getRestoreCredential(
    request: PasskeyGetRequest
  ): Promise<PasskeyGetResult> {
    if (!Passkey.isRestoreCredentialSupported()) {
      throw NotSupportedError;
    }

    try {
      const response = await NativePasskey.getRestoreCredential(
        stringifyPasskeyRequest(request, Platform.OS)
      );

      if (typeof response === 'string') {
        return JSON.parse(response) as PasskeyGetResult;
      }
      return response as PasskeyGetResult;
    } catch (error: unknown) {
      throw handleNativeError(error as TNativeError);
    }
  }

  /**
   * Deletes the stored Android Restore Credential (`TYPE_CLEAR_RESTORE_CREDENTIAL`) from
   * the device and backup. Call this whenever the user signs out or their session is
   * invalidated.
   *
   * Android 9 (API 28)+ only; rejects with `NotSupported` on iOS or older Android versions.
   *
   * @returns A Promise that resolves once the restore credential has been cleared
   * @throws
   */
  public static async clearRestoreCredential(): Promise<void> {
    if (!Passkey.isRestoreCredentialSupported()) {
      throw NotSupportedError;
    }

    try {
      await NativePasskey.clearRestoreCredential();
    } catch (error: unknown) {
      throw handleNativeError(error as TNativeError);
    }
  }

  /**
   * Checks if Android Restore Credentials are supported on the current device
   *
   * @returns A boolean indicating whether Restore Credentials are supported
   */
  public static isRestoreCredentialSupported(): boolean {
    return Platform.OS === 'android' && Platform.Version >= 28;
  }

  /**
   * Checks if Passkeys are supported on the current device
   *
   * @returns A boolean indicating whether Passkeys are supported
   */
  public static isSupported(): boolean {
    if (Platform.OS === 'android') {
      return Platform.Version >= 28;
    }

    if (Platform.OS === 'ios') {
      return parseInt(Platform.Version, 10) >= 15;
    }

    return false;
  }
}
