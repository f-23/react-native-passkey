import AuthenticationServices

/**
 navigator.credentials.create request options
 
 Specification reference: https://w3c.github.io/webauthn/#dictionary-makecredentialoptions
*/
@available(iOS 15.0, *)
internal struct RNPasskeyCredentialCreationOptions: Decodable {
  
  var rp: PublicKeyCredentialRpEntity
  
  var user: PublicKeyCredentialUserEntity
  
  var challenge: Base64URLString
  
  var pubKeyCredParams: [PublicKeyCredentialParameters]
  
  var timeout: Int?
  
  var excludeCredentials: [PublicKeyCredentialDescriptor]?
  
  var authenticatorSelection: AuthenticatorSelectionCriteria?
  
  var attestation: AttestationConveyancePreference?
  
  var extensions: AuthenticationExtensionsClientInputs?
}

/**
 navigator.credentials.get request options
 
 Specification reference: https://w3c.github.io/webauthn/#dictionary-assertion-options
 */
@available(iOS 15.0, *)
internal struct RNPasskeyCredentialRequestOptions: Decodable {
  
  var challenge: Base64URLString
  
  var rpId: String
  
  var timeout: Int? = 60000
  
  var allowCredentials: [PublicKeyCredentialDescriptor]?
  
  var userVerification: UserVerificationRequirement?
  
  var extensions: AuthenticationExtensionsClientInputs?
  
}
