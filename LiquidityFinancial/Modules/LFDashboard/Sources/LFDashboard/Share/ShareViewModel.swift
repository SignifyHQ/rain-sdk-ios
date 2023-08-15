import Combine
import SwiftUI
import LFLocalizable

@MainActor
final class ShareViewModel: ObservableObject {
  var data: ShareItemData
  let items: [any ShareItem]
  @Published var includeDonation = false
  @Published var toastMessage: String?
  @Published var showShareSheet = false
  
  init(data: ShareItemData) {
    self.data = data
    subject = .init()
    items = [
      // TODO: Will be implemented later
      //      FacebookShareItem(data: data, subject: subject),
      //      TikTokShareItem(data: data, subject: subject),
      //      MessagesShareItem(data: data),
      //      EmailShareItem(data: data),
      //      WhatsappShareItem(data: data),
      //      TwitterShareItem(data: data),
      //      SnapchatShareItem(data: data, subject: subject),
      //      InstagramShareItem(data: data, subject: subject),
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
    toastMessage = LFLocalizable.Toast.Copy.message
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
      toastMessage = LFLocalizable.Share.failure(item)
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
