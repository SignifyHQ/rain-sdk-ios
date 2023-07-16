import Lottie
import UIKit

public class RefreshAnimationView: UIView {
  public static let shared: UIView = RefreshAnimationView.sharedInstance()
  
  private class func sharedInstance() -> UIView {
    let animationWidth: CGFloat = 30
    let animationHeight: CGFloat = 20
    let bounds = Device.current.screen.bounds
    let originX = bounds.width / 2 - (animationWidth / 2)
    let view = UIView(frame: CGRect(x: originX, y: 0, width: animationWidth, height: animationHeight))
    let animationView = LottieAnimationView()
    animationView.animation = .named(LottieView.Loading.primary.fileName)
    animationView.contentMode = .scaleAspectFit
    animationView.play()
    animationView.loopMode = .loop
    animationView.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(animationView)
    animationView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    animationView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    
    return view
  }
}
