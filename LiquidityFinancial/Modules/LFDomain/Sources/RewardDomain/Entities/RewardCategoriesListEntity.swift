import Foundation

public protocol RewardCategoriesListEntity {
  var total: Int { get }
  var data: [RewardCategoriesEntity] { get }
}

public protocol RewardCategoriesEntity {
  var id: String? { get }
  var productId: String? { get }
  var name: String? { get }
  var description: String? { get }
  var logoUrl: String? { get }
  var rank: Int? { get }
}
