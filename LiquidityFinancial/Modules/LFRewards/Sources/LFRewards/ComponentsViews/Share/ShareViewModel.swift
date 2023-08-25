import Combine
import SwiftUI
import LFUtilities
import LFLocalizable

@MainActor
public class ShareViewModel: ObservableObject {
  var data: ShareItemData
  let items: [any ShareItem]
  @Published var includeDonation = false
  @Published var toastMessage: String?
  @Published var showShareSheet = false
  
  public init(data: ShareItemData) {
    self.data = data
    subject = .init()
    items = [
      FacebookShareItem(data: data, subject: subject),
      MessagesShareItem(data: data),
      EmailShareItem(data: data),
      WhatsappShareItem(data: data),
      TwitterShareItem(data: data),
      InstagramShareItem(data: data, subject: subject)
    ]
    
    cancellable = subject
      .receive(on: DispatchQueue.main)
      .sink { [weak self] action in
        self?.handleAction(action: action)
      }
  }
  
  var allowHitTesting: Bool {
    switch status {
    case .idle: return true
    case .loading: return false
    }
  }
  
  func linkTapped() {
    UIPasteboard.general.string = data.attachmentUrl?.absoluteString
    toastMessage = "pasteboard_copy".localizedString
  }
  
  func isItemLoading(item: ShareItem) -> Bool {
    switch status {
    case let .loading(name):
      return item.name == name
    case .idle:
      return false
    }
  }
  
  func moreTapped() {
    showShareSheet = true
  }
  
  var shareActivityItems: [Any] {
    var result: [Any] = []
    if let url = data.attachmentUrl {
      result.append(url)
    } else {
      result.append(data.message)
    }
    return result
  }
  
  private let subject: PassthroughSubject<ShareItemAction, Never>
  private var cancellable: AnyCancellable?
  private var status = Status.idle
  
  private func handleAction(action: ShareItemAction) {
    switch action {
    case let .startLoading(item):
      status = .loading(item)
    case .succeeded:
      status = .idle
    case let .failed(item):
      status = .idle
      toastMessage = String(format: "share.failure".localizedString, item)
    }
    objectWillChange.send()
  }
}

extension ShareViewModel {
  enum Status {
    case idle
    case loading(String)
  }
}
