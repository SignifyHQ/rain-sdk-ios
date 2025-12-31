import Foundation
import LFLocalizable
import LFUtilities

struct CardMetaData: Equatable, Hashable {
  let pan: String
  let cvv: String
  let processorCardId: String
  let timeBasedSecret: String
  
  var panFormatted: String {
    pan.insertSpaces(afterEvery: 4)
  }
  
  init(
    pan: String,
    cvv: String,
    processorCardId: String,
    timeBasedSecret: String
  ) {
    self.pan = pan
    self.cvv = cvv
    self.processorCardId = processorCardId
    self.timeBasedSecret = timeBasedSecret
  }
}
