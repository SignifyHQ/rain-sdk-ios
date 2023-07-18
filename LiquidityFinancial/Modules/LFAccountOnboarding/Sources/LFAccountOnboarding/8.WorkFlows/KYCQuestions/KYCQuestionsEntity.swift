import Foundation

class KYCQuestion {
  let id: UUID = UUID()
  var questions: [AnswerOptions]
  var requiredAnswers: Int
 
  init(questions: [AnswerOptions], requiredAnswers: Int) {
    self.questions = questions
    self.requiredAnswers = requiredAnswers
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
  
  static var mockKYCQuestion = KYCQuestion(
    questions: [
      AnswerOptions(id: "340b1782-4c49-4697-bde1-d84f9dc159d5", question: "From whom did you purchase the property at 222333 PEACHTREE PLACE?", answer: [
        Answer(isSelect: true, answerId: "9a02ebb0-7686-4b96-af09-dd896c856240", text: "CHRIS THOMAS"),
        Answer(answerId: "c67376f2-61d4-4d71-b486-36cbb328b8b3", text: "A VIRAY"),
        Answer(answerId: "1581f563-95ed-4129-b1f5-5bc508ad975c", text: "JOE ANDERSON"),
        Answer(answerId: "898cde6c-910f-4394-81d5-f5c97e386197", text: "None of the above")
      ]),
      AnswerOptions(id: "5f6f67b6-8df8-40d6-85ec-1ecc5702ef46", question: "At which of the following addresses have you lived?", answer: [
        Answer(isSelect: true, answerId: "b130ac68-a4ab-4682-ace3-26f000cc0e3a", text: "1084 BPEACHTREE CT"),
        Answer(answerId: "cc2b2e00-cd10-43e0-a989-4de6bf1c4cd9", text: "510 ADAMS RD"),
        Answer(answerId: "019069eb-307e-453b-8174-1547fa856f44", text: "3 CRESSING CT"),
        Answer(answerId: "898cde6c-910f-4394-81d5-f5c97e386197", text: "None of the above")
      ]),
      AnswerOptions(id: "d3f86196-59f3-4b00-a188-e62c2ee05068", question: "What type of residence is 222333 PEACHTREE PLACE?", answer: [
        Answer(isSelect: true, answerId: "ad500453-c1ea-420b-9f05-c3b61ff07b52", text: "Townhome"),
        Answer(answerId: "1ee4248f-b51c-4025-ac79-38b969f5379d", text: "Single Family Residence"),
        Answer(answerId: "8bf6dd1e-fd24-49ee-857a-e47715dfff04", text: "Apartment"),
        Answer(answerId: "898cde6c-910f-4394-81d5-f5c97e386197", text: "None of the above")
      ])
    ],
    requiredAnswers: 3
  )
}
