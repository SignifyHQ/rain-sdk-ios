import SwiftUI
import LFUtilities
import LinkKit

struct ExternalLinkBankViewController {
  
  let configuration: LinkConfigurationType
  let onCreateError: ((Plaid.CreateError) -> Void)?
  let onUpdateHandler: ((LinkKit.Handler?) -> Void)?
  
  init(configuration: LinkConfigurationType, onCreateError: ((Plaid.CreateError) -> Void)? = nil, onUpdateHandler: ((LinkKit.Handler?) -> Void)?) {
    self.configuration = configuration
    self.onCreateError = onCreateError
    self.onUpdateHandler = onUpdateHandler
  }
  
  enum LinkConfigurationType {
    case publicKey(LinkPublicKeyConfiguration)
    case linkToken(LinkTokenConfiguration)
  }
}

extension ExternalLinkBankViewController: UIViewControllerRepresentable {
  final class Coordinator: NSObject {
    fileprivate init(_ parent: ExternalLinkBankViewController) {
      self.parent = parent
    }
    
    private(set) var parent: ExternalLinkBankViewController
    private(set) var handler: LinkKit.Handler?
    
    fileprivate func createHandler() -> Result<LinkKit.Handler, Plaid.CreateError> {
      switch parent.configuration {
      case let .publicKey(configuration):
        return Plaid.create(configuration)
      case let .linkToken(configuration):
        return Plaid.create(configuration)
      }
    }
    
    fileprivate func present(_ handler: LinkKit.Handler, in viewController: UIViewController) {
      guard self.handler == nil else {
        // Already presented a handler!
        return
      }
      self.handler = handler
      
      handler.open(presentUsing: .custom { linkViewController in
        viewController.addChild(linkViewController)
        viewController.view.addSubview(linkViewController.view)
        linkViewController.view.translatesAutoresizingMaskIntoConstraints = false
        linkViewController.view.frame = viewController.view.bounds
        NSLayoutConstraint.activate([
          linkViewController.view.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
          linkViewController.view.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor),
          linkViewController.view.widthAnchor.constraint(equalTo: viewController.view.widthAnchor),
          linkViewController.view.heightAnchor.constraint(equalTo: viewController.view.heightAnchor)
        ])
        linkViewController.didMove(toParent: viewController)
      })
    }
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  func makeUIViewController(context: Context) -> UIViewController {
    let viewController = UIViewController()
    onUpdateHandler?(nil)
    let handlerResult = context.coordinator.createHandler()
    switch handlerResult {
    case let .success(handler):
      context.coordinator.present(handler, in: viewController)
      onUpdateHandler?(handler)
    case let .failure(createError):
      onCreateError?(createError)
    }
    
    return viewController
  }
  
  func updateUIViewController(_: UIViewController, context _: Context) {
    // Empty implementation
  }
}
