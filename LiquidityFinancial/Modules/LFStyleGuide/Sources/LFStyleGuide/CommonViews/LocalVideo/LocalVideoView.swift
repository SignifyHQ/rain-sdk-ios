import SwiftUI
import AVFoundation

public struct LocalVideoView: View {
  private let fileName: String
  
  public init(fileName: String) {
    self.fileName = fileName
  }
  
  public var body: some View {
    VideoPlayerView(fileName: fileName)
      .frame(maxWidth: .infinity)
  }
}

struct VideoPlayerView: UIViewRepresentable {
  let fileName: String
  
  func makeUIView(context: Context) -> PlayerContainerView {
    let containerView = PlayerContainerView()
    containerView.setupPlayer(fileName: fileName, coordinator: context.coordinator)
    return containerView
  }
  
  func updateUIView(_ uiView: PlayerContainerView, context: Context) {
    uiView.updateFrame()
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator()
  }
  
  class Coordinator {
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var observer: NSObjectProtocol?
    
    deinit {
      if let observer = observer {
        NotificationCenter.default.removeObserver(observer)
      }
      player?.pause()
    }
  }
}

class PlayerContainerView: UIView {
  private var playerLayer: AVPlayerLayer?
  private var player: AVPlayer?
  private var observer: NSObjectProtocol?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .clear
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setupPlayer(fileName: String, coordinator: VideoPlayerView.Coordinator) {
    guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp4") else {
      return
    }
    
    let newPlayer = AVPlayer(url: url)
    let newPlayerLayer = AVPlayerLayer(player: newPlayer)
    newPlayerLayer.videoGravity = .resizeAspect
    
    layer.addSublayer(newPlayerLayer)
    newPlayerLayer.frame = bounds
    
    // Set up looping
    let newObserver = NotificationCenter.default.addObserver(
      forName: .AVPlayerItemDidPlayToEndTime,
      object: newPlayer.currentItem,
      queue: .main
    ) { [weak newPlayer] _ in
      newPlayer?.seek(to: .zero)
      newPlayer?.play()
    }
    
    // Auto-play
    newPlayer.play()
    
    // Store references
    self.player = newPlayer
    self.playerLayer = newPlayerLayer
    self.observer = newObserver
    
    coordinator.player = newPlayer
    coordinator.playerLayer = newPlayerLayer
    coordinator.observer = newObserver
  }
  
  func updateFrame() {
    playerLayer?.frame = bounds
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    playerLayer?.frame = bounds
  }
  
  deinit {
    if let observer = observer {
      NotificationCenter.default.removeObserver(observer)
    }
    player?.pause()
  }
}

