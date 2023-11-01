import Foundation
import LFUtilities
import NetspendSdk
import NetworkUtilities

public struct AnswerQuestionParameters: Parameterable {
  
  public let answers: [Answers]
  
  public init(answers: [Answers]) {
    self.answers = answers
  }
  
  public struct Answers: Codable {
    public let questionId: String
    public let answerId: String
    
    public init(questionId: String, answerId: String) {
      self.questionId = questionId
      self.answerId = answerId
    }
    
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
