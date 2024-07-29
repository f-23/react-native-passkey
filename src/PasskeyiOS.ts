import type {
  PasskeyRegistrationResult,
  PasskeyRegistrationRequest,
  PasskeyAuthenticationRequest,
  PasskeyAuthenticationResult,
} from './PasskeyTypes';
import { handleNativeError } from './PasskeyError';
import { NativePasskey } from './NativePasskey';

export class PasskeyiOS {
  /**
   * iOS implementation of the registration process
   *
   * @param request The FIDO2 Attestation Request in JSON format
   * @returns The FIDO2 Attestation Result in JSON format
   */
  public static async create(
    request: PasskeyRegistrationRequest
  ): Promise<PasskeyRegistrationResult> {
    try {
      const response: PasskeyRegistrationResult = await NativePasskey.create(
        JSON.stringify(request)
      );

      return response;
    } catch (error) {
      throw handleNativeError(error);
    }
  }

  /**
   * iOS implementation of the authentication process
   *
   * @param request The FIDO2 Assertion Request in JSON format
   * @returns The FIDO2 Assertion Result in JSON format
   */
  public static async get(
    request: PasskeyAuthenticationRequest
  ): Promise<PasskeyAuthenticationResult> {
    try {
      const response: PasskeyAuthenticationResult = await NativePasskey.get(
        JSON.stringify(request)
      );

      return response;
    } catch (error) {
      throw handleNativeError(error);
    }
  }
}
