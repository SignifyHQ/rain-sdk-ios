import Foundation

public protocol CategoriesFundraisersListEntity {
  var total: Int { get }
  var data: [CategoriesFundraisersEntity] { get }
}

public protocol CategoriesFundraisersEntity {
  var id: String? { get }
  var name: String? { get }
  var description: String? { get }
  var stickerUrl: String? { get }
  var createdAt: String? { get }
  var goal: Int? { get }
  var currency: String? { get }
  var isFeatured: Bool? { get }
  var isLive: Bool? { get }
  var categories: [String]? { get }
}
