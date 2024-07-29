struct RNPasskeyError {
  var type: RNPasskeyErrorType
  
  var message: String?
}

enum RNPasskeyErrorType: String {
  
  case notSupported = "NotSupported"
  
  case requestFailed = "RequestFailed"
  
  case cancelled = "UserCancelled"
  
  case invalidChallenge = "InvalidChallenge"
  
  case invalidUser = "InvalidUser"
  
  case badConfiguration = "BadConfiguration"
  
  case timedOut = "TimedOut"
  
  case HandlerUndefined = "HandlerUndefined"
  
  case unknown = "UnknownError"
  
}
