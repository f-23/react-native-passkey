import { NotSupportedError } from './PasskeyError';
import { Platform } from 'react-native';
import { PasskeyAndroid } from './PasskeyAndroid';
import { PasskeyiOS } from './PasskeyiOS';
import type {
  PasskeyRegistrationRequest,
  PasskeyRegistrationResult,
  PasskeyAuthenticationRequest,
  PasskeyAuthenticationResult,
} from './PasskeyTypes';

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
    request: PasskeyRegistrationRequest
  ): Promise<PasskeyRegistrationResult> {
    if (!Passkey.isSupported()) {
      throw NotSupportedError;
    }

    if (Platform.OS === 'android') {
      return PasskeyAndroid.create(request);
    }

    return PasskeyiOS.create(request);
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
    request: PasskeyAuthenticationRequest
  ): Promise<PasskeyAuthenticationResult> {
    if (!Passkey.isSupported()) {
      throw NotSupportedError;
    }

    if (Platform.OS === 'android') {
      return PasskeyAndroid.get(request);
    }
    return PasskeyiOS.get(request);
  }

  /**
   * Checks if Passkeys are supported on the current device
   *
   * @returns A boolean indicating whether Passkeys are supported
   */
  public static isSupported(): boolean {
    if (Platform.OS === 'android') {
      return Platform.Version > 28;
    }

    if (Platform.OS === 'ios') {
      return parseInt(Platform.Version, 10) >= 15;
    }

    return false;
  }
}
