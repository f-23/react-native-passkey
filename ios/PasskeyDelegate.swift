import Foundation
import AuthenticationServices
import CryptoKit

@available(iOS 15.0, *)
protocol RNPasskeyResultHandler: AnyObject {
  func onSuccess(_ data: PublicKeyCredentialJSON)
  func onError(_ error: Error)
}

@objc(PasskeyDelegate)
@available(iOS 15.0, *)
class PasskeyDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
  private weak var _completionHandler: RNPasskeyResultHandler?

  /**
   Whether the system asked us for a window to present the credential sheet in.

   The system only requests a presentation anchor when it is about to show UI,
   and under immediate (silent) mediation it only shows UI when a credential is
   actually available. That makes this the signal separating "the user dismissed
   the sheet" from "the request failed before anything appeared" — two outcomes
   iOS otherwise reports identically as ASAuthorizationError.canceled (1001).
   See `Passkey.handleErrorCode`.
   */
  private(set) var didRequestPresentationAnchor: Bool = false;

  // Initializes delegate with a completion handler (callback function)
  init(completionHandler: RNPasskeyResultHandler) {
    _completionHandler = completionHandler;
  }

  private func finishWithError(_ error: Error) {
    let handler = _completionHandler;
    _completionHandler = nil;
    handler?.onError(error);
  }

  private func finishWithSuccess(_ data: PublicKeyCredentialJSON) {
    let handler = _completionHandler;
    _completionHandler = nil;
    handler?.onSuccess(data);
  }

  // Perform the authorization request for a given ASAuthorizationController instance
  func performAuthForController(controller: ASAuthorizationController, preferImmediatelyAvailable: Bool = false) {
    controller.delegate = self;
    controller.presentationContextProvider = self;
    // A delegate is created per request, but reset defensively so a reused
    // instance can never carry a stale "UI was shown" verdict into a new one.
    didRequestPresentationAnchor = false;
    if preferImmediatelyAvailable {
      if #available(iOS 16.0, *) {
        controller.performRequests(options: .preferImmediatelyAvailableCredentials);
      } else {
        controller.performRequests();
      }
    } else {
      controller.performRequests();
    }
  }

  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    didRequestPresentationAnchor = true;
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
    finishWithError(error);
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
      finishWithError(ASAuthorizationError(ASAuthorizationError.invalidResponse));
    }
  }
  
  func handlePlatformPublicKeyRegistrationResponse(credential: ASAuthorizationPlatformPublicKeyCredentialRegistration) -> Void {
    guard let attestationObject = credential.rawAttestationObject else {
      finishWithError(ASAuthorizationError(ASAuthorizationError.invalidResponse));
      return;
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
      attestationObject: attestationObject.toBase64URLEncodedString()
    );
      
    let createResponse = RNPasskeyCreateResponseJSON(
        id: credential.credentialID.toBase64URLEncodedString(),
        rawId: credential.credentialID.toBase64URLEncodedString(),
        response: response,
        clientExtensionResults: clientExtensionResults
    );

    finishWithSuccess(.create(createResponse));
  }
  
  func handleSecurityKeyPublicKeyRegistrationResponse(credential: ASAuthorizationSecurityKeyPublicKeyCredentialRegistration) -> Void {
    guard let attestationObject = credential.rawAttestationObject else {
      finishWithError((ASAuthorizationError(ASAuthorizationError.Code.failed)));
      return;
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
      attestationObject: attestationObject.toBase64URLEncodedString()
    );
     
    let createResponse = RNPasskeyCreateResponseJSON(
      id: credential.credentialID.toBase64URLEncodedString(),
      rawId: credential.credentialID.toBase64URLEncodedString(),
      response: response
    );
    
    finishWithSuccess(.create(createResponse));
  }
  
  func handlePlatformPublicKeyAssertionResponse(credential: ASAuthorizationPlatformPublicKeyCredentialAssertion) -> Void {
    guard let signature = credential.signature else {
      finishWithError(ASAuthorizationError(ASAuthorizationError.invalidResponse));
      return;
    }
    var largeBlob: AuthenticationExtensionsLargeBlobOutputsJSON?;
    if #available(iOS 17.0, *), let result = credential.largeBlob?.result {
      largeBlob = AuthenticationExtensionsLargeBlobOutputsJSON()
        switch (result) {
        case .read(data: let blobData):
          if let blob = blobData {
            // Preserve each byte and expose the same zero-based indices as Uint8Array.
            largeBlob?.blob = Dictionary(uniqueKeysWithValues: blob.enumerated().map { (index, value) in
              (String(index), Int(value))
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
    let userHandle: String? = credential.userID?.toBase64URLEncodedString();

    let response = AuthenticatorAssertionResponseJSON(
        authenticatorData: credential.rawAuthenticatorData.toBase64URLEncodedString(),
        clientDataJSON: credential.rawClientDataJSON.toBase64URLEncodedString(),
        signature: signature.toBase64URLEncodedString(),
        userHandle: userHandle
    );
    
    let getResponse = RNPasskeyGetResponseJSON(
        id: credential.credentialID.toBase64URLEncodedString(),
        rawId: credential.credentialID.toBase64URLEncodedString(),
        response: response,
        clientExtensionResults: clientExtensionResults
    );
    
    finishWithSuccess(.get(getResponse));
  }
  
  func handleSecurityKeyPublicKeyAssertionResponse(credential: ASAuthorizationSecurityKeyPublicKeyCredentialAssertion) -> Void {
    guard let signature = credential.signature else {
      finishWithError(ASAuthorizationError(ASAuthorizationError.invalidResponse));
      return;
    }
    let userHandle: String? = credential.userID?.toBase64URLEncodedString();
    
    let response =  AuthenticatorAssertionResponseJSON(
      authenticatorData: credential.rawAuthenticatorData.toBase64URLEncodedString(),
      clientDataJSON: credential.rawClientDataJSON.toBase64URLEncodedString(),
      signature: signature.toBase64URLEncodedString(),
      userHandle: userHandle
    );
    
    let getResponse = RNPasskeyGetResponseJSON(
      id: credential.credentialID.toBase64URLEncodedString(),
      rawId: credential.credentialID.toBase64URLEncodedString(),
      response: response
    );
    
    finishWithSuccess(.get(getResponse));
  }
}
