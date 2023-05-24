import type {
  PasskeyRegistrationResult,
  PasskeyAuthenticationResult,
  PasskeyRegistrationRequest,
  PasskeyAuthenticationRequest,
} from './Passkey';
import { handleNativeError } from './PasskeyError';
import { NativePasskey } from './NativePasskey';

export class PasskeyAndroid {
  /**
   * Android implementation of the registration process
   *
   * @param request The FIDO2 Attestation Request in JSON format
   * @returns The FIDO2 Attestation Result in JSON format
   */
  public static async register(
    request: PasskeyRegistrationRequest
  ): Promise<PasskeyRegistrationResult> {
    const nativeRequest = this.prepareRequest(request);

    try {
      const response = await NativePasskey.register(
        JSON.stringify(nativeRequest)
      );
      return this.handleNativeResponse(JSON.parse(response));
    } catch (error) {
      throw handleNativeError(error);
    }
  }

  /**
   * Android implementation of the authentication process
   *
   * @param request The FIDO2 Assertion Request in JSON format
   * @returns The FIDO2 Assertion Result in JSON format
   */
  public static async authenticate(
    request: PasskeyAuthenticationRequest
  ): Promise<PasskeyAuthenticationResult> {
    const nativeRequest = this.prepareRequest(request);

    try {
      const response = await NativePasskey.authenticate(
        JSON.stringify(nativeRequest)
      );
      return this.handleNativeResponse(JSON.parse(response));
    } catch (error) {
      throw handleNativeError(error);
    }
  }

  /**
   * Prepares the attestation or assertion request for Android
   */
  public static prepareRequest(request: { challenge: string }): object {
    // Transform challenge from Base64 to Base64URL
    const encodedChallenge = request.challenge
      .replace(/\+/g, '-')
      .replace(/\//g, '_')
      .replace(/\=+$/, '');

    return {
      ...request,
      challenge: encodedChallenge,
    };
  }

  /**
   * Transform the attestation or assertion result
   */
  private static handleNativeResponse(
    response: PasskeyRegistrationResult & PasskeyAuthenticationResult
  ): PasskeyRegistrationResult & PasskeyAuthenticationResult {
    // Transform Base64URL Response to Base64
    let id = response.id;
    if (id.length % 4 !== 0) {
      id += '==='.slice(0, 4 - (id.length % 4));
    }
    id = id.replace(/-/g, '+').replace(/_/g, '/');

    return {
      ...response,
      id,
      rawId: id,
    };
  }
}
