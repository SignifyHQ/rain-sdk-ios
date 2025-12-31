import MessageUI
import SwiftUI
import UIKit

public struct MailView: UIViewControllerRepresentable {
  @Environment(\.dismiss) var dismiss
  @Binding var result: Result<MFMailComposeResult, Error>?
  var configure: ((MFMailComposeViewController) -> Void)?
  
  public init(
    result: Binding<Result<MFMailComposeResult, Error>?>,
    configure: @escaping ((MFMailComposeViewController) -> Void)
  ) {
    _result = result
    self.configure = configure
  }
  
  public func makeCoordinator() -> Coordinator {
    Coordinator(dismiss: dismiss, result: $result)
  }
  
  public func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
    let viewController = MFMailComposeViewController()
    viewController.mailComposeDelegate = context.coordinator
    configure?(viewController)
    return viewController
  }
  
  public func updateUIViewController(
    _: MFMailComposeViewController,
    context _: UIViewControllerRepresentableContext<MailView>
  ) {}
}

extension MailView {
  public class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
    var dismiss: DismissAction
    @Binding var result: Result<MFMailComposeResult, Error>?
    
    public init(
      dismiss: DismissAction,
      result: Binding<Result<MFMailComposeResult, Error>?>
    ) {
      self.dismiss = dismiss
      _result = result
    }
    
    public func mailComposeController(
      _: MFMailComposeViewController,
      didFinishWith result: MFMailComposeResult,
      error: Error?
    ) {
      defer {
        dismiss()
      }
      guard let error else {
        self.result = .success(result)
        return
      }
      self.result = .failure(error)
    }
  }
  
}
