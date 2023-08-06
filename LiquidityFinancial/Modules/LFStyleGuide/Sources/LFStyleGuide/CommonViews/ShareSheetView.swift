import Foundation
import SwiftUI
import UIKit

public struct ShareSheetView: UIViewControllerRepresentable {
  public typealias Callback = (_ activityType: UIActivity.ActivityType?, _ completed: Bool, _ returnedItems: [Any]?, _ error: Error?) -> Void

  private var activityItems: [Any]
  private var applicationActivities: [UIActivity]?
  private var excludedActivityTypes: [UIActivity.ActivityType]?
  private var callback: Callback?
    
  public init(activityItems: [Any], applicationActivities: [UIActivity]? = nil, excludedActivityTypes: [UIActivity.ActivityType]? = nil, callback: Callback? = nil) {
    self.activityItems = activityItems
    self.applicationActivities = applicationActivities
    self.excludedActivityTypes = excludedActivityTypes
    self.callback = callback
  }
  
  
  public func makeUIViewController(context _: Context) -> UIActivityViewController {
    let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    controller.excludedActivityTypes = excludedActivityTypes
    controller.completionWithItemsHandler = callback
    return controller
  }
  
  public func updateUIViewController(_: UIActivityViewController, context _: Context) {}
}
