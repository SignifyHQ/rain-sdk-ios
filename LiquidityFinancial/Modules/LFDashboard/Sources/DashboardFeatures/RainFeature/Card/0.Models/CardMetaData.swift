import Foundation
import LFLocalizable
import LFUtilities

struct CardMetaData: Equatable {
  let pan: String
  let cvv: String
  
  var panFormatted: String {
    pan.insertSpaces(afterEvery: 4)
  }
  
  init(pan: String, cvv: String) {
    self.pan = pan
    self.cvv = cvv
  }
}
