import Foundation

public protocol ContributionListEntity {
  var total: Int { get }
  var data: [ContributionEntity] { get }
}

public protocol ContributionEntity {
  var id: String? { get }
  var title: String? { get }
  var fundraiserId: String? { get }
  var userId: String? { get }
  var userName: String? { get }
  var stickerUrl: String? { get }
  var status: String? { get }
  var createdAt: String? { get }
  var amount: Double? { get }
}
