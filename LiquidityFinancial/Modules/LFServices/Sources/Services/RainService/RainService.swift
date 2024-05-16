import Foundation
import CryptoSwift
import EnvironmentService
import Factory
import LFUtilities
import CryptoKit
import CommonCrypto

public class RainService: RainServiceProtocol {
  @LazyInjected(\.environmentService) var environmentService
  
  private var publicKey: SecKey?
  private var secretKeyBase64: String?
  
  init() {
    self.publicKey = getPublicKey()
    self.secretKeyBase64 = generateSecretKeyBase64()
  }
}

// MARK: - Public Functions
public extension RainService {
  func generateSessionId() -> String {
    guard let publicKey, let secretKeyBase64 else {
      return .empty
    }
    
    guard let encryptedSecret = SecKeyCreateEncryptedData(
      publicKey, .rsaEncryptionOAEPSHA1, secretKeyBase64.data(using: .utf8)! as CFData, nil
    ) else {
      return .empty
    }
    return (encryptedSecret as Data).base64EncodedString()
  }
  
  func decryptData(ivBase64: String, dataBase64: String) -> String {
    guard let secretKeyBase64,
          let secretKeyData = Data(base64Encoded: secretKeyBase64),
          let ivData = Data(base64Encoded: ivBase64),
          let data = Data(base64Encoded: dataBase64) else {
      log.error("Failed to decode base64 strings")
      return .empty
    }
    
    let authTagLength = 16 // Authentication tag length for AES-GCM
    let encryptedData = data.prefix(upTo: data.count - authTagLength)
    let authTag = data.suffix(from: data.count - authTagLength)
    
    do {
      let symmetricKey = SymmetricKey(data: secretKeyData)
      let sealedBox = try AES.GCM.SealedBox(nonce: AES.GCM.Nonce(data: ivData), ciphertext: encryptedData, tag: authTag)
      let decryptedData = try AES.GCM.open(sealedBox, using: symmetricKey)
      
      return String(decoding: decryptedData, as: UTF8.self)
    } catch {
      log.error("Failed to decrypt data: \(error)")
      return .empty
    }
  }
}

// MARK: - Private Functions
private extension RainService {
  func getPublicKey() -> SecKey? {
    let publicKeyString = environmentService.networkEnvironment == .productionLive
    ? Configs.RainConfig.prodPublicKey
    : Configs.RainConfig.devPublicKey
    
    // Extracting the public key string from its header and footer
    let publicKeyBytes = publicKeyString
      .replace(string: "-----BEGIN PUBLIC KEY-----", replacement: .empty)
      .replace(string: "-----END PUBLIC KEY-----", replacement: .empty)
      .replace(string: "\n", replacement: .empty)
      .trimWhitespacesAndNewlines()
    
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
