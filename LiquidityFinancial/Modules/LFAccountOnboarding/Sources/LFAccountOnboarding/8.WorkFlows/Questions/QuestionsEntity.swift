import Foundation
import NetSpendData

class QuestionsEntity {
  let id: UUID = UUID()
  var questions: [AnswerOptions]
 
  init(questions: [AnswerOptions]) {
    self.questions = questions
  }
  
  class AnswerOptions {
    var id: String
    var question: String
    var answer: [Answer]
    
    init(id: String, question: String, answer: [Answer]) {
      self.id = id
      self.question = question
      self.answer = answer
    }
  }
  
  class Answer {
    var isSelect: Bool = false
    var answerId: String
    var text: String
    
    init(isSelect: Bool = false, answerId: String, text: String) {
      self.isSelect = isSelect
      self.answerId = answerId
      self.text = text
    }
    
    func toggle() {
      self.isSelect.toggle()
    }
  }
  
  static func mapObj(_ obj: NetSpendQuestionDataDecode) -> QuestionsEntity {
    var questions: [AnswerOptions] = []
    obj.questions.forEach { question in
      questions.append(
        AnswerOptions(id: question.id, question: question.question, answer: question.answerOptions.compactMap { Answer(answerId: $0.answerId, text: $0.text) })
      )
    }
    return QuestionsEntity(questions: questions)
  }
  
  
}
