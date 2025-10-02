import AuthenticationServices

@available(iOS 15.0, *)
struct RNPasskeyHandler {
  var resolve: RCTPromiseResolveBlock
  var reject: RCTPromiseRejectBlock
  
  init(_ resolve: @escaping RCTPromiseResolveBlock, _ reject: @escaping RCTPromiseRejectBlock) {
    self.resolve = resolve
    self.reject = reject
  }
}

@objc(Passkey)
@available(iOS 15.0, *)
class Passkey: NSObject, RNPasskeyResultHandler {
  var passkeyDelegate: PasskeyDelegate?;
  var passkeyHandler: RNPasskeyHandler?;

  /**
   Main create entrypoint
   */
  @objc(create:withForcePlatformKey:withForceSecurityKey:withResolver:withRejecter:)
  func create(_ request: String, forcePlatformKey: Bool, forceSecurityKey: Bool, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) -> Void {
    do {
      passkeyHandler = RNPasskeyHandler(resolve, reject);
      
      // Decode request object
      let requestData = request.data(using: .utf8)!;
      let requestJSON = try JSONDecoder().decode(RNPasskeyCredentialCreationOptions.self, from: requestData);
      
      // Convert challenge to Data
      guard let challenge: Data = Data(base64URLEncoded: requestJSON.challenge) else {
        handleError(RNPasskeyError(type: .invalidChallenge));
        return;
      }
      
      // Convert userId to Data
      guard let userId: Data = requestJSON.user.id.data(using: .utf8) else {
        handleError(RNPasskeyError(type: .invalidUser));
        return;
      }
      
      // Create requests
      let platformKeyRequest: ASAuthorizationRequest = try self.configureCreatePlatformRequest(challenge: challenge, userId: userId, request: requestJSON);
      let securityKeyRequest: ASAuthorizationRequest = self.configureCreateSecurityKeyRequest(challenge: challenge, userId: userId, request: requestJSON);
        
      // Get authorization controller
      let authController: ASAuthorizationController = self.configureAuthController(forcePlatformKey: forcePlatformKey, forceSecurityKey: forceSecurityKey, platformKeyRequest: platformKeyRequest, securityKeyRequest: securityKeyRequest);

      let passkeyDelegate = PasskeyDelegate(completionHandler: self);
      
      // Keep a reference to the delegate object
      self.passkeyDelegate = passkeyDelegate;
      
      // Perform the authorization
      passkeyDelegate.performAuthForController(controller: authController);

    } catch let error as NSError {
      handleError(handleErrorCode(error: error));
    }
  }

  /**
   Main get entrypoint
   */
  @objc(get:withForcePlatformKey:withForceSecurityKey:withResolver:withRejecter:)
  func get(_ request: String, forcePlatformKey: Bool, forceSecurityKey: Bool, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) -> Void {
    do {
      passkeyHandler = RNPasskeyHandler(resolve, reject);
      
      // Decode request object
      let requestData = request.data(using: .utf8)!;
      let requestJSON = try JSONDecoder().decode(RNPasskeyCredentialRequestOptions.self, from: requestData);
      
      // Convert challenge to Data
      guard let challenge: Data = Data(base64URLEncoded: requestJSON.challenge) else {
        handleError(RNPasskeyError(type: .invalidChallenge));
        return;
      }
      
      let platformKeyRequest: ASAuthorizationRequest = try self.configureGetPlatformRequest(challenge: challenge, request: requestJSON);
      let securityKeyRequest: ASAuthorizationRequest = self.configureGetSecurityKeyRequest(challenge: challenge, request: requestJSON);
      
      // Get authorization controller
      let authController: ASAuthorizationController = self.configureAuthController(forcePlatformKey: forcePlatformKey, forceSecurityKey: forceSecurityKey, platformKeyRequest: platformKeyRequest, securityKeyRequest: securityKeyRequest);
      
      let passkeyDelegate = PasskeyDelegate(completionHandler: self);
      
      // Keep a reference to the delegate object
      self.passkeyDelegate = passkeyDelegate;

      // Perform the authorization
      passkeyDelegate.performAuthForController(controller: authController);
      
    } catch let error as NSError {
      reject(error.debugDescription, error.debugDescription, nil);
    }
  }
  
  func onSuccess(_ data: PublicKeyCredentialJSON) {
    guard let handler = passkeyHandler else {
      print("passkeyHandler was nil");
      return
    }
    
    do {
      switch data {
      case .create(let createResponse):
        let data = try JSONEncoder().encode(createResponse);
        handler.resolve(try JSONSerialization.jsonObject(with: data));
        return
      case .get(let getResponse):
        let data = try JSONEncoder().encode(getResponse);
        handler.resolve(try JSONSerialization.jsonObject(with: data));
      }
    } catch let error as NSError {
      handler.reject(error.debugDescription, error.debugDescription, nil);
    }
  }
  
  func onError(_ error: any Error) {
    handleError(handleErrorCode(error: error));
  }
  
  /**
   Creates and returns security key create request
   */
  private func configureCreateSecurityKeyRequest(challenge: Data, userId: Data, request: RNPasskeyCredentialCreationOptions) -> ASAuthorizationSecurityKeyPublicKeyCredentialRegistrationRequest {
    
    let securityKeyProvider = ASAuthorizationSecurityKeyPublicKeyCredentialProvider(relyingPartyIdentifier: request.rp.id!);

    let authRequest = securityKeyProvider.createCredentialRegistrationRequest(challenge: challenge, 
                                                                              displayName: request.user.displayName,
                                                                              name: request.user.name,
                                                                              userID: userId);
    
    authRequest.credentialParameters = request.pubKeyCredParams.map({ $0.appleise() })
    if #available(iOS 17.4, *) {
      if let excludeCredentials = request.excludeCredentials {
        authRequest.excludedCredentials = excludeCredentials.map({ $0.getCrossPlatformDescriptor() })
      }
    }
    
    if let residentCredPref = request.authenticatorSelection?.residentKey {
      authRequest.residentKeyPreference = residentCredPref.appleise()
    }
    
    if let userVerificationPref = request.authenticatorSelection?.userVerification {
      authRequest.userVerificationPreference = userVerificationPref.appleise()
    }
    
    if let rpAttestationPref = request.attestation {
      authRequest.attestationPreference = rpAttestationPref.appleise()
    }
    
    return authRequest;
  }
  
  /**
   Creates and returns platform key create request
   */
  private func configureCreatePlatformRequest(challenge: Data, userId: Data, request: RNPasskeyCredentialCreationOptions) throws -> ASAuthorizationPlatformPublicKeyCredentialRegistrationRequest {

    let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: request.rp.id!);
    
    let authRequest = platformProvider.createCredentialRegistrationRequest(challenge: challenge, 
                                                                           name: request.user.name,
                                                                           userID: userId);
    
    // LargeBlob Extension
    if #available(iOS 17.0, *) {
      if let largeBlob = request.extensions?.largeBlob {
        authRequest.largeBlob = largeBlob.support?.appleise()
      }
    }
    
    // PRF Extension
    if #available(iOS 18.0, *) {
      if let prf = request.extensions?.prf {
        // If evalByCredential is present at registration we throw an "Unsupported" error as specified in the WebAuthn standard
        if prf.evalByCredential != nil {
          throw NSError(domain: "PRF Unsupported", code: 1)
        }
        
        if let first = prf.eval?.first {
          // If at least the first input value is present we will set it accordingly
          authRequest.prf = .inputValues(ASAuthorizationPublicKeyCredentialPRFRegistrationInput.InputValues(saltInput1: first, saltInput2: prf.eval?.second))
        } else {
          // Otherwise we only enable "shouldCheckForSupport"
          authRequest.prf = .checkForSupport
        }
      }
    }
    
    if #available(iOS 17.4, *) {
      if let excludeCredentials = request.excludeCredentials {
        authRequest.excludedCredentials = excludeCredentials.map({ $0.getPlatformDescriptor() })
      }
    }
    
    if let userVerificationPref = request.authenticatorSelection?.userVerification {
      authRequest.userVerificationPreference = userVerificationPref.appleise()
    }

    return authRequest;
  }
  
  /**
   Creates and returns platform key get request
   */
  private func configureGetPlatformRequest(challenge: Data, request: RNPasskeyCredentialRequestOptions) throws -> ASAuthorizationPlatformPublicKeyCredentialAssertionRequest {
    
    let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: request.rpId);
    let authRequest = platformProvider.createCredentialAssertionRequest(challenge: challenge);
    
    // LargeBlob Extension
    if #available(iOS 17.0, *) {
      if request.extensions?.largeBlob?.read == true {
        authRequest.largeBlob = ASAuthorizationPublicKeyCredentialLargeBlobAssertionInput.read;
      }
      
      if let largeBlobWriteData = request.extensions?.largeBlob?.write {
        authRequest.largeBlob = ASAuthorizationPublicKeyCredentialLargeBlobAssertionInput.write(largeBlobWriteData)
      }
    }
    
    // PRF Extension
    if #available(iOS 18.0, *) {
      if let prf = request.extensions?.prf {
        // Check if evalByCredential is set first
        if prf.evalByCredential != nil {
          // If evalByCredential is present and allowCredentials is empty we throw an "Unsupported" error as specified in the WebAuthn standard

          if let allowCredentials = request.allowCredentials, allowCredentials.isEmpty {
            throw NSError(domain: "PRF Issue", code: 1)
          }
          
          if let inputValues = prf.toPerCredentialInputValues() {
            authRequest.prf = .perCredentialInputValues(inputValues)
          }
        } else if let first = prf.eval?.first {
          // If at least the first input value is present we will set it accordingly
          authRequest.prf = .inputValues(ASAuthorizationPublicKeyCredentialPRFRegistrationInput.InputValues(saltInput1: first, saltInput2: prf.eval?.second))
        }
      }
    }
    
    if let allowCredentials = request.allowCredentials {
      authRequest.allowedCredentials = allowCredentials.map({ $0.getPlatformDescriptor() })
    }
    
    if let userVerificationPref = request.userVerification {
      authRequest.userVerificationPreference = userVerificationPref.appleise()
    }
    
    return authRequest;
  }
  
  /**
   Creates and returns security key get request
   */
  private func configureGetSecurityKeyRequest(challenge: Data, request: RNPasskeyCredentialRequestOptions) -> ASAuthorizationSecurityKeyPublicKeyCredentialAssertionRequest {
    
    let securityKeyProvider = ASAuthorizationSecurityKeyPublicKeyCredentialProvider(relyingPartyIdentifier: request.rpId);
    
    let authRequest = securityKeyProvider.createCredentialAssertionRequest(challenge: challenge);
    
    if let allowCredentials = request.allowCredentials {
      authRequest.allowedCredentials = allowCredentials.map({ $0.getCrossPlatformDescriptor() })
    }
    
    if let userVerificationPref = request.userVerification {
      authRequest.userVerificationPreference = userVerificationPref.appleise()
    }
    
    return authRequest;
  }
  
  /**
   Creates and returns authorization controller depending on selected request types
   */
  private func configureAuthController(forcePlatformKey: Bool, forceSecurityKey: Bool, platformKeyRequest: ASAuthorizationRequest, securityKeyRequest: ASAuthorizationRequest) -> ASAuthorizationController {
    if (forcePlatformKey) {
      return ASAuthorizationController(authorizationRequests: [platformKeyRequest]);
    }
    
    if (forceSecurityKey) {
      return ASAuthorizationController(authorizationRequests: [securityKeyRequest]);
    }

    return ASAuthorizationController(authorizationRequests: [platformKeyRequest, securityKeyRequest]);
  }
  
  /**
   Handles ASAuthorization error codes
  */
  private func handleErrorCode(error: Error) -> RNPasskeyError {
    let errorCode = (error as NSError).code;
    switch errorCode {
      case 1001:
      return RNPasskeyError(type: .cancelled, message: error.localizedDescription);
      case 1004:
      return RNPasskeyError(type: .requestFailed, message: error.localizedDescription);
      case 4004:
      return RNPasskeyError(type: .badConfiguration, message: error.localizedDescription);
      case 31:
      return RNPasskeyError(type: .timedOut, message: error.localizedDescription);
      case 1:
      return RNPasskeyError(type: .notSupported, message: error.localizedDescription);
      default:
      return RNPasskeyError(type: .unknown, message: error.localizedDescription);
    }
  }
  
  private func handleError(_ error: RNPasskeyError) {
    guard let handler = passkeyHandler else {
      print("passkeyHandler was nil");
      return
    }
    
    handler.reject(error.type.rawValue, error.message, nil);
  }
}

