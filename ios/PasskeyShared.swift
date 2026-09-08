import AuthenticationServices
import CryptoKit

typealias Base64URLString = String

enum Either<Create, Get> {
    case create(Create), get(Get)
}

private struct PasskeyBinaryData: Decodable {
  let data: Data

  init(from decoder: any Decoder) throws {
    let value = try decoder.singleValueContainer()
    if let encoded = try? value.decode(String.self) {
      guard let decoded = Data(base64URLEncoded: encoded) else {
        throw DecodingError.dataCorruptedError(in: value, debugDescription: "Invalid base64url binary value")
      }
      data = decoded
    } else if let bytes = try? value.decode([UInt8].self) {
      data = Data(bytes)
    } else {
      let record = try value.decode([String: UInt8].self)
      let indexedBytes = try record.map { key, byte -> (Int, UInt8) in
        guard let index = Int(key), index >= 0 else {
          throw DecodingError.dataCorruptedError(in: value, debugDescription: "Invalid binary byte index")
        }
        return (index, byte)
      }
      data = Data(indexedBytes.sorted { $0.0 < $1.0 }.map { $0.1 })
    }
  }
}

/**
    Specification reference: https://w3c.github.io/webauthn/#enum-transport
*/
@available(iOS 15.0, *)
internal enum AuthenticatorTransport: String, Codable {
    case ble
    case hybrid
    case nfc
    case usb
  
    func appleise() -> [ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor.Transport]? {
        switch self {
        case .ble:
            return [ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor.Transport.bluetooth]
        case .nfc:
            return [ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor.Transport.nfc]
        case .usb:
            return [ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor.Transport.usb]
        default:
          return ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor.Transport.allSupported
        }
    }
}

/**
    Specification reference: https://w3c.github.io/webauthn/#enum-attachment
*/
internal enum AuthenticatorAttachment: String, Codable {
    case platform
  
    // - cross-platform marks that the user wants to select a security key
    case crossPlatform = "cross-platform"
}

/**
    Specification reference: https://w3c.github.io/webauthn/#enum-attestation-convey
*/
@available(iOS 15.0, *)
internal enum AttestationConveyancePreference: String, Decodable {
    case direct
    case enterprise
    case indirect
    case none

    func appleise() -> ASAuthorizationPublicKeyCredentialAttestationKind {
        switch self {
        case .direct:
            return ASAuthorizationPublicKeyCredentialAttestationKind.direct
        case .indirect:
            return ASAuthorizationPublicKeyCredentialAttestationKind.indirect
        case .enterprise:
            return ASAuthorizationPublicKeyCredentialAttestationKind.enterprise
        default:
            return ASAuthorizationPublicKeyCredentialAttestationKind.direct
        }
    }
}

/**
    Specification reference: https://w3c.github.io/webauthn/#enum-credentialType
*/
internal enum PublicKeyCredentialType: String, Codable {
    case publicKey = "public-key"
}

/**
    Specification reference: https://w3c.github.io/webauthn/#enum-userVerificationRequirement
*/
@available(iOS 15.0, *)
internal enum UserVerificationRequirement: String, Codable {
    case discouraged
    case preferred
    case required

    func appleise () -> ASAuthorizationPublicKeyCredentialUserVerificationPreference {
        switch self {
        case .discouraged:
            return ASAuthorizationPublicKeyCredentialUserVerificationPreference.discouraged
        case .preferred:
            return ASAuthorizationPublicKeyCredentialUserVerificationPreference.preferred
        case .required:
            return ASAuthorizationPublicKeyCredentialUserVerificationPreference.required
        default:
            return ASAuthorizationPublicKeyCredentialUserVerificationPreference.preferred
        }
    }
}

/**
    Specification reference: https://w3c.github.io/webauthn/#enum-residentKeyRequirement
*/
@available(iOS 15.0, *)
internal enum ResidentKeyRequirement: String, Decodable {
    case discouraged
    case preferred
    case required

    func appleise() -> ASAuthorizationPublicKeyCredentialResidentKeyPreference {
        switch self {
        case .discouraged:
            return ASAuthorizationPublicKeyCredentialResidentKeyPreference.discouraged
        case .preferred:
            return ASAuthorizationPublicKeyCredentialResidentKeyPreference.preferred
        case .required:
            return ASAuthorizationPublicKeyCredentialResidentKeyPreference.required
        default:
            return ASAuthorizationPublicKeyCredentialResidentKeyPreference.preferred
        }
    }
}

/**
    Specification reference: https://w3c.github.io/webauthn/#enumdef-largeblobsupport
*/
internal enum LargeBlobSupport: String {
    case preferred
    case required
  
  @available(iOS 17.0, *)
  func appleise() -> ASAuthorizationPublicKeyCredentialLargeBlobRegistrationInput? {
      switch self {
      case .preferred:
        return ASAuthorizationPublicKeyCredentialLargeBlobRegistrationInput.supportPreferred
      case .required:
        return ASAuthorizationPublicKeyCredentialLargeBlobRegistrationInput.supportRequired
      default:
          return nil
      }
  }
}

// - Structs

/**
    Specification reference: https://w3c.github.io/webauthn/#dictionary-authenticatorSelection
*/
@available(iOS 15.0, *)
internal struct AuthenticatorSelectionCriteria: Decodable {
  var authenticatorAttachment: AuthenticatorAttachment?
  
  var residentKey: ResidentKeyRequirement?
  
  var requireResidentKey: Bool? = false
  
  var userVerification: UserVerificationRequirement? = UserVerificationRequirement.preferred
  
  enum CodingKeys: String, CodingKey {
    case authenticatorAttachment
    case residentKey
    case requireResidentKey
    case userVerification
  }
  
  // We have to manually decode this
  init(from decoder: any Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    let authenticatorAttachmentValue = try values.decodeIfPresent(String.self, forKey: .authenticatorAttachment)
    if let authenticatorAttachmentString = authenticatorAttachmentValue {
      authenticatorAttachment = AuthenticatorAttachment(rawValue: authenticatorAttachmentString)
    }
    
    let residentKeyValue = try values.decodeIfPresent(String.self, forKey: .residentKey)
    if let residentKeyString = residentKeyValue {
      residentKey = ResidentKeyRequirement(rawValue: residentKeyString)
    }
    
    requireResidentKey = try values .decodeIfPresent(Bool.self, forKey: .requireResidentKey)
    
    let userVerificationValue = try values.decodeIfPresent(String.self, forKey: .userVerification)
    if let userVerificationString = userVerificationValue {
      userVerification = UserVerificationRequirement(rawValue: userVerificationString)
    }
  }
}

/**
    Specification reference: https://w3c.github.io/webauthn/#dictionary-pkcredentialentity
*/
internal struct PublicKeyCredentialEntity: Decodable {
    var name: String
}

/**
    Specification reference: https://w3c.github.io/webauthn/#dictionary-credential-params
*/
@available(iOS 15.0, *)
internal struct PublicKeyCredentialParameters: Decodable {
  var alg: ASCOSEAlgorithmIdentifier = .ES256
  
  var type: PublicKeyCredentialType = .publicKey
  
  func appleise() -> ASAuthorizationPublicKeyCredentialParameters {
    return ASAuthorizationPublicKeyCredentialParameters.init(algorithm: ASCOSEAlgorithmIdentifier(self.alg.rawValue))
  }
  
  enum CodingKeys: String, CodingKey {
    case alg
    case type
  }
  
  // We have to manually decode this
  init(from decoder: any Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    let algValue = try values.decodeIfPresent(Int.self, forKey: .alg)
    if let algInt = algValue {
      alg = ASCOSEAlgorithmIdentifier(algInt)
    }

    let typeValue = try values.decodeIfPresent(String.self, forKey: .type)
    if let typeString = typeValue {
      type = PublicKeyCredentialType(rawValue: typeString) ?? .publicKey
    }
  }
}

/**
    Specification reference: https://w3c.github.io/webauthn/#dictionary-rp-credential-params
*/
internal struct PublicKeyCredentialRpEntity: Decodable {
  
  var name: String
  
  var id: String
}

/**
    Specification reference: https://w3c.github.io/webauthn/#dictdef-publickeycredentialuserentity
*/
internal struct PublicKeyCredentialUserEntity: Decodable {

  var name: String

  var displayName: String

  var id: String
}


/**
    Specification reference: https://w3c.github.io/webauthn/#dictdef-publickeycredentialdescriptor
*/
@available(iOS 15.0, *)
internal struct PublicKeyCredentialDescriptor: Decodable {

  var id: Base64URLString

  var transports: [AuthenticatorTransport]

  private let credentialID: Data

  var type: PublicKeyCredentialType = .publicKey

  func getPlatformDescriptor() -> ASAuthorizationPlatformPublicKeyCredentialDescriptor {
    return ASAuthorizationPlatformPublicKeyCredentialDescriptor.init(credentialID: credentialID)
  }
    
  func getCrossPlatformDescriptor() -> ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor {
    let supportedTransports = transports.flatMap { $0.appleise() ?? [] }
    return ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor.init(credentialID: credentialID,
                                                                        transports: supportedTransports.isEmpty ? ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor.Transport.allSupported : supportedTransports)
  }
  
  enum CodingKeys: String, CodingKey {
    case id
    case transports
    case type
  }
  
  // We have to manually decode this
  init(from decoder: any Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    id = try values.decode(String.self, forKey: .id)
    guard let decodedID = Data(base64URLEncoded: id), !decodedID.isEmpty else {
      throw DecodingError.dataCorruptedError(forKey: .id, in: values, debugDescription: "Invalid base64url credential ID")
    }
    credentialID = decodedID
    
    let transportStrings = try values.decodeIfPresent([String].self, forKey: .transports) ?? []
    transports = transportStrings.compactMap { AuthenticatorTransport(rawValue: $0) }
    
    let typeValue = try values.decodeIfPresent(String.self, forKey: .type)
    if let typeString = typeValue {
      type = PublicKeyCredentialType(rawValue: typeString) ?? .publicKey
    }
  }
}


/**
    Specification reference: https://w3c.github.io/webauthn/#dictdef-authenticationextensionslargeblobinputs
*/
internal struct AuthenticationExtensionsLargeBlobInputs: Decodable {
  // - Only valid during registration.
  var support: LargeBlobSupport?
    
  // - A boolean that indicates that the Relying Party would like to fetch the previously-written blob associated with the asserted credential. Only valid during authentication.
  var read: Bool?
    
  // - An opaque byte string that the Relying Party wishes to store with the existing credential. Only valid during authentication.
  // - We impose that the data is passed as base64-url encoding to make better align the passing of data from RN to native code
  var write: Data?
  
  enum CodingKeys: String, CodingKey {
    case support
    case read
    case write
  }
  
  // We have to manually decode this
  init(from decoder: any Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    let supportValue = try values.decodeIfPresent(String.self, forKey: .support)
    if let supportString = supportValue {
      support = LargeBlobSupport(rawValue: supportString)
    }
    
    read = try values.decodeIfPresent(Bool.self, forKey: .read)
    
    write = try values.decodeIfPresent(PasskeyBinaryData.self, forKey: .write)?.data
  }
}

internal struct AuthenticationExtensionsPRFValues: Encodable, Decodable {
  var first: Data?
  var second: Data?
  
  enum CodingKeys: String, CodingKey {
    case first
    case second
  }
    
  init(from decoder: any Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    first = try values.decodeIfPresent(PasskeyBinaryData.self, forKey: .first)?.data
    second = try values.decodeIfPresent(PasskeyBinaryData.self, forKey: .second)?.data
  }
  
  init(first: SymmetricKey?, second: SymmetricKey?) {
    self.first = first?.serialize()
    self.second = second?.serialize()
  }
  
  init(first: Data?, second: Data?) {
    self.first = first
    self.second = second
  }
  
  @available(iOS 18.0, *)
  func toInputValues() -> ASAuthorizationPublicKeyCredentialPRFAssertionInput.InputValues? {
    if let first = self.first {
      return ASAuthorizationPublicKeyCredentialPRFAssertionInput.InputValues(saltInput1: first, saltInput2: self.second)
    }
    return nil
  }
}

/**
    Specification reference: https://w3c.github.io/webauthn/#dictdef-authenticationextensionsprfinputs
*/
internal struct AuthenticationExtensionsPRFInputs: Decodable {
    
  var eval: AuthenticationExtensionsPRFValues?
    
  // Mapping of credential IDs -> PRFValues
  var evalByCredential: [Data: AuthenticationExtensionsPRFValues]?
    
  enum CodingKeys: String, CodingKey {
      case eval
      case evalByCredential
  }
  
  init(from decoder: any Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    eval = try values.decodeIfPresent(AuthenticationExtensionsPRFValues.self, forKey: .eval)

    if values.contains(.evalByCredential), try !values.decodeNil(forKey: .evalByCredential) {
        let credentialsArray: [[String: AuthenticationExtensionsPRFValues]]
        if let record = try? values.decode([String: AuthenticationExtensionsPRFValues].self, forKey: .evalByCredential) {
          credentialsArray = [record]
        } else {
          credentialsArray = try values.decode([[String: AuthenticationExtensionsPRFValues]].self, forKey: .evalByCredential)
        }
        evalByCredential = [:]
        
        for credentialDict in credentialsArray {
            for (credentialID, prfValues) in credentialDict {
                guard let credentialIDData = Data(base64URLEncoded: credentialID), !credentialIDData.isEmpty else {
                  throw DecodingError.dataCorruptedError(forKey: .evalByCredential, in: values, debugDescription: "Invalid base64url credential ID")
                }
                evalByCredential?[credentialIDData] = prfValues
            }
        }
    }
  }
  
  // Converts the evalByCredential array to correct ASAuthorization type
  @available(iOS 18.0, *)
  func toPerCredentialInputValues() -> [Data: ASAuthorizationPublicKeyCredentialPRFAssertionInput.InputValues]? {
    if let evalByCredential = self.evalByCredential {
      
      var credentialInputValues: [Data: ASAuthorizationPublicKeyCredentialPRFAssertionInput.InputValues] = [:]
      
      for (credentialID, value) in evalByCredential {
        guard let inputValues = value.toInputValues() else {
          continue
        }
        
        credentialInputValues[credentialID] = inputValues
      }
      
      return credentialInputValues
    }
    
    return nil
  }
}


/**
    Specification reference: https://w3c.github.io/webauthn/#dictdef-authenticationextensionsclientinputs
*/
internal struct AuthenticationExtensionsClientInputs: Decodable {
  var largeBlob: AuthenticationExtensionsLargeBlobInputs?
  var prf: AuthenticationExtensionsPRFInputs?
}

// Used for PRF extension
extension SymmetricKey {
    func serialize() -> Data {
        return self.withUnsafeBytes { body in
          Data(body)
        }
    }
}
