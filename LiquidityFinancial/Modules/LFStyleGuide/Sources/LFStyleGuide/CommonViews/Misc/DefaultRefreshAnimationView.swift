import Lottie
import UIKit

public class DefaultRefreshAnimationView: UIView {
  public static let shared: UIView = DefaultRefreshAnimationView.sharedInstance()
  
  private let animationView = LottieAnimationView()
  private let animationWidth: CGFloat = 36
  private let animationHeight: CGFloat = 36
  private var centerXConstraint: NSLayoutConstraint?
  
  private class func sharedInstance() -> DefaultRefreshAnimationView {
    let view = DefaultRefreshAnimationView()
    view.setupView()
    return view
  }
  
  private func setupView() {
    translatesAutoresizingMaskIntoConstraints = false
    
    animationView.animation = .named(DefaultLottieView.Loading.branded.fileName)
    animationView.contentMode = .scaleAspectFit
    animationView.play()
    animationView.loopMode = .loop
    animationView.translatesAutoresizingMaskIntoConstraints = false
    
    addSubview(animationView)
    
    // Constrain animation view to fill the container
    NSLayoutConstraint.activate([
      animationView.heightAnchor.constraint(equalTo: heightAnchor),
      animationView.widthAnchor.constraint(equalTo: widthAnchor),
      animationView.centerXAnchor.constraint(equalTo: centerXAnchor),
      animationView.centerYAnchor.constraint(equalTo: centerYAnchor)
    ])
    
    // Set fixed size
    NSLayoutConstraint.activate([
      widthAnchor.constraint(equalToConstant: animationWidth),
      heightAnchor.constraint(equalToConstant: animationHeight)
    ])
  }
  
  public override func didMoveToSuperview() {
    super.didMoveToSuperview()
    
    guard let superview = superview else {
      centerXConstraint?.isActive = false
      centerXConstraint = nil
      return
    }
    
    // Remove old constraint if exists
    centerXConstraint?.isActive = false
    
    // Center horizontally within the refresh control (superview)
    // and position at the top
    centerXConstraint = centerXAnchor.constraint(equalTo: superview.centerXAnchor)
    centerXConstraint?.isActive = true
    
    topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
  }
}
