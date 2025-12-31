import Lottie
import SwiftUI

public struct LottieView: UIViewRepresentable {
  private let fileName: String
  private let tint: UIColor?
  private let animationView = LottieAnimationView()
  
  public init(
    loading: Loading,
    tint: UIColor? = nil
  ) {
    fileName = loading.fileName
    self.tint = tint
  }
  
  public init(
    twinkle: Twinkle,
    tint: UIColor? = nil
  ) {
    fileName = twinkle.fileName
    self.tint = tint
  }
  
  public init(
    tutorial: Tutorial,
    tint: UIColor? = nil
  ) {
    fileName = tutorial.fileName
    self.tint = tint
  }
  
  public func makeUIView(context _: Context) -> some UIView {
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

public extension LottieView {
  enum Loading {
    case primary
    case mix
    case contrast
    case heart
    
    var fileName: String {
      switch self {
      case .primary:
        return "LoadingPrimary"
      case .mix:
        return "LoadingMix"
      case .contrast:
        return "LoadingContrast"
      case .heart:
        return "LoadingHeart"
      }
    }
  }
  
  enum Twinkle {
    case sides
    case circle
    case contrast
    
    var fileName: String {
      switch self {
      case .sides:
        return "TwinkleSides"
      case .circle:
        return "TwinkleCircle"
      case .contrast:
        return "TwinkleContrast"
      }
    }
  }
  
  enum Tutorial {
    case welcome
    case applePay
    
    var fileName: String {
      switch self {
      case .welcome:
        return "Welcome"
      case .applePay:
        return "ApplePay"
      }
    }
  }
}
