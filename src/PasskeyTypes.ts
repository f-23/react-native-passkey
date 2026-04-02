/**
 * The FIDO2 Attestation Request
 * https://www.w3.org/TR/webauthn-3/#dictionary-makecredentialoptions
 */
export interface PasskeyCreateRequest {
  challenge: string;
  rp: {
    id: string;
    name: string;
  };
  user: {
    id: string;
    name: string;
    displayName: string;
  };
  pubKeyCredParams: Array<{ type: 'public-key'; alg: number }>;
  timeout?: number;
  excludeCredentials?: Array<PublicKeyCredentialDescriptor>;
  authenticatorSelection?: {
    authenticatorAttachment?: 'platform' | 'cross-platform';
    requireResidentKey?: boolean;
    residentKey?: 'discouraged' | 'preferred' | 'required';
    userVerification?: 'discouraged' | 'preferred' | 'required';
  };
  attestation?: 'none' | 'indirect' | 'direct' | 'enterprise';
  extensions?: {
    largeBlob?: {
      support?: 'preferred' | 'required';
      read?: boolean;
      write?: Uint8Array;
    };
    prf?: {
      eval?: AuthenticationExtensionsPRFValues;
      evalByCredential?: [string: AuthenticationExtensionsPRFValues];
    };
  };
}

/**
 * The FIDO2 Attestation Result
 * https://www.w3.org/TR/webauthn-3/#iface-pkcredential
 */
export interface PasskeyCreateResult {
  id: string;
  rawId: string;
  type?: string;
  authenticatorAttachment?: string;
  response: {
    clientDataJSON: string;
    attestationObject: string;
    authenticatorData?: string;
    transports?: Array<AuthenticatorTransport>;
    publicKeyAlgorithm?: number;
    publicKey?: string;
  };
  clientExtensionResults?: {
    largeBlob?: {
      supported?: boolean;
      blob?: Record<string, number>;
      written?: boolean;
    };
    prf?: {
      enabled?: boolean;
      results?: AuthenticationExtensionsPRFValues;
    };
  };
}

/**
 * The FIDO2 Assertion Request
 * https://www.w3.org/TR/webauthn-3/#dictionary-assertion-options
 */
export interface PasskeyGetRequest {
  challenge: string;
  rpId: string;
  timeout?: number;
  allowCredentials?: Array<PublicKeyCredentialDescriptor>;
  userVerification?: 'discouraged' | 'preferred' | 'required';
  extensions?: {
    largeBlob?: {
      read?: boolean;
      write?: Uint8Array;
    };
    prf?: {
      eval?: AuthenticationExtensionsPRFValues;
      evalByCredential?: [string: AuthenticationExtensionsPRFValues];
    };
  };
}

/**
 * The FIDO2 Assertion Result
 * https://www.w3.org/TR/webauthn-3/#iface-pkcredential
 */
export interface PasskeyGetResult {
  id: string;
  rawId?: string;
  type?: string;
  authenticatorAttachment?: string;
  response: {
    authenticatorData: string;
    clientDataJSON: string;
    signature: string;
    userHandle?: string;
    attestationObject?: string;
  };
  clientExtensionResults?: {
    largeBlob?: {
      supported?: boolean;
      blob?: Record<string, number>;
      written?: boolean;
    };
    prf?: {
      enabled?: boolean;
      results?: AuthenticationExtensionsPRFValues;
    };
  };
}

// https://www.w3.org/TR/webauthn-3/#dictionary-credential-descriptor
export interface PublicKeyCredentialDescriptor {
  type: 'public-key';
  id: string;
  transports?: Array<AuthenticatorTransport>;
}

export enum AuthenticatorTransport {
  usb = 'usb',
  nfc = 'nfc',
  ble = 'ble',
  smartCard = 'smart-card',
  hybrid = 'hybrid',
  internal = 'internal',
}

/**
 * https://www.w3.org/TR/webauthn-3/#prf-extension
 */
export interface AuthenticationExtensionsPRFValues {
  first: Uint8Array;
  second?: Uint8Array;
}
