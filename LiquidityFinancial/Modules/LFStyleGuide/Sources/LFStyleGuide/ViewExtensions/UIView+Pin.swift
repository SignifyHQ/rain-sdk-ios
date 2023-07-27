import Foundation
import UIKit

public enum Edge {
  case top
  case left
  case bottom
  case right
  
  var layoutAttribute: NSLayoutConstraint.Attribute {
    switch self {
    case .top:
      return .top
    case .bottom:
      return .bottom
    case .left:
      return .left
    case .right:
      return .right
    }
  }
}

public extension UIView {
  func pinToSuperviewEdges(withConstant constant: CGFloat = 0) {
    guard let superview = superview else {
      preconditionFailure("view has no superview")
    }
    
    pinTop(to: superview, constant: constant)
    pinBottom(to: superview, constant: constant)
    pinLeft(to: superview, constant: constant)
    pinRight(to: superview, constant: constant)
  }
}

public extension UIView {
  @discardableResult
  func pinTop(
    to view: UIView,
    constant: CGFloat = 0,
    priority: UILayoutPriority = UILayoutPriority.required,
    relatedBy relation: NSLayoutConstraint.Relation = .equal
  ) -> NSLayoutConstraint {
    pin(edge: .top, to: .top, of: view, constant: constant, priority: priority, relatedBy: relation)
  }
  
  @discardableResult
  func pinBottom(
    to view: UIView,
    constant: CGFloat = 0,
    priority: UILayoutPriority = UILayoutPriority.required,
    relatedBy relation: NSLayoutConstraint.Relation = .equal
  ) -> NSLayoutConstraint {
    pin(edge: .bottom, to: .bottom, of: view, constant: constant, priority: priority, relatedBy: relation)
  }
  
  @discardableResult
  func pinLeft(
    to view: UIView,
    constant: CGFloat = 0,
    priority: UILayoutPriority = UILayoutPriority.required,
    relatedBy relation: NSLayoutConstraint.Relation = .equal
  ) -> NSLayoutConstraint {
    pin(edge: .left, to: .left, of: view, constant: constant, priority: priority, relatedBy: relation)
  }
  
  @discardableResult
  func pinRight(
    to view: UIView,
    constant: CGFloat = 0,
    priority: UILayoutPriority = UILayoutPriority.required,
    relatedBy relation: NSLayoutConstraint.Relation = .equal
  ) -> NSLayoutConstraint {
    pin(edge: .right, to: .right, of: view, constant: constant, priority: priority, relatedBy: relation)
  }
  
  func pinEdges(to view: UIView) {
    pin(edge: .left, to: .left, of: view)
    pin(edge: .right, to: .right, of: view)
    pin(edge: .top, to: .top, of: view)
    pin(edge: .bottom, to: .bottom, of: view)
  }
  
  @discardableResult
  func pin(
    edge: Edge,
    to otherEdge: Edge,
    of view: UIView,
    constant: CGFloat = 0,
    priority: UILayoutPriority = UILayoutPriority.required,
    relatedBy relation: NSLayoutConstraint.Relation = .equal
  ) -> NSLayoutConstraint {
    guard let superview = superview else {
      preconditionFailure("view has no superview")
    }
    
    translatesAutoresizingMaskIntoConstraints = false
    if view !== superview {
      view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    let constraint = NSLayoutConstraint(
      item: self,
      attribute: edge.layoutAttribute,
      relatedBy: relation,
      toItem: view,
      attribute: otherEdge.layoutAttribute,
      multiplier: 1,
      constant: constant
    )
    constraint.priority = priority
    superview.addConstraint(constraint)
    return constraint
  }
}
