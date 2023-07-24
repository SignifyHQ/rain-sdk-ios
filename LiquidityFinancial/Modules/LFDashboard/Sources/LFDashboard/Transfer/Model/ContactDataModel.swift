import Foundation

struct ContactDataModel: Codable, Identifiable, Equatable {
  var id: String?
  var accountId: String?
  var ach: ACHAccount?
  var debitCard: DebitCardModel?

  static func == (lhs: ContactDataModel, rhs: ContactDataModel) -> Bool {
    lhs.id == rhs.id
  }
}
