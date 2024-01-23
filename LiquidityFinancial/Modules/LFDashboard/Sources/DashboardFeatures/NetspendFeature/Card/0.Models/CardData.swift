import Foundation

struct CardData {
  var cards: [CardModel]
  var metaDatas: [CardMetaData?]
  var loading: Bool
  
  init(cards: [CardModel], metaDatas: [CardMetaData?], loading: Bool) {
    self.cards = cards
    self.metaDatas = metaDatas
    self.loading = loading
  }
}
