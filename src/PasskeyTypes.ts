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
  pubKeyCredParams: Array<{ type: string; alg: number }>;
  timeout?: number;
  excludeCredentials?: Array<PublicKeyCredentialDescriptor>;
  authenticatorSelection?: {
    authenticatorAttachment?: string;
    requireResidentKey?: boolean;
    residentKey?: string;
    userVerification?: string;
  };
  attestation?: string;
  extensions?: {
    largeBlob?: {
      supported?: boolean;
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
  response: {
    clientDataJSON: string;
    attestationObject: string;
  };
  extensions?: {
    clientExtensionResults?: {
      largeBlob?: {
        supported?: boolean;
        blob?: Uint8Array;
        written?: boolean;
      };
      prf: {
        enabled?: boolean;
        results?: AuthenticationExtensionsPRFValues;
      };
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
  userVerification?: string;
  extensions?: {
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
  rawId: string;
  type?: string;
  response: {
    authenticatorData: string;
    clientDataJSON: string;
    signature: string;
    userHandle: string;
  };
  clientExtensionResults?: {
    largeBlob?: {
      supported?: boolean;
      blob?: Uint8Array;
      written?: boolean;
    };
    prf: {
      enabled?: boolean;
      results?: AuthenticationExtensionsPRFValues;
    };
  };
}

// https://www.w3.org/TR/webauthn-3/#dictionary-credential-descriptor
export interface PublicKeyCredentialDescriptor {
  type: string;
  id: string;
  transports?: Array<AuthenticatorTransport>;
}

enum AuthenticatorTransport {
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
interface AuthenticationExtensionsPRFValues {
  first: Uint8Array;
  second?: Uint8Array;
}
