import Foundation
import RewardData
import RewardDomain

// swiftlint:disable all
extension StickerModel {
  static func mock(name: String = "Example Sticker",
                   url: URL? = .init(string: "https://i.ibb.co/8mVdtS1/avatar-3.png"),
                   count: Int? = nil) -> Self
  {
    .init(
      id: UUID().uuidString,
      name: name,
      url: url,
      count: count,
      backgroundColor: nil,
      charityName: nil
    )
  }
}

extension CauseModel {
  static var mock: Self {
    .init(id: "1", productId: "", name: "LGBTQIA+", logoUrl: .init(string: "https://i.ibb.co/xgZpnSj/lgbtq.png"), rank: 1)
  }
  
  static var mockList: [Self] = [
    .init(id: "1", productId: "", name: "LGBTQIA+", logoUrl: .init(string: "https://i.ibb.co/xgZpnSj/lgbtq.png"), rank: 1),
    .init(id: "2", productId: "", name: "Reproductive rights", logoUrl: .init(string: "https://i.ibb.co/xgZpnSj/lgbtq.png"), rank: 4),
    .init(id: "3", productId: "", name: "Veterans", logoUrl: .init(string: "https://i.ibb.co/xgZpnSj/lgbtq.png"), rank: 3),
    .init(id: "4", productId: "", name: "Improving education", logoUrl: .init(string: "https://i.ibb.co/xgZpnSj/lgbtq.png"), rank: 2),
  ]
  
  static func mockList(count: Int) -> [Self] {
    var result: [Self] = []
    for index in 0 ..< count {
      result.append(.init(id: "\(index)", productId: "", name: "LGBTQIA+", logoUrl: .init(string: "https://i.ibb.co/xgZpnSj/lgbtq.png"), rank: 1))
    }
    return result
  }
}
