import Foundation

extension JSONDecoder {
  
  public static let apiDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    return decoder
  }()
  
}
