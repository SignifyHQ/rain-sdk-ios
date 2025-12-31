import SwiftUI
import WebKit

public struct WebView: UIViewRepresentable {
  var url: URL
  
  public init(url: URL) {
    self.url = url
  }
  
  public func makeUIView(context _: Context) -> WKWebView {
    let webView = WKWebView()
    webView.backgroundColor = Colors.background.color
    return webView
  }
  
  public func updateUIView(_ webView: WKWebView, context _: Context) {
    let request = URLRequest(url: url)
    webView.load(request)
  }
}
