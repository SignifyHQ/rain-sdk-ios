import SwiftUI

public struct PDFWebView: View {
  @State private var documentUrl: URL?
  @State private var showShare = false
  let documentName: String
  
  public init(documentName: String) {
    self.documentName = documentName
  }
  
  public var body: some View {
    VStack {
      Spacer()
      if let documentUrl {
        WebView(url: documentUrl)
      } else {
        LottieView(loading: .primary)
          .frame(width: 60, height: 40)
      }
      Spacer()
    }
    .frame(maxWidth: .infinity)
    .background(Colors.background.swiftUIColor)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        if documentUrl != nil {
          Button {
            showShare = true
          } label: {
            CircleButton(style: .share)
          }
        }
      }
    }
    .onAppear {
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        loadDocument()
      }
    }
    .sheet(isPresented: $showShare) {
      if let documentUrl {
        ShareSheetView(activityItems: [documentUrl])
      }
    }
  }
}

// MARK: - View Helpers
private extension PDFWebView {
  func loadDocument() {
    guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
    let outputFileURL = documentDirectory.appendingPathComponent(documentName).path
    let url = URL(fileURLWithPath: outputFileURL)
    
    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: outputFileURL) {
      documentUrl = url
    }
  }
}
