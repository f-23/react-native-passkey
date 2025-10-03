import Foundation
import AuthenticationServices
import CryptoKit

@available(iOS 15.0, *)
protocol RNPasskeyResultHandler {
  func onSuccess(_ data: PublicKeyCredentialJSON)
  func onError(_ error: Error)
}

@objc(PasskeyDelegate)
@available(iOS 15.0, *)
class PasskeyDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
  private let _completionHandler: RNPasskeyResultHandler
  
  // Initializes delegate with a completion handler (callback function)
  init(completionHandler: RNPasskeyResultHandler) {
    _completionHandler = completionHandler;
  }
  
  // Perform the authorization request for a given ASAuthorizationController instance
  func performAuthForController(controller: ASAuthorizationController) {
    controller.delegate = self;
    controller.presentationContextProvider = self;
    controller.performRequests();
  }
  
  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    return UIApplication
      .shared
      .connectedScenes
      .compactMap { ($0 as? UIWindowScene)?.keyWindow }
      .last ?? ASPresentationAnchor()
  }
  
  func authorizationController(
      controller: ASAuthorizationController,
      didCompleteWithError error: Error
  ) {
    // Authorization request returned an error
    _completionHandler.onError(error);
  }

  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    
    switch (authorization.credential) {
    case let credential as ASAuthorizationPlatformPublicKeyCredentialRegistration:
      self.handlePlatformPublicKeyRegistrationResponse(credential: credential);
      
    case let credential as ASAuthorizationSecurityKeyPublicKeyCredentialRegistration:
      self.handleSecurityKeyPublicKeyRegistrationResponse(credential: credential);
      
    case let credential as ASAuthorizationPlatformPublicKeyCredentialAssertion:
      self.handlePlatformPublicKeyAssertionResponse(credential: credential);
      
    case let credential as ASAuthorizationSecurityKeyPublicKeyCredentialAssertion:
      self.handleSecurityKeyPublicKeyAssertionResponse(credential: credential);
    default:
      _completionHandler.onError(ASAuthorizationError(ASAuthorizationError.invalidResponse));
    }
  }
  
  func handlePlatformPublicKeyRegistrationResponse(credential: ASAuthorizationPlatformPublicKeyCredentialRegistration) -> Void {
    if credential.rawAttestationObject == nil {
      _completionHandler.onError(ASAuthorizationError(ASAuthorizationError.invalidResponse));
    }
    
    // LargeBlob Extension
    var largeBlob: AuthenticationExtensionsLargeBlobOutputsJSON?;
    if #available(iOS 17.0, *) {
      if (credential.largeBlob != nil) {
        largeBlob = AuthenticationExtensionsLargeBlobOutputsJSON(
          supported: credential.largeBlob?.isSupported
        );
      }
    }
    
    // PRF Extension
    var prf: AuthenticationExtensionsPRFOutputsJSON?;
    if #available(iOS 18.0, *) {
      if (credential.prf != nil) {
        prf = AuthenticationExtensionsPRFOutputsJSON(
          enabled: credential.prf?.isSupported,
          results: AuthenticationExtensionsPRFValues(
            first: credential.prf?.first,
            second: credential.prf?.second
          )
        )
      }
    }
      
    let clientExtensionResults = (largeBlob != nil || prf != nil) ? AuthenticationExtensionsClientOutputsJSON(largeBlob: largeBlob, prf: prf) : nil;
    
    let response =  AuthenticatorAttestationResponseJSON(
      clientDataJSON: credential.rawClientDataJSON.toBase64URLEncodedString(),
      attestationObject: credential.rawAttestationObject!.toBase64URLEncodedString()
    );
      
    let createResponse = RNPasskeyCreateResponseJSON(
        id: credential.credentialID.toBase64URLEncodedString(),
        rawId: credential.credentialID.toBase64URLEncodedString(),
        response: response,
        clientExtensionResults: clientExtensionResults
    );

    _completionHandler.onSuccess(.create(createResponse));
  }
  
  func handleSecurityKeyPublicKeyRegistrationResponse(credential: ASAuthorizationSecurityKeyPublicKeyCredentialRegistration) -> Void {
    if credential.rawAttestationObject == nil {
      _completionHandler.onError((ASAuthorizationError(ASAuthorizationError.Code.failed)));
    }
    
    var transports: [AuthenticatorTransport] = [];
    
    // Credential transports is only available on iOS 17.5+, so we need to check it here
    // If device is running <17.5, return an empty array
    if #available(iOS 17.5, *) {
      transports = credential.transports.compactMap { transport in
        AuthenticatorTransport(rawValue: transport.rawValue)
      }
    }
     
    let response =  AuthenticatorAttestationResponseJSON(
      clientDataJSON: credential.rawClientDataJSON.toBase64URLEncodedString(),
      transports: transports, 
      attestationObject: credential.rawAttestationObject!.toBase64URLEncodedString()
    );
     
    let createResponse = RNPasskeyCreateResponseJSON(
      id: credential.credentialID.toBase64URLEncodedString(),
      rawId: credential.credentialID.toBase64URLEncodedString(),
      response: response
    );
    
    _completionHandler.onSuccess(.create(createResponse));
  }
  
  func handlePlatformPublicKeyAssertionResponse(credential: ASAuthorizationPlatformPublicKeyCredentialAssertion) -> Void {
    var largeBlob: AuthenticationExtensionsLargeBlobOutputsJSON?;
    if #available(iOS 17.0, *), let result = credential.largeBlob?.result {
      largeBlob = AuthenticationExtensionsLargeBlobOutputsJSON()
        switch (result) {
        case .read(data: let blobData):
          if let blob = blobData {
            // get uIntArray, then transform to a dictionary RN can work with
            largeBlob?.blob = Dictionary(uniqueKeysWithValues: blob.uIntArray.enumerated().map { (index, value) in
              (String(index + 1), Int(value))
            })
          }
        case .write(success: let successfullyWritten):
          largeBlob?.written = successfullyWritten;
        @unknown default: break
        }
    }
    
    // PRF Extension
    var prf: AuthenticationExtensionsPRFOutputsJSON?;
    if #available(iOS 18.0, *) {
      if (credential.prf != nil) {
        prf = AuthenticationExtensionsPRFOutputsJSON(
          results: AuthenticationExtensionsPRFValues(
            first: credential.prf?.first,
            second: credential.prf?.second
          )
        )
      }
    }
    
    let clientExtensionResults = (largeBlob != nil || prf != nil) ? AuthenticationExtensionsClientOutputsJSON(largeBlob: largeBlob, prf: prf) : nil;
    let userHandle: String? = credential.userID.flatMap { String(data: $0, encoding: .utf8) };

    let response = AuthenticatorAssertionResponseJSON(
        authenticatorData: credential.rawAuthenticatorData.toBase64URLEncodedString(),
        clientDataJSON: credential.rawClientDataJSON.toBase64URLEncodedString(),
        signature: credential.signature!.toBase64URLEncodedString(),
        userHandle: userHandle
    );
    
    let getResponse = RNPasskeyGetResponseJSON(
        id: credential.credentialID.toBase64URLEncodedString(),
        rawId: credential.credentialID.toBase64URLEncodedString(),
        response: response,
        clientExtensionResults: clientExtensionResults
    );
    
    _completionHandler.onSuccess(.get(getResponse));
  }
  
  func handleSecurityKeyPublicKeyAssertionResponse(credential: ASAuthorizationSecurityKeyPublicKeyCredentialAssertion) -> Void {
    let userHandle: String? = credential.userID.flatMap { String(data: $0, encoding: .utf8) };
    
    let response =  AuthenticatorAssertionResponseJSON(
      authenticatorData: credential.rawAuthenticatorData.toBase64URLEncodedString(),
      clientDataJSON: credential.rawClientDataJSON.toBase64URLEncodedString(),
      signature: credential.signature!.toBase64URLEncodedString(),
      userHandle: userHandle
    );
    
    let getResponse = RNPasskeyGetResponseJSON(
      id: credential.credentialID.toBase64URLEncodedString(),
      rawId: credential.credentialID.toBase64URLEncodedString(),
      response: response
    );
    
    _completionHandler.onSuccess(.get(getResponse));
  }
}
