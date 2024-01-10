import SwiftUI

public struct AdaptiveKeyboardScrollView<Content: View>: View {
  @State private var isShownKeyboard = false
  @State private var isShowBottomView = false

  let destinationViewID: String
  let content: () -> Content
  
  public init(destinationViewID: String, @ViewBuilder content: @escaping () -> Content) {
    self.destinationViewID = destinationViewID
    self.content = content
  }
  
  public var body: some View {
    VStack(spacing: 0) {
      ScrollViewReader { proxy in
        ScrollView(showsIndicators: false) {
          content()
        }
        .onChange(of: isShownKeyboard) { _ in
          if isShownKeyboard {
            proxy.scrollTo(destinationViewID)
          }
        }
      }
      .onAppear {
        observeKeyboard()
      }
      
      // Used to handle not scaling white space when the keyboard disappears in iOS 16
      if isShowBottomView {
        Rectangle()
          .fill(Colors.background.swiftUIColor)
          .frame(height: 1)
      }
    }
  }
}

// MARK: - View Helpers
extension AdaptiveKeyboardScrollView {
  func observeKeyboard() {
    NotificationCenter.default.addObserver(
      forName: UIResponder.keyboardWillShowNotification,
      object: nil,
      queue: .main
    ) { _ in
      withAnimation {
        isShownKeyboard = true
      }
    }

    NotificationCenter.default.addObserver(
      forName: UIResponder.keyboardWillHideNotification,
      object: nil,
      queue: .main
    ) { _ in
      withAnimation {
        isShowBottomView = true
        isShownKeyboard = false
      }
      isShowBottomView = false
    }
  }
}
