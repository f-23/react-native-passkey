//
//  PasskeyDelegate.swift
//  Passkey
//
//  Created by Fabian on 22.10.22.
//  Copyright © 2022 Facebook. All rights reserved.
//

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
      /** We need to determine whether the request was a registration or authentication request */

      // Request was a registration request
      if let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialRegistration {
        if let rawAttestationObject = credential.rawAttestationObject {
          // Parse the authorization credential and resolve the callback
          let registrationResult = PassKeyRegistrationResult(credentialID: credential.credentialID, rawAttestationObject: rawAttestationObject, rawClientDataJSON: credential.rawClientDataJSON);
          
          let passkeyResult = PassKeyResult(registrationResult: registrationResult);
          self._completion(nil, passkeyResult);
        } else {
          // Authorization credential was malformed, throw an error
          self._completion(PassKeyError.requestFailed, nil);
        }
        
        //Request was an authentication request
      } else if let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialAssertion {
        // Parse the authorization credential and resolve the callback
        let assertionResult = PassKeyAssertionResult(credentialID: credential.credentialID, rawAuthenticatorData: credential.rawAuthenticatorData, rawClientDataJSON: credential.rawClientDataJSON, signature: credential.signature, userID: credential.userID);
        
        let passkeyResult = PassKeyResult(assertionResult: assertionResult);
        self._completion(nil, passkeyResult);
      }
      
    } else {
      // Authorization credential was malformed, throw an error
      self._completion(PassKeyError.notSupported, nil);
    }
  }
}
