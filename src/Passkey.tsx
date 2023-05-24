import { NotSupportedError } from './PasskeyError';
import { Platform } from 'react-native';
import { PasskeyAndroid } from './PasskeyAndroid';
import { PasskeyiOS } from './PasskeyiOS';

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
    { withSecurityKey }: { withSecurityKey: boolean } = {
      withSecurityKey: false,
    }
  ): Promise<object> {
    if (!Passkey.isSupported) {
      throw NotSupportedError;
    }

    if (Platform.OS === 'android') {
      return PasskeyAndroid.register(request);
    }
    return PasskeyiOS.register(request, withSecurityKey);
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
    { withSecurityKey }: { withSecurityKey: boolean } = {
      withSecurityKey: false,
    }
  ): Promise<PasskeyAuthenticationResult> {
    if (!Passkey.isSupported) {
      throw NotSupportedError;
    }

    if (Platform.OS === 'android') {
      return PasskeyAndroid.authenticate(request);
    }
    return PasskeyiOS.authenticate(request, withSecurityKey);
  }

  /**
   * Checks if Passkeys are supported on the current device
   *
   * @returns A boolean indicating whether Passkeys are supported
   */
  public static async isSupported(): Promise<boolean> {
    if (Platform.OS === 'android') {
      return Platform.Version > 28;
    }

    if (Platform.OS === 'ios') {
      return parseInt(Platform.Version, 10) > 15;
    }

    return false;
  }
}

/**
 * The available options for Passkey operations
 */
export interface PasskeyOptions {
  withSecurityKey: boolean; // iOS only
}

/**
 * The FIDO2 Attestation Request
 */
export interface PasskeyRegistrationRequest {
  challenge: string;
  rp: {
    id: string;
    name?: string;
  };
  user: {
    id: string;
    name?: string;
    displayName: string;
  };
  pubKeyCredParams: Array<{ type: string; alg: number }>;
  timeout: number;
  attestation: string;
  authenticatorSelection: {
    authenticatorAttachment?: string;
    requireResidentKey?: boolean;
    residentKey?: string;
    userVerification?: string;
  };
}

/**
 * The FIDO2 Attestation Result
 */
export interface PasskeyRegistrationResult {
  id: string;
  rawId: string;
  type?: string;
  response: {
    clientDataJSON: string;
    attestationObject: string;
  };
}

/**
 * The FIDO2 Assertion Request
 */
export interface PasskeyAuthenticationRequest {
  challenge: string;
  timeout: number;
  userVerification: string;
  rpId: string;
}

/**
 * The FIDO2 Assertion Result
 */
export interface PasskeyAuthenticationResult {
  id: string;
  rawId: string;
  type?: string;
  response: {
    authenticatorData: string;
    clientDataJSON: string;
    signature: string;
    userHandle: string;
  };
}
