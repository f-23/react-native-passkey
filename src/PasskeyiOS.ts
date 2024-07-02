import type {
  PasskeyRegistrationResult,
  PasskeyRegistrationRequest,
  PasskeyAuthenticationRequest,
  PasskeyAuthenticationResult,
  PasskeyiOSRegistrationResult,
  PasskeyiOSAuthenticationResult,
} from './PasskeyTypes';
import { handleNativeError } from './PasskeyError';
import { NativePasskey } from './NativePasskey';

export class PasskeyiOS {
  /**
   * iOS implementation of the registration process
   *
   * @param request The FIDO2 Attestation Request in JSON format
   * @param withSecurityKey A boolean indicating wether a security key should be used for registration
   * @returns The FIDO2 Attestation Result in JSON format
   */
  public static async register(
    request: PasskeyRegistrationRequest,
    enablePlatformKey = true,
    enableSecurityKey = true
  ): Promise<PasskeyRegistrationResult> {
    try {
      const response = await NativePasskey.register(
        JSON.stringify(request),
        enablePlatformKey,
        enableSecurityKey
      );
      return this.handleNativeRegistrationResult(response);
    } catch (error) {
      throw handleNativeError(error);
    }
  }

  /**
   * Transform the iOS-specific attestation result into a FIDO2 result
   */
  private static handleNativeRegistrationResult(
    result: PasskeyiOSRegistrationResult
  ): PasskeyRegistrationResult {
    return {
      type: 'public-key',
      id: result.credentialID,
      rawId: result.credentialID,
      response: {
        clientDataJSON: result.response.rawClientDataJSON,
        attestationObject: result.response.rawAttestationObject,
      },
    };
  }

  /**
   * iOS implementation of the authentication process
   *
   * @param request The FIDO2 Assertion Request in JSON format
   * @param withSecurityKey A boolean indicating wether a security key should be used for authentication
   * @returns The FIDO2 Assertion Result in JSON format
   */
  public static async authenticate(
    request: PasskeyAuthenticationRequest,
    enablePlatformKey = true,
    enableSecurityKey = true
  ): Promise<PasskeyAuthenticationResult> {
    try {
      const response = await NativePasskey.authenticate(
        JSON.stringify(request),
        enablePlatformKey,
        enableSecurityKey
      );
      return this.handleNativeAuthenticationResult(response);
    } catch (error) {
      throw handleNativeError(error);
    }
  }

  /**
   * Transform the iOS-specific assertion result into a FIDO2 result
   */
  private static handleNativeAuthenticationResult(
    result: PasskeyiOSAuthenticationResult
  ): PasskeyAuthenticationResult {
    return {
      type: 'public-key',
      id: result.credentialID,
      rawId: result.credentialID,
      response: {
        clientDataJSON: result.response.rawClientDataJSON,
        authenticatorData: result.response.rawAuthenticatorData,
        signature: result.response.signature,
        userHandle: result.userID,
      },
    };
  }
}
