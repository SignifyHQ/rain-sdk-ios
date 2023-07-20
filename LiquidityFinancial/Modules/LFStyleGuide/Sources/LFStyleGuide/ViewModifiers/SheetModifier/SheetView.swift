#if os(iOS)

import SwiftUI

struct SheetView<Content: View>: UIViewControllerRepresentable {
  private let content: Content
  private let detents: [Detents]

  init(detents: [Detents], @ViewBuilder content: () -> Content) {
    self.content = content()
    self.detents = detents
  }

  func makeUIViewController(context: Context) -> SheetHostingController<Content> {
    SheetHostingController(rootView: content, detents: detents.map(\.uiViewDetents))
  }

  func updateUIViewController(_: SheetHostingController<Content>, context: Context) {}
}

#endif
