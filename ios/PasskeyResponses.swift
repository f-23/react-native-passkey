/**
    Specification reference: https://w3c.github.io/webauthn/#typedefdef-publickeycredentialjson
*/
@available(iOS 15.0, *)
typealias PublicKeyCredentialJSON = Either<RNPasskeyCreateResponseJSON, RNPasskeyGetResponseJSON>

/**
    Specification reference: https://w3c.github.io/webauthn/#dictdef-registrationresponsejson
*/
@available(iOS 15.0, *)
internal struct RNPasskeyCreateResponseJSON: Encodable {
  
  var id: Base64URLString
  
  var rawId: Base64URLString
  
  var response: AuthenticatorAttestationResponseJSON
  
  var authenticatorAttachment: AuthenticatorAttachment?
  
  var clientExtensionResults: AuthenticationExtensionsClientOutputsJSON?

  var type: PublicKeyCredentialType = .publicKey
  
}

/**
    Specification reference: https://w3c.github.io/webauthn/#dictdef-authenticatorattestationresponsejson
*/
@available(iOS 15.0, *)
internal struct AuthenticatorAttestationResponseJSON: Encodable {
  
  var clientDataJSON: Base64URLString
  
  var authenticatorData: Base64URLString?
  
  var transports: [AuthenticatorTransport]?
  
  var publicKeyAlgorithm: Int?
  
  var publicKey: Base64URLString?
  
  var attestationObject: Base64URLString
  
}

/**
    Specification reference: https://w3c.github.io/webauthn/#dictdef-authenticationresponsejson
*/
internal struct RNPasskeyGetResponseJSON: Encodable {
  
  var type: PublicKeyCredentialType = .publicKey
  
  var id: Base64URLString
  
  var rawId: Base64URLString?
  
  var authenticatorAttachment: AuthenticatorAttachment?
  
  var response: AuthenticatorAssertionResponseJSON
  
  var clientExtensionResults: AuthenticationExtensionsClientOutputsJSON?
  
}

/**
    Specification reference: https://w3c.github.io/webauthn/#dictdef-authenticatorassertionresponsejson
*/
internal struct AuthenticatorAssertionResponseJSON: Encodable {
  
  var authenticatorData: Base64URLString
  
  var clientDataJSON: Base64URLString
  
  var signature: Base64URLString
  
  var userHandle: Base64URLString?
  
  var attestationObject: Base64URLString?
  
}

/**
    Specification reference: https://w3c.github.io/webauthn/#dictdef-authenticationextensionsclientoutputsjson
*/
internal struct  AuthenticationExtensionsClientOutputsJSON: Encodable {
  var largeBlob: AuthenticationExtensionsLargeBlobOutputsJSON?
  var prf: AuthenticationExtensionsPRFOutputsJSON?
}

/**
 We convert this to `AuthenticationExtensionsLargeBlobOutputsJSON` instead of `AuthenticationExtensionsLargeBlobOutputs` for consistency
 and because it is what is actually returned to RN

 Specification reference: https://w3c.github.io/webauthn/#dictdef-authenticationextensionslargebloboutputs
 */
internal struct AuthenticationExtensionsLargeBlobOutputsJSON: Encodable {
  var supported: Bool?;
  
  var blob: [String: Int]?;
  
  var written: Bool?;
}

/**
 We convert this to `AuthenticationExtensionsPRFOutputsJSON` instead of `AuthenticationExtensionsPRFOutputs` for consistency
 and because it is what is actually returned to RN

 Specification reference: https://w3c.github.io/webauthn/#dictdef-authenticationextensionsprfoutputs
 */
internal struct AuthenticationExtensionsPRFOutputsJSON: Encodable {
  var enabled: Bool?;
  
  var results: AuthenticationExtensionsPRFValues?;
}
