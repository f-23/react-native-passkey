import AuthenticationServices

@objc(Passkey)
@available(iOS 15.0, *)
class Passkey: NSObject {
  var passKeyDelegate: PasskeyDelegate?;

  /**
   Main registration entrypoint
   */
  @objc(register:withPlatformKey:withSecurityKey:withResolver:withRejecter:)
  func register(_ request: String, platformKey: Bool, securityKey: Bool, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) -> Void {
    do {
      // Decode request object
      let requestData = request.data(using: .utf8)!;
      let requestJSON = try JSONDecoder().decode(RNPasskeyRegistrationRequest.self, from: requestData);
      
      // Convert challenge and userId to correct type
      guard let challengeData: Data = Data(base64Encoded: Base64Helper.toBase64(base64URL: requestJSON.challenge)) else {
        reject(RNPasskeyError.invalidChallenge.rawValue, RNPasskeyError.invalidChallenge.rawValue, nil);
        return;
      }
      
      // Set up a PasskeyDelegate instance with a callback function
      self.passKeyDelegate = PasskeyDelegate(completionHandler: { error, result in
        self.registrationCallback(error: error, result: result, resolve: resolve, reject: reject);
      })
      
      if let passKeyDelegate = self.passKeyDelegate {
            // Get authorization requests
        let platformKeyRequest: ASAuthorizationRequest = self.configureRegistrationPlatformRequest(challenge: challengeData, request: requestJSON);
        let securityKeyRequest: ASAuthorizationRequest = self.configureRegistrationSecurityKeyRequest(challenge: challengeData, request: requestJSON);
        
        // Get authorization controller
        let authController: ASAuthorizationController = self.configureAuthController(platformKey: platformKey, platformKeyRequest: platformKeyRequest, securityKey: securityKey, securityKeyRequest: securityKeyRequest);
        
        // Perform the authorization
        passKeyDelegate.performAuthForController(controller: authController);
      }
    } catch let error as NSError {
      reject(error.debugDescription, error.debugDescription, nil);
    }
  }
  
  /**
   Process registration result
   */
  private func registrationCallback(error: Error?, result: RNPasskeyResult?, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) -> Void {
    // Check if authorization process returned an error and throw if thats the case
    if (error != nil) {
      let passkeyError = self.handleErrorCode(error: error!);
      reject(passkeyError, passkeyError, nil);
      return;
    }
    
    // Check if the result object contains a valid registration result
    if let registrationResult = result?.registrationResult {
      // Return a NSDictionary instance with the received authorization data
      let authResponse: NSDictionary = [
        "rawAttestationObject": Base64Helper.toBase64URL(data: registrationResult.rawAttestationObject),
        "rawClientDataJSON": Base64Helper.toBase64URL(data: registrationResult.rawClientDataJSON)
      ];
      
      let authResult: NSDictionary = [
        "transports": registrationResult.transports ?? [],
        "credentialID": Base64Helper.toBase64URL(data: registrationResult.credentialID),
        "response": authResponse,
      ]
      resolve(authResult);
    } else {
      // If result didn't contain a valid registration result throw an error
      reject(RNPasskeyError.requestFailed.rawValue, RNPasskeyError.requestFailed.rawValue, nil);
    }
  }

  /**
   Main authentication entrypoint
   */
  @objc(authenticate:withPlatformKey:withSecurityKey:withResolver:withRejecter:)
  func authenticate(_ request: String, platformKey: Bool, securityKey: Bool, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) -> Void {
    do {
      // Decode request object
      let requestData = request.data(using: .utf8)!;
      let requestJSON = try JSONDecoder().decode(RNPasskeyAuthenticationRequest.self, from: requestData);
      
      // Convert challenge to correct type
      guard let challengeData: Data = Data(base64Encoded: Base64Helper.toBase64(base64URL: requestJSON.challenge)) else {
        reject(RNPasskeyError.invalidChallenge.rawValue, RNPasskeyError.invalidChallenge.rawValue, nil);
        return;
      }
      
      // Set up a PasskeyDelegate instance with a callback function
      self.passKeyDelegate = PasskeyDelegate { error, result in
        self.authenticationCallback(error: error, result: result, resolve: resolve, reject: reject);
      }
      
      if let passKeyDelegate = self.passKeyDelegate {
        // Get authorization requests
        let platformKeyRequest: ASAuthorizationRequest = self.configureAuthenticationPlatformRequest(challenge: challengeData, request: requestJSON);
        let securityKeyRequest: ASAuthorizationRequest = self.configureAuthenticationSecurityKeyRequest(challenge: challengeData, request: requestJSON);
        
        // Get authorization controller
        let authController: ASAuthorizationController = self.configureAuthController(platformKey: platformKey, platformKeyRequest: platformKeyRequest, securityKey: securityKey, securityKeyRequest: securityKeyRequest);
        
        // Perform the authorization
        passKeyDelegate.performAuthForController(controller: authController);
      }
    } catch let error as NSError {
      reject(error.debugDescription, error.debugDescription, nil);
    }
  }
  
  /**
   Process authentication result
   */
  private func authenticationCallback(error: Error?, result: RNPasskeyResult?, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) -> Void {
    // Check if authorization process returned an error and throw if thats the case
    if (error != nil) {
      let passkeyError = self.handleErrorCode(error: error!);
      reject(passkeyError, passkeyError, nil);
      return;
    }
    // Check if the result object contains a valid authentication result
    if let assertionResult = result?.assertionResult {
      // Return a NSDictionary instance with the received authorization data
      let authResponse: NSDictionary = [
        "rawAuthenticatorData": Base64Helper.toBase64URL(data: assertionResult.rawAuthenticatorData),
        "rawClientDataJSON": Base64Helper.toBase64URL(data: assertionResult.rawClientDataJSON),
        "signature": Base64Helper.toBase64URL(data: assertionResult.signature),
      ];
      
      let authResult: NSDictionary = [
        "credentialID": Base64Helper.toBase64URL(data: assertionResult.credentialID),
        "userID": String(decoding: assertionResult.userID, as: UTF8.self),
        "response": authResponse
      ]
      resolve(authResult);
    } else {
      // If result didn't contain a valid authentication result throw an error
      reject(RNPasskeyError.requestFailed.rawValue, RNPasskeyError.requestFailed.rawValue, nil);
    }
  }
  
  /**
   Creates and returns security key registration request
   */
  private func configureRegistrationSecurityKeyRequest(challenge: Data, request: RNPasskeyRegistrationRequest) -> ASAuthorizationSecurityKeyPublicKeyCredentialRegistrationRequest {
    let userIdData: Data = RCTConvert.nsData(request.user.id);
    let securityKeyProvider = ASAuthorizationSecurityKeyPublicKeyCredentialProvider(relyingPartyIdentifier: request.rp.id);

    // Configure auth request
    let authRequest = securityKeyProvider.createCredentialRegistrationRequest(challenge: challenge, displayName: request.user.displayName ?? "", name: request.user.name ?? "", userID: userIdData);
    authRequest.credentialParameters = [ ASAuthorizationPublicKeyCredentialParameters(algorithm: ASCOSEAlgorithmIdentifier.ES256) ];
    authRequest.excludedCredentials = self.transformDescriptorsForSecurityKey(credentials: request.excludeCredentials);
    authRequest.attestationPreference = ASAuthorizationPublicKeyCredentialAttestationKind(request.attestation ?? "none")
    authRequest.residentKeyPreference = ASAuthorizationPublicKeyCredentialResidentKeyPreference(request.authenticatorSelection.residentKey ?? "preferred");
    authRequest.userVerificationPreference = ASAuthorizationPublicKeyCredentialUserVerificationPreference(request.authenticatorSelection.userVerification ?? "preferred");
    
    return authRequest;
  }
  
  /**
   Creates and returns platform key registration request
   */
  private func configureRegistrationPlatformRequest(challenge: Data, request: RNPasskeyRegistrationRequest) -> ASAuthorizationPlatformPublicKeyCredentialRegistrationRequest {
    let userIdData: Data = RCTConvert.nsData(request.user.id);
    let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: request.rp.id);
    
    // Configure auth request
    let authRequest = platformProvider.createCredentialRegistrationRequest(challenge: challenge, name: request.user.name ?? "", userID: userIdData);
    if #available(iOS 17.4, *) {
      authRequest.excludedCredentials = self.transformDescriptorsForPlatform(credentials: request.excludeCredentials)
    }
    authRequest.userVerificationPreference = ASAuthorizationPublicKeyCredentialUserVerificationPreference(request.authenticatorSelection.userVerification ?? "preferred");

    return authRequest;
  }
  
  /**
   Creates and returns security key authentication request
   */
  private func configureAuthenticationSecurityKeyRequest(challenge: Data, request: RNPasskeyAuthenticationRequest) -> ASAuthorizationSecurityKeyPublicKeyCredentialAssertionRequest {
    let securityKeyProvider = ASAuthorizationSecurityKeyPublicKeyCredentialProvider(relyingPartyIdentifier: request.rpId);
    
    // Configure auth request
    let authRequest = securityKeyProvider.createCredentialAssertionRequest(challenge: challenge);
    authRequest.allowedCredentials = self.transformDescriptorsForSecurityKey(credentials: request.allowCredentials);
    if let userVerification = request.userVerification {
      authRequest.userVerificationPreference = ASAuthorizationPublicKeyCredentialUserVerificationPreference(userVerification);
    }
    
    return authRequest;
  }
  
  /**
   Creates and returns platform key authentication request
   */
  private func configureAuthenticationPlatformRequest(challenge: Data, request: RNPasskeyAuthenticationRequest) -> ASAuthorizationPlatformPublicKeyCredentialAssertionRequest {
    let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: request.rpId);
    
    // Configure auth request
    let authRequest = platformProvider.createCredentialAssertionRequest(challenge: challenge);
    authRequest.allowedCredentials = self.transformDescriptorsForPlatform(credentials: request.allowCredentials);
    if let userVerification = request.userVerification {
      authRequest.userVerificationPreference = ASAuthorizationPublicKeyCredentialUserVerificationPreference(userVerification)
    }
    
    return authRequest;
  }
  
  /**
   Creates and returns authorization controller depending on selected request types
   */
  private func configureAuthController(platformKey: Bool, platformKeyRequest: ASAuthorizationRequest, securityKey: Bool, securityKeyRequest: ASAuthorizationRequest) -> ASAuthorizationController {
    // Determine if we show platformKeyRequest, securityKeyRequest, or both
    var authorizationRequests: [ASAuthorizationRequest] = []

    if (platformKey || securityKey) {
      if (platformKey) {
        authorizationRequests.append(platformKeyRequest);
      }
      if (securityKey) {
        authorizationRequests.append(securityKeyRequest);
      }
    } else {
      // Default to platform key request
      authorizationRequests.append(platformKeyRequest);
    }
    
    // Create auth controller
    return ASAuthorizationController(authorizationRequests: authorizationRequests);
  }

  /**
   Turns RN platform key credential descriptors into native Swift credential descriptors
   */
  private func transformDescriptorsForSecurityKey(credentials: [RNPasskeyCredential]?) -> [ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor] {
    guard let credentialsData = credentials else {
      return [];
    }
    
    return credentialsData.compactMap { (credential: RNPasskeyCredential) -> ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor? in
      guard let credId: Data = Data(base64Encoded: credential.id) else {
        return nil;
      }
      
      guard let transportsData = credential.transports else {
        return nil;
      }
      
      let transports: [ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor.Transport] = transportsData.compactMap { transport in
        return ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor.Transport(transport);
      }
      
      return ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor(credentialID: credId, transports: transports);
    }
  }
  
  /**
   Turns RN security key credential descriptors into native Swift credential descriptors
   */
  private func transformDescriptorsForPlatform(credentials: [RNPasskeyCredential]?) -> [ASAuthorizationPlatformPublicKeyCredentialDescriptor] {
    guard let credentialsData = credentials else {
      return [];
    }
    
    return credentialsData.compactMap { credential in
      guard let credId: Data = Data(base64Encoded: credential.id) else {
        return nil;
      }
      
      return ASAuthorizationPlatformPublicKeyCredentialDescriptor(credentialID: credId);
    }
  }
  
  /**
   Handles ASAuthorization error codes
  */
  private func handleErrorCode(error: Error) -> String {
    let errorCode = (error as NSError).code;
    switch errorCode {
      case 1001:
      return RNPasskeyError.cancelled.rawValue;
      case 1004:
      return (error as NSError).localizedDescription;
      case 4004:
      return RNPasskeyError.notConfigured.rawValue;
      case 31:
      return RNPasskeyError.timedOut.rawValue;
      default:
      return RNPasskeyError.unknown.rawValue;
    }
  }
}

/**
 Base64 helper functions
 */
class Base64Helper {
  public static func toBase64URL(base64: String) -> String {
    return base64
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: "=", with: "");
  }
  
  public static func toBase64URL(data: Data) -> String {
    return self.toBase64URL(base64: data.base64EncodedString());
  }
  
  public static func toBase64(base64URL: String) -> String {
    var base64 = base64URL
        .replacingOccurrences(of: "-", with: "+")
        .replacingOccurrences(of: "_", with: "/");
    if base64.count % 4 != 0 {
      base64.append(String(repeating: "=", count: 4 - base64.count % 4));
    }
    return base64;
  }
}

struct RNPasskeyCredential: Decodable {
  var type: String
  var id: String
  var transports: [String]?
}

struct RNPasskeyRelyingParty: Decodable {
  var id: String
}

struct RNPasskeyUser: Decodable {
  var id: String
  var displayName: String?
  var name: String?
}

struct RNPasskeyAuthenticatorSelection: Decodable {
  let residentKey: String?
  let userVerification: String?
  let authenticatorAttachment: String?
  let requireResidentKey: Bool
}

struct RNPasskeyRegistrationRequest: Decodable {
  let challenge: String
  let rp: RNPasskeyRelyingParty
  let user: RNPasskeyUser
  let excludeCredentials: [RNPasskeyCredential]?
  let authenticatorSelection: RNPasskeyAuthenticatorSelection
  let attestation: String?
}

struct RNPasskeyAuthenticationRequest: Decodable {
  let challenge: String
  let rpId: String
  let allowCredentials: [RNPasskeyCredential]?
  let userVerification: String?
}

enum RNPasskeyError: String, Error {
  case notSupported = "NotSupported"
  case requestFailed = "RequestFailed"
  case cancelled = "UserCancelled"
  case invalidChallenge = "InvalidChallenge"
  case invalidCredential = "InvalidCredential"
  case notConfigured = "NotConfigured"
  case timedOut = "TimedOut"
  case unknown = "UnknownError"
}

@available(iOS 15.0, *)
struct RNPasskeyAuthRegistrationResult {
  var passkey: RNPasskeyRegistrationResult
  var type: RNPasskeyOperation
}

struct RNPasskeyAuthAssertionResult {
  var passkey: RNPasskeyAssertionResult
  var type: RNPasskeyOperation
}

@available(iOS 15.0, *)
struct RNPasskeyResult {
  var registrationResult: RNPasskeyRegistrationResult?
  var assertionResult: RNPasskeyAssertionResult?
}

@available(iOS 15.0, *)
struct RNPasskeyRegistrationResult {
  var credentialID: Data
  var rawAttestationObject: Data
  var rawClientDataJSON: Data
  var transports: [ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor.Transport]?
}

struct RNPasskeyAssertionResult {
  var credentialID: Data
  var rawAuthenticatorData: Data
  var rawClientDataJSON: Data
  var signature: Data
  var userID: Data
}

enum RNPasskeyOperation {
  case Registration
  case Assertion
}
