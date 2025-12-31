import SwiftUICore

extension EdgeInsets {
  static public let zero: EdgeInsets = .init()
  
  static public func vertical(_ value: CGFloat) -> EdgeInsets {
    EdgeInsets(top: value, leading: 0, bottom: value, trailing: 0)
  }
  
  static public func horizontal(_ value: CGFloat) -> EdgeInsets {
    EdgeInsets(top: 0, leading: value, bottom: 0, trailing: value)
  }
  
  static public func leading(_ value: CGFloat) -> EdgeInsets {
    EdgeInsets(top: 0, leading: value, bottom: 0, trailing: 0)
  }
  
  static public func trailing(_ value: CGFloat) -> EdgeInsets {
    EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: value)
  }
  
  static public func top(_ value: CGFloat) -> EdgeInsets {
    EdgeInsets(top: value, leading: 0, bottom: 0, trailing: 0)
  }
  
  static public func bottom(_ value: CGFloat) -> EdgeInsets {
    EdgeInsets(top: 0, leading: 0, bottom: value, trailing: 0)
  }
  
  static public func all(_ value: CGFloat) -> EdgeInsets {
    EdgeInsets(top: value, leading: value, bottom: value, trailing: value)
  }
}
