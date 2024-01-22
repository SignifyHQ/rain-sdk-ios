import Foundation
import LFLocalizable
import LFUtilities

public struct CardMetaData: Equatable {
  public let pan: String
  public let cvv: String
  
  public var panFormatted: String {
    pan.insertSpaces(afterEvery: 4)
  }
  
  public init(pan: String, cvv: String) {
    self.pan = pan
    self.cvv = cvv
  }
}
