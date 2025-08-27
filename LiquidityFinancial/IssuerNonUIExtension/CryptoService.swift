import Foundation
import CryptoSwift
import CryptoKit
//import CommonCrypto

public struct CryptoService {
  static let shared = CryptoService()
  
  private var publicKey: SecKey?
  private var secretKeyBase64: String?
  
  init() {
    self.publicKey = getPublicKey()
    self.secretKeyBase64 = generateSecretKeyBase64()
  }
}

// MARK: - Public Functions
public extension CryptoService {
  func generateSessionId() -> String {
    guard let publicKey, let secretKeyBase64 else {
      return ""
    }
    
    guard let encryptedSecret = SecKeyCreateEncryptedData(
      publicKey, .rsaEncryptionOAEPSHA1, secretKeyBase64.data(using: .utf8)! as CFData, nil
    ) else {
      return ""
    }
    return (encryptedSecret as Data).base64EncodedString()
  }
}

// MARK: - Private Functions
private extension CryptoService {
  func getPublicKey() -> SecKey? {
    var publicKeyString = "-----BEGIN PUBLIC KEY-----MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCeZ9uCoxi2XvOw1VmvVLo88TLkGE+OO1j3fa8HhYlJZZ7CCIAsaCorrU+ZpD5PUTnmME3DJk+JyY1BB3p8XI+C5unoQucrbxFbkM1lgR10ewz/LcuhleG0mrXL/bzUZbeJqI6v3c9bXvLPKlsordPanYBGFZkmBPxc8QEdRgH4awIDAQAB-----END PUBLIC KEY-----"
    
    // Extracting the public key string from its header and footer
    let publicKeyBytes = publicKeyString
      .replacingOccurrences(of: "-----BEGIN PUBLIC KEY-----", with: "")
      .replacingOccurrences(of: "-----END PUBLIC KEY-----", with: "")
      .replacingOccurrences(of: "\n", with: "")
      .trimmingCharacters(in: .whitespacesAndNewlines)
    
    guard let publicKeyData = Data(base64Encoded: publicKeyBytes) else {
      return nil
    }
    
    let keyDict: [CFString: Any] = [
      kSecAttrKeyType: kSecAttrKeyTypeRSA,
      kSecAttrKeyClass: kSecAttrKeyClassPublic,
      kSecAttrKeySizeInBits: 2048
    ]
    guard let publicKey = SecKeyCreateWithData(publicKeyData as CFData, keyDict as CFDictionary, nil) else {
      return nil
    }
    return publicKey
  }
  
  func generateSecretKeyBase64() -> String? {
    // Generate a random secret
    let secret = Data(count: 16)
    // Copy the contents of 'secret' to a local variable
    var secretCopy = secret
    let result = secretCopy.withUnsafeMutableBytes { mutableBytes -> Int32 in
      guard let baseAddress = mutableBytes.baseAddress else { return -1 }
      return SecRandomCopyBytes(kSecRandomDefault, secret.count, baseAddress)
    }
    
    guard result == errSecSuccess else {
      return nil
    }
    
    return secretCopy.base64EncodedString()
  }
}
