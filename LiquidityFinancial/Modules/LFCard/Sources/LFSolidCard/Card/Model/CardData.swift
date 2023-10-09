import Foundation

public struct CardData {
  public var cards: [CardModel]
  public var metaDatas: [CardMetaData?]
  public var loading: Bool
  
  public init(cards: [CardModel], metaDatas: [CardMetaData?], loading: Bool) {
    self.cards = cards
    self.metaDatas = metaDatas
    self.loading = loading
  }
}
