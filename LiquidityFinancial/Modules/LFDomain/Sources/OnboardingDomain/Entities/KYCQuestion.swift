import Foundation

public protocol KYCQuestion {
  var questions: [KYCAnswerOptions] { get }
  var requiredAnswers: Int { get }
}

public protocol KYCAnswerOptions {
  var id: String { get }
  var question: String { get }
  var answer: [KYCAnswer] { get }
}

public protocol KYCAnswer {
  var answerId: String { get }
  var text: String { get }
}
