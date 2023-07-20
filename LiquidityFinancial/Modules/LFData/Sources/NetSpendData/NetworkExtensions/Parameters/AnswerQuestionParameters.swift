import Foundation
import LFUtilities
import NetspendSdk
import DataUtilities

public struct AnswerQuestionParameters: Parameterable {
  
  public let answers: [Answers]
  
  public struct Answers: Codable {
    public let questionId: String
    public let answerId: String
    
    enum CodingKeys: String, CodingKey {
      case questionId = "question_id"
      case answerId = "answer_id"
    }
  }
  
  public func encodeObj(session: NetspendSdkUserSession) -> String {
    let obj = try? session.encryptWithJWKSet(value: self.encoded())
    return obj ?? ""
  }
  
}
