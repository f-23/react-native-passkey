import AuthenticationServices

@objc(Passkey)
class Passkey: NSObject {
  var passKeyDelegate: PasskeyDelegate?;
  
  @objc(register:withChallenge:withDisplayName:withUserId:withResolver:withRejecter:)
  func register(_ identifier: String, challenge: String, displayName: String, userId: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) -> Void {

    // Convert challenge and userId to correct type
    guard let challengeData: Data = Data(base64Encoded: challenge) else {
      reject(PassKeyError.invalidChallenge.rawValue, PassKeyError.invalidChallenge.rawValue, nil);
      return;
    }
    let userIdData: Data = RCTConvert.nsData(userId);
    
    // Check if Passkeys are supported on this OS version
    if #available(iOS 15.0, *) {
      // Create a new registration request
      let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: identifier);
      let platformKeyRequest = platformProvider.createCredentialRegistrationRequest(challenge: challengeData, name: displayName, userID: userIdData);
      let authController = ASAuthorizationController(authorizationRequests: [platformKeyRequest]);
      
      // Set up a PasskeyDelegate instance with a callback function
      self.passKeyDelegate = PasskeyDelegate { error, result in
        // Check if authorization process returned an error and throw if thats the case
        if (error != nil) {
          let passkeyError = self.handleErrorCode(error: error!);
          reject(passkeyError.rawValue, passkeyError.rawValue, nil);
          return;
        }
        
        // Check if the result object contains a valid registration result
        if let registrationResult = result?.registrationResult {
          // Return a NSDictionary instance with the received authorization data
          let authResult: NSDictionary = [
            "credentialID": registrationResult.credentialID.base64EncodedString(),
            "rawAttestationObject": registrationResult.rawAttestationObject.base64EncodedString(),
            "rawClientDataJSON": registrationResult.rawClientDataJSON.base64EncodedString()
          ];
          resolve(authResult);
        } else {
          // If result didn't contain a valid registration result throw an error
          reject(PassKeyError.requestFailed.rawValue, PassKeyError.requestFailed.rawValue, nil);
        }
      }
      
      if let passKeyDelegate = self.passKeyDelegate {
        // Perform the authorization request
        passKeyDelegate.performAuthForController(controller: authController);
      }
    } else {
      // If Passkeys are not supported throw an error
      reject(PassKeyError.notSupported.rawValue, PassKeyError.notSupported.rawValue, nil);
    }
  }
  
  @objc(auth:withChallenge:withResolver:withRejecter:)
  func auth(_ identifier: String, challenge: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) -> Void {

    // Convert challenge to correct type
    guard let challengeData: Data = Data(base64Encoded: challenge) else {
      reject(PassKeyError.invalidChallenge.rawValue, PassKeyError.invalidChallenge.rawValue, nil);
      return;
    }
    
    // Check if Passkeys are supported on this OS version
    if #available(iOS 15.0, *) {
      let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: identifier);
      let platformKeyRequest = platformProvider.createCredentialAssertionRequest(challenge: challengeData);
      let authController = ASAuthorizationController(authorizationRequests: [platformKeyRequest]);
      
      // Set up a PasskeyDelegate instance with a callback function
      self.passKeyDelegate = PasskeyDelegate { error, result in
        // Check if authorization process returned an error and throw if thats the case
        if (error != nil) {
          let passkeyError = self.handleErrorCode(error: error!);
          reject(passkeyError.rawValue, passkeyError.rawValue, nil);
          return;
        }
        // Check if the result object contains a valid authentication result
        if let assertionResult = result?.assertionResult {
          // Return a NSDictionary instance with the received authorization data
          let authResult: NSDictionary = [
            "credentialID": assertionResult.credentialID.base64EncodedString(),
            "rawAuthenticatorData": assertionResult.rawAuthenticatorData.base64EncodedString(),
            "rawClientDataJSON": assertionResult.rawClientDataJSON.base64EncodedString(),
            "signature": assertionResult.signature.base64EncodedString(),
            "userID": String(decoding: assertionResult.userID, as: UTF8.self)
          ];
          resolve(authResult);
        } else {
          // If result didn't contain a valid authentication result throw an error
          reject(PassKeyError.requestFailed.rawValue, PassKeyError.requestFailed.rawValue, nil);
        }
      }
      
      if let passKeyDelegate = self.passKeyDelegate {
        // Perform the authorization request
        passKeyDelegate.performAuthForController(controller: authController);
      }
    } else {
      // If Passkeys are not supported throw an error
      reject(PassKeyError.notSupported.rawValue, PassKeyError.notSupported.rawValue, nil);
    }
  }
  
  // Handles ASAuthorization error codes
  func handleErrorCode(error: Error) -> PassKeyError {
    let errorCode = (error as NSError).code;
    switch errorCode {
      case 1001:
        return PassKeyError.cancelled;
      case 4004:
        return PassKeyError.notConfigured;
      default:
        return PassKeyError.unknown;
    }
  }
}

enum PassKeyError: String, Error {
  case notSupported = "NotSupported"
  case requestFailed = "RequestFailed"
  case cancelled = "UserCancelled"
  case invalidChallenge = "InvalidChallenge"
  case notConfigured = "NotConfigured"
  case unknown = "UnknownError"
}

struct AuthRegistrationResult {
  var passkey: PassKeyRegistrationResult
  var type: PasskeyOperation
}

struct AuthAssertionResult {
  var passkey: PassKeyAssertionResult
  var type: PasskeyOperation
}

struct PassKeyResult {
  var registrationResult: PassKeyRegistrationResult?
  var assertionResult: PassKeyAssertionResult?
}

struct PassKeyRegistrationResult {
  var credentialID: Data
  var rawAttestationObject: Data
  var rawClientDataJSON: Data
}

struct PassKeyAssertionResult {
  var credentialID: Data
  var rawAuthenticatorData: Data
  var rawClientDataJSON: Data
  var signature: Data
  var userID: Data
}

enum PasskeyOperation {
  case Registration
  case Assertion
}
