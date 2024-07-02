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
  public static async register(
    request: PasskeyRegistrationRequest,
    {
      enablePlatformKey,
      enableSecurityKey,
    }: { enablePlatformKey?: boolean; enableSecurityKey?: boolean } = {
      enablePlatformKey: true,
      enableSecurityKey: true,
    }
  ): Promise<PasskeyRegistrationResult> {
    if (!Passkey.isSupported()) {
      throw NotSupportedError;
    }

    if (Platform.OS === 'android') {
      return PasskeyAndroid.register(request);
    }
    return PasskeyiOS.register(request, enablePlatformKey, enableSecurityKey);
  }

  /**
   * Authenticates using an existing Passkey
   *
   * @param request The FIDO2 Assertion Request in JSON format
   * @param options An object containing options for the authentication process
   * @returns The FIDO2 Assertion Result in JSON format
   * @throws
   */
  public static async authenticate(
    request: PasskeyAuthenticationRequest,
    {
      enablePlatformKey,
      enableSecurityKey,
    }: { enablePlatformKey?: boolean; enableSecurityKey?: boolean } = {
      enablePlatformKey: true,
      enableSecurityKey: true,
    }
  ): Promise<PasskeyAuthenticationResult> {
    if (!Passkey.isSupported()) {
      throw NotSupportedError;
    }

    if (Platform.OS === 'android') {
      return PasskeyAndroid.authenticate(request);
    }
    return PasskeyiOS.authenticate(
      request,
      enablePlatformKey,
      enableSecurityKey
    );
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
