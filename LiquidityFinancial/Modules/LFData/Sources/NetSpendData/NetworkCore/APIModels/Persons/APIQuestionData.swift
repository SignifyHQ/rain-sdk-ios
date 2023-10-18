import Foundation
import LFUtilities
import NetspendSdk
import NetworkUtilities
import BankDomain

public struct APIQuestionData: Decodable, QuestionDataEntiy {
  public let encryptedData: String?
  
  public func decodeData(session: NetspendSdkUserSession) -> NetSpendQuestionDataDecode? {
    guard let encryptedData = encryptedData else { return nil }
    guard let jsonStr = try? session.decryptWithJWKSet(value: encryptedData).jsonString else { return nil }
    let obj = try? NetSpendQuestionDataDecode(jsonStr)
    return obj
  }
}

public struct NetSpendQuestionDataDecode: Codable {
  public let questions: [NSQuestion]
  
  init(data: Data) throws {
    self = try JSONDecoder().decode(NetSpendQuestionDataDecode.self, from: data)
  }
  
  init(_ json: String, using encoding: String.Encoding = .utf8) throws {
    guard let data = json.data(using: encoding) else {
      throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
    }
    try self.init(data: data)
  }
}

public struct NSQuestion: Codable {
  public let question, id: String
  public let answerOptions: [NSAnswerOption]
  
  enum CodingKeys: String, CodingKey {
    case question = "question"
    case id = "id"
    case answerOptions = "answer_options"
  }
}

public struct NSAnswerOption: Codable {
  public let answerId: String
  public let text: String
  
  enum CodingKeys: String, CodingKey {
    case text = "text"
    case answerId = "answer_id"
  }
}
