import SwiftUI

public struct LoadingIndicatorView<Content>: View where Content: View {
  @Binding public var isShowing: Bool
  public var content: () -> Content
  
  public init(isShowing: Binding<Bool>, content: @escaping () -> Content) {
    self._isShowing = isShowing
    self.content = content
  }

  public var body: some View {
    GeometryReader { _ in
      ZStack(alignment: .center) {
        content()
          .disabled(isShowing)
        // .blur(radius: self.isShowing ? 1 : 0)

        VStack {
          if isShowing {
            ActivityIndicator(
              isAnimating: $isShowing,
              styleValue: .large,
              colorValue: UIColor(Colors.primary.swiftUIColor)
            )
          }
        }
      }
    }
  }
}

// MARK: - ActivityIndicator
public struct ActivityIndicator: UIViewRepresentable {
  @Binding var isAnimating: Bool
  let styleValue: UIActivityIndicatorView.Style
  let colorValue: UIColor

  public func makeUIView(context _: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
    let indicatorView = UIActivityIndicatorView()
    indicatorView.style = styleValue
    indicatorView.color = colorValue

    return indicatorView
  }

  public func updateUIView(_ uiView: UIActivityIndicatorView, context _: UIViewRepresentableContext<ActivityIndicator>) {
    if isAnimating {
      uiView.startAnimating()
    } else {
      uiView.stopAnimating()
    }
  }
}
