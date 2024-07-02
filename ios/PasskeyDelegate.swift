import Foundation
import AuthenticationServices

@objc(PasskeyDelegate)
@available(iOS 15.0, *)
class PasskeyDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
  private var _completion: (_ error: Error?, _ result: RNPasskeyResult?) -> Void;
  
  // Initializes delegate with a completion handler (callback function)
  init(completionHandler: @escaping (_ error: Error?, _ result: RNPasskeyResult?) -> Void) {
    self._completion = completionHandler;
  }
  
  // Perform the authorization request for a given ASAuthorizationController instance
  @objc(performAuthForController:)
  func performAuthForController(controller: ASAuthorizationController) {
    controller.delegate = self;
    controller.presentationContextProvider = self;
    controller.performRequests();
  }
  
  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    return UIApplication.shared.keyWindow!;
  }
  
  func authorizationController(
      controller: ASAuthorizationController,
      didCompleteWithError error: Error
  ) {
    // Authorization request returned an error
    self._completion(error, nil);
  }

  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
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
      self._completion(RNPasskeyError.requestFailed, nil)
    }
  }
  
  func handlePlatformPublicKeyRegistrationResponse(credential: ASAuthorizationPlatformPublicKeyCredentialRegistration) -> Void {
    if let rawAttestationObject = credential.rawAttestationObject {
      // Parse the authorization credential and resolve the callback
      let registrationResult = RNPasskeyRegistrationResult(credentialID: credential.credentialID,
                                                         rawAttestationObject: rawAttestationObject,
                                                         rawClientDataJSON: credential.rawClientDataJSON);
      self._completion(nil, RNPasskeyResult(registrationResult: registrationResult));
    } else {
      // Authorization credential was malformed, throw an error
      self._completion(RNPasskeyError.requestFailed, nil);
    }
  }
  
  func handleSecurityKeyPublicKeyRegistrationResponse(credential: ASAuthorizationSecurityKeyPublicKeyCredentialRegistration) -> Void {
    if let rawAttestationObject = credential.rawAttestationObject {
      var transports: [ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor.Transport] = [];
      
      // Credential transports is only available on iOS 17.5+, so we need to check it here
      // If device is running <17.5, return an empty array
      if #available(iOS 17.5, *) {
        transports = credential.transports
      }
      
      // Parse the authorization credential and resolve the callback
      let registrationResult = RNPasskeyRegistrationResult(credentialID: credential.credentialID,
                                                           rawAttestationObject: rawAttestationObject,
                                                           rawClientDataJSON: credential.rawClientDataJSON,
                                                           transports: transports);
      self._completion(nil, RNPasskeyResult(registrationResult: registrationResult));
    } else {
      // Authorization credential was malformed, throw an error
      self._completion(RNPasskeyError.requestFailed, nil);
    }
  }
  
  func handlePlatformPublicKeyAssertionResponse(credential: ASAuthorizationPlatformPublicKeyCredentialAssertion) -> Void {
    // Parse the authorization credential and resolve the callback
    let assertionResult = RNPasskeyAssertionResult(credentialID: credential.credentialID,
                                                 rawAuthenticatorData: credential.rawAuthenticatorData,
                                                 rawClientDataJSON: credential.rawClientDataJSON,
                                                 signature: credential.signature,
                                                 userID: credential.userID);
    self._completion(nil, RNPasskeyResult(assertionResult: assertionResult));
  }
  
  func handleSecurityKeyPublicKeyAssertionResponse(credential: ASAuthorizationSecurityKeyPublicKeyCredentialAssertion) -> Void {
    // Parse the authorization credential and resolve the callback
    let assertionResult = RNPasskeyAssertionResult(credentialID: credential.credentialID,
                                                 rawAuthenticatorData: credential.rawAuthenticatorData,
                                                 rawClientDataJSON: credential.rawClientDataJSON,
                                                 signature: credential.signature,
                                                 userID: credential.userID);
    self._completion(nil, RNPasskeyResult(assertionResult: assertionResult));
  }
}
