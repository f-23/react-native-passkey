import Foundation
import AuthenticationServices

@objc(PasskeyDelegate)
class PasskeyDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
  private var _completion: (_ error: Error?, _ result: PassKeyResult?) -> Void;
  
  // Initializes delegate with a completion handler (callback function)
  init(completionHandler: @escaping (_ error: Error?, _ result: PassKeyResult?) -> Void) {
    self._completion = completionHandler;
  }
  
  // Perform the authorization request for a given ASAuthorizationController instance
  @available(iOS 15.0, *)
  @objc(performAuthForController:)
  func performAuthForController(controller: ASAuthorizationController) {
    controller.delegate = self;
    controller.presentationContextProvider = self;
    controller.performRequests();
  }
  
  @available(iOS 13.0, *)
  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    return UIApplication.shared.keyWindow!;
  }
  
  @available(iOS 13.0, *)
  func authorizationController(
      controller: ASAuthorizationController,
      didCompleteWithError error: Error
  ) {
    // Authorization request returned an error
    self._completion(error, nil);
  }

  @available(iOS 13.0, *)
  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    // Check if Passkeys are supported on this OS version
    if #available(iOS 15.0, *) {
      /** We need to determine whether the request was a registration or authentication request and if a security key was used or not*/
      
      // Request was a registration request
      if let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialRegistration {
        self.handlePlatformPublicKeyRegistrationResponse(credential: credential)
      //Request was an authentication request
      } else if let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialAssertion {
        self.handlePlatformPublicKeyAssertionResponse(credential: credential)
      // Request was a registration request with security key
      } else if let credential = authorization.credential as? ASAuthorizationSecurityKeyPublicKeyCredentialRegistration {
        self.handleSecurityKeyPublicKeyRegistrationResponse(credential: credential)
      // Request was an authentication request with security key
      } else if let credential = authorization.credential as? ASAuthorizationSecurityKeyPublicKeyCredentialAssertion {
        self.handleSecurityKeyPublicKeyAssertionResponse(credential: credential)
      } else {
        self._completion(PassKeyError.requestFailed, nil)
      }
    } else {
      // Authorization credential was malformed, throw an error
      self._completion(PassKeyError.notSupported, nil);
    }
  }
  
  @available(iOS 15.0, *)
  func handlePlatformPublicKeyRegistrationResponse(credential: ASAuthorizationPlatformPublicKeyCredentialRegistration) -> Void {
    if let rawAttestationObject = credential.rawAttestationObject {
      // Parse the authorization credential and resolve the callback
      let registrationResult = PassKeyRegistrationResult(credentialID: credential.credentialID,
                                                         rawAttestationObject: rawAttestationObject,
                                                         rawClientDataJSON: credential.rawClientDataJSON);
      self._completion(nil, PassKeyResult(registrationResult: registrationResult));
    } else {
      // Authorization credential was malformed, throw an error
      self._completion(PassKeyError.requestFailed, nil);
    }
  }
  
  @available(iOS 15.0, *)
  func handleSecurityKeyPublicKeyRegistrationResponse(credential: ASAuthorizationSecurityKeyPublicKeyCredentialRegistration) -> Void {
    if let rawAttestationObject = credential.rawAttestationObject {
      // Parse the authorization credential and resolve the callback
      let registrationResult = PassKeyRegistrationResult(credentialID: credential.credentialID,
                                                         rawAttestationObject: rawAttestationObject,
                                                         rawClientDataJSON: credential.rawClientDataJSON);
      self._completion(nil, PassKeyResult(registrationResult: registrationResult));
    } else {
      // Authorization credential was malformed, throw an error
      self._completion(PassKeyError.requestFailed, nil);
    }
  }
  
  @available(iOS 15.0, *)
  func handlePlatformPublicKeyAssertionResponse(credential: ASAuthorizationPlatformPublicKeyCredentialAssertion) -> Void {
    // Parse the authorization credential and resolve the callback
    let assertionResult = PassKeyAssertionResult(credentialID: credential.credentialID,
                                                 rawAuthenticatorData: credential.rawAuthenticatorData,
                                                 rawClientDataJSON: credential.rawClientDataJSON,
                                                 signature: credential.signature,
                                                 userID: credential.userID);
    self._completion(nil, PassKeyResult(assertionResult: assertionResult));
  }
  
  
  @available(iOS 15.0, *)
  func handleSecurityKeyPublicKeyAssertionResponse(credential: ASAuthorizationSecurityKeyPublicKeyCredentialAssertion) -> Void {
    // Parse the authorization credential and resolve the callback
    let assertionResult = PassKeyAssertionResult(credentialID: credential.credentialID,
                                                 rawAuthenticatorData: credential.rawAuthenticatorData,
                                                 rawClientDataJSON: credential.rawClientDataJSON,
                                                 signature: credential.signature,
                                                 userID: credential.userID);
    self._completion(nil, PassKeyResult(assertionResult: assertionResult));
  }
}
