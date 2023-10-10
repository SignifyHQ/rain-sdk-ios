import LinkKit
import SwiftUI

struct PlaidLinkView: View {
  private let configuration: LinkTokenConfiguration
  private var handler: LinkKit.Handler?
  @StateObject private var viewModel = PlaidLinkViewModel()

  init(configuration: LinkTokenConfiguration) {
    self.configuration = configuration
  }

  var body: some View {
    let controller = ExternalLinkBankViewController(
      configuration: .linkToken(configuration)
    ) { @MainActor handler in
      self.viewModel.handler = handler
    }
    return controller
      .onOpenURL { url in
        self.viewModel.handler?.resumeAfterTermination(from: url)
      }
  }
}
