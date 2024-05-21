import SwiftUI

public struct CircleLoadingTimerView: View {
  @State private var progress: CGFloat = 0.0
  @State private var remainingTime: Int = 0
  
  private let duration: Int
  private let dismissAction: (() -> Void)?
  
  public init(duration: Int, dismissAction: @escaping () -> Void) {
    self.duration = duration
    self.dismissAction = dismissAction
  }
  
  public var body: some View {
    ZStack {
      Circle()
        .stroke(
          Colors.primary.swiftUIColor.opacity(0.2),
          style: StrokeStyle(lineWidth: 10, lineCap: .round)
        )
        .frame(120)
      Circle()
        .trim(from: 0.0, to: progress)
        .stroke(
          Colors.primary.swiftUIColor,
          style: StrokeStyle(lineWidth: 10, lineCap: .round)
        )
        .rotationEffect(Angle(degrees: -90))
        .frame(120)
        .onAppear {
          startTimer()
          withAnimation(
            .linear(duration: TimeInterval(fromMilliseconds: Int64(duration * 1000)))
          ) {
            progress = 1.0
          }
        }
      
      Text("\(remainingTime)")
        .font(.largeTitle)
        .bold()
    }
  }
  
  private func startTimer() {
    remainingTime = duration
    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
      if self.remainingTime > 0 {
        self.remainingTime -= 1
      } else {
        timer.invalidate()
        dismissAction?()
      }
    }
  }
}
