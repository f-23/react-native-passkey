require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-passkey"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  # Passkeys need iOS 15+
  s.platform     = :ios, "15.0"

  # When autolinked, CocoaPods will use the local path; the :source is not used.
  s.source       = { :git => "https://github.com/f-23/react-native-passkey.git", :tag => "v#{s.version}" }

  s.source_files  = "ios/**/*.{h,m,mm,swift}"
  s.swift_version = "5.7"
  s.frameworks    = "AuthenticationServices"

  # Let React Native decide/transitively provide React, Folly, glog, etc.
  if defined?(install_modules_dependencies)
    install_modules_dependencies(s)
  else
    # Fallback for RN < 0.71
    s.dependency "React-Core"
    # Do NOT add RCT-Folly / React-Codegen here — older RN brings what it needs transitively.
  end
end
