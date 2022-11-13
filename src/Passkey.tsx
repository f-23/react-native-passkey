import {
  handleNativeError,
  InvalidChallengeError,
  InvalidUserIdError,
  NotSupportedError,
} from './PasskeyError';
import { NativePasskey } from './NativePasskey';
import { Platform } from 'react-native';

export class Passkey {
  private _identifier: string;
  private _displayName: string;

  /**
   * Creates a new Passkey Instance
   *
   * @param identifier The identifier for the authorization process (usually the associated domain, refer to the docs)
   * @param displayName The displayName for the native Overlay
   */
  constructor(identifier: string, displayName: string) {
    this._identifier = identifier;
    this._displayName = displayName;
  }

  /**
   * Getter for Passkey displayName
   */
  private get displayName(): string {
    return this._displayName;
  }

  /**
   * Getter for Passkey identifier
   */
  private get identifier(): string {
    return this._identifier;
  }

  /**
   * Creates a new Passkey and associates it with a given userId
   *
   * @param challenge The FIDO2 challenge
   * @param userId The id of the new user
   * @param options An object containing options for the registration process
   * @returns A result object containing all necessary FIDO2 data
   */
  public async register(
    challenge: string,
    userId: string,
    options?: PasskeyOptions
  ): Promise<PasskeyRegistrationResult> {
    if (Platform.OS !== 'ios') {
      throw NotSupportedError;
    }
    if (!challenge) {
      throw InvalidChallengeError;
    }
    if (!userId) {
      throw InvalidUserIdError;
    }

    try {
      return (await NativePasskey.register(
        this.identifier,
        challenge,
        this.displayName,
        userId,
        options?.withSecurityKey ?? false
      )) as PasskeyRegistrationResult;
    } catch (error) {
      throw handleNativeError(error);
    }
  }

  /**
   * Authenticates with an exisiting Passkey
   *
   * @param challenge The FIDO2 challenge
   * @param options An object containing options for the authentication process
   * @returns A result object containing all necessary FIDO2 data and the userId associated with the selected Passkey
   */
  public async auth(
    challenge: string,
    options?: PasskeyOptions
  ): Promise<PasskeyAuthResult> {
    if (Platform.OS !== 'ios') {
      throw NotSupportedError;
    }
    if (!challenge) {
      throw InvalidChallengeError;
    }

    try {
      return (await NativePasskey.auth(
        this.identifier,
        challenge,
        options?.withSecurityKey ?? false
      )) as PasskeyAuthResult;
    } catch (error) {
      throw handleNativeError(error);
    }
  }

  /**
   * Checks if Passkeys are supported on the current device
   *
   * @returns A boolean indicating whether Passkeys are supported
   */
  public static async isSupported(): Promise<boolean> {
    return !(Platform.OS !== 'ios' || parseInt(Platform.Version, 10) < 15);
  }
}

export interface PasskeyOptions {
  withSecurityKey: boolean;
}

/**
 * The result of a successful registration request
 */
export interface PasskeyRegistrationResult {
  credentialID: string;
  response: {
    rawAttestationObject: string;
    rawClientDataJSON: string;
  };
}

/**
 * The result of a successful authentication request
 */
export interface PasskeyAuthResult {
  credentialID: string;
  userID: string;
  response: {
    rawAuthenticatorData: string;
    rawClientDataJSON: string;
    signature: string;
  };
}
