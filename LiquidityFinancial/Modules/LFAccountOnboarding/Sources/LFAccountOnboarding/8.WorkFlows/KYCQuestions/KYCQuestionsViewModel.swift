import SwiftUI

@MainActor
public final class KYCQuestionsViewModel: ObservableObject {

  @Published var questionList: KYCQuestion = KYCQuestion.mockKYCQuestion
  
  public init() {}
  
  func updateAnswerSelect(questionID: String, answerID: String) {
    let question = questionList.questions.first(where: { $0.id == questionID })
    question?.answer.forEach({ $0.isSelect = false })
    let answer = question?.answer.first(where: { $0.answerId == answerID })
    answer?.isSelect = true
    self.objectWillChange.send()
  }
  
}
