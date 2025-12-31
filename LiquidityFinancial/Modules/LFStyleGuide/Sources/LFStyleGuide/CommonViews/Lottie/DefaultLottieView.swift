import Lottie
import SwiftUI

public struct DefaultLottieView: UIViewRepresentable {
  private let fileName: String
  private let tint: UIColor?
  private let animationView = LottieAnimationView()
  
  public init(
    loading: Loading,
    tint: UIColor? = nil
  ) {
    self.fileName = loading.fileName
    self.tint = tint
  }
  
  public func makeUIView(
    context _: Context
  ) -> some UIView {
    let view = UIView(frame: .zero)
    
    animationView.animation = LottieAnimation.named(fileName)
    animationView.contentMode = .scaleAspectFit
    
    if let tint {
      animationView.setValueProvider(
        ColorValueProvider(tint.lottieColorValue),
        keypath: AnimationKeypath(keypath: "**.Color")
      )
    }
    
    animationView.play()
    animationView.loopMode = .loop
    animationView.backgroundBehavior = .pauseAndRestore
    animationView.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(animationView)
    
    animationView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    animationView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    
    return view
  }
  
  public func updateUIView(_: UIViewType, context _: Context) {}
}

// MARK: - Types
public extension DefaultLottieView {
  enum Loading {
    case ctaRegular
    case ctaFast
    case branded
    
    var fileName: String {
      switch self {
      case .ctaRegular:
        "loaderCtaRegular"
      case .ctaFast:
        "loaderCtaFast"
      case .branded:
        "loaderBranded"
      }
    }
  }
}

// Helper to convert UIColor to Lottie’s Color
extension UIColor {
  var lottieColorValue: LottieColor {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    
    getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    
    return LottieColor(r: red, g: green, b: blue, a: alpha)
  }
}
