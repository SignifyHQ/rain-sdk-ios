import Lottie
import SwiftUI

struct LottieView: UIViewRepresentable {
  private let fileName: String
  private let animationView = LottieAnimationView()
  
  init(loading: Loading) {
    fileName = loading.fileName
  }
  
  init(twinkle: Twinkle) {
    fileName = twinkle.fileName
  }
  
  init(tutorial: Tutorial) {
    fileName = tutorial.fileName
  }
  
  func makeUIView(context _: Context) -> some UIView {
    let view = UIView(frame: .zero)
    
    animationView.animation = LottieAnimation.named(fileName)
    animationView.contentMode = .scaleAspectFit
    animationView.play()
    animationView.loopMode = .loop
    animationView.backgroundBehavior = .pauseAndRestore
    animationView.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(animationView)
    animationView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    animationView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    
    return view
  }
  
  func updateUIView(_: UIViewType, context _: Context) {}
}

  // MARK: - Types

extension LottieView {
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
