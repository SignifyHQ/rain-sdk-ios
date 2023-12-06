import Foundation
import UIKit
import SafariServices
import SwiftUI

public struct SFSafariViewWrapper: UIViewControllerRepresentable {
  let url: URL
  public init(url: URL) {
    self.url = url
  }
  
  public func makeUIViewController(context: UIViewControllerRepresentableContext<Self>) -> SFSafariViewController {
    return SFSafariViewController(url: url)
  }
  
  public func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SFSafariViewWrapper>) {
    return
  }
}
