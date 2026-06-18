import {
  handleNativeError,
  NotSupportedError,
  TNativeError,
} from './PasskeyError';
import { Platform } from 'react-native';
import type {
  PasskeyCreateRequest,
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
