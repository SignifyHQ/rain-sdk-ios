import Foundation

// swiftlint: disable all
public struct APINSJwkToken: Decodable {
  public let jwks: [APINSJwkToken.Jwk]
  
  var rawData: [[String: String]] {
    var jwt: [[String: String]] = .init()
    jwks.forEach { token in
      jwt.append(token.dict)
    }
    return jwt
  }
  
  public struct Jwk: Decodable {
    let kty, use, alg, kid: String
    let n, e: String
    
    var dict: [String: String] {
      [
        "kty": kty,
        "use": use,
        "alg": alg,
        "kid": kid,
        "n": n,
        "e": e
      ]
    }
  }
}
