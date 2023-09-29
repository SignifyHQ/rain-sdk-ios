import SwiftUI
import WebKit
import LFUtilities
import LFStyleGuide

struct IdentityVerificationView: View {
  let url: URL
  let succcessCallback: () -> Void
  
  @Environment(\.dismiss) private var dismiss
  
  var body: some View {
    PersonaView(hostedURL: url, successCallback: succcessCallback)
      .defaultToolBar(icon: .xMark)
      .embedInNavigation()
  }
}

// MARK: - PersonaView
private struct PersonaView: UIViewRepresentable {
  let hostedURL: URL
  var successCallback: () -> Void
  
  // Make a coordinator to co-ordinate with WKWebView's default delegate functions
  func makeCoordinator() -> PersonaWebView {
    PersonaWebView(self)
  }
  
  func makeUIView(context: Context) -> WKWebView {
    let config = WKWebViewConfiguration()
    config.allowsInlineMediaPlayback = true
    
    let webView = WKWebView(frame: CGRect.zero, configuration: config)
    webView.navigationDelegate = context.coordinator
    webView.allowsBackForwardNavigationGestures = false
    webView.scrollView.bounces = false
    webView.translatesAutoresizingMaskIntoConstraints = false
    
    let redirectURI = "&redirect-uri=\(LFUtilities.personaCallback)"
    let strHostedURL = hostedURL.absoluteString + redirectURI
    if let url = URL(string: strHostedURL) {
      webView.load(URLRequest(url: url))
    }
    
    return webView
  }
  
  func updateUIView(_: WKWebView, context _: Context) {}
}

// MARK: - PersonaWebView
private class PersonaWebView: NSObject, WKNavigationDelegate {
  init(_ uiWebView: PersonaView) {
    parent = uiWebView
  }
  
  var parent: PersonaView
  
  func webView(_: WKWebView, didFail _: WKNavigation!, withError error: Error) {}
  
  /// Handle navigation actions from the web view.
  func webView(_: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    // Check if we are being redirected to our `redirectUri`. This happens once verification is completed.
    guard let redirectUri = navigationAction.request.url?.absoluteString, redirectUri.starts(with: LFUtilities.personaCallback) else {
      // We're not being redirected, so load the URL.
      decisionHandler(.allow)
      return
    }
    
    // At this point we're done, so we don't need to load the URL.
    // verification is success..
    decisionHandler(.cancel)
    
    // TO REMOVE TEMP FILE
    FileManager.default.clearTmpDirectory()
    
    parent.successCallback()
  }
}
