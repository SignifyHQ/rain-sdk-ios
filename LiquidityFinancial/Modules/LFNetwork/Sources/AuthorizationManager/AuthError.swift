import Foundation

enum AuthError: Error {
  case missingToken
  case urlInvalid
  case invalidBody
}
