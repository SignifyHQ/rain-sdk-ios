import PDFKit
import SwiftUI
import LFUtilities

public struct DocumentViewer: View {
  let title: String
  let url: URL
  @State private var isSharePresented = false
  @State private var isLoading = true
  
  public init(title: String, url: URL, isSharePresented: Bool = false) {
    self.title = title
    self.url = url
    self.isSharePresented = isSharePresented
  }
  
  public var body: some View {
    ZStack {
      PDFKitView(
        url: url,
        completion: { _ in
          self.isLoading = false
        }
      )
      if isLoading {
        loadingView
      }
    }
    .background(Colors.background.swiftUIColor)
    .toolbar {
      ToolbarItem(placement: .principal) {
        Text(title)
          .foregroundColor(Colors.label.swiftUIColor)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
      }
      
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          isSharePresented = true
        } label: {
          CircleButton(style: .share)
        }
      }
    }
    .sheet(isPresented: $isSharePresented) {
      ShareSheetView(activityItems: [url])
    }
  }
  
  private var loadingView: some View {
    VStack {
      Spacer()
      LottieView(loading: .primary)
        .frame(width: 30, height: 20)
      Spacer()
    }
    .frame(max: .infinity)
  }
}

// MARK: - PDFKitView

private struct PDFKitView: UIViewRepresentable {
  let url: URL
  let completion: (Bool) -> Void
  
  func makeUIView(context _: Context) -> UIView {
    let pdfView = PDFKit.PDFView()
    loadDocument(url: url) { document in
      pdfView.document = document
      completion(document != nil)
    }
    pdfView.autoScales = true
    pdfView.backgroundColor = UIColor(Colors.secondaryBackground.swiftUIColor)
    return pdfView
  }
  
  func loadDocument(url: URL, escaping completion: @escaping ((PDFDocument?) -> Void)) {
    DispatchQueue.global(qos: .background).async {
      let pdfDocument = PDFDocument(url: url)
      DispatchQueue.main.async {
        completion(pdfDocument)
      }
    }
  }
  
  func updateUIView(_: UIView, context _: Context) {}
}
