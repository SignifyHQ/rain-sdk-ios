import SwiftUI

public struct SegmentedProgressBar: View {
  let totalSteps: Int
  
  @Binding var currentStep: Int
  
  var activeColor: Color = Colors.progressBarActive.swiftUIColor
  var inactiveColor: Color = Colors.backgroundLight.swiftUIColor
  var spacing: CGFloat = 15
  var segmentHeight: CGFloat = 4
  var animationDuration: Double = 0.3
  
  public init(
    totalSteps: Int,
    currentStep: Binding<Int>
  ) {
    self.totalSteps = totalSteps
    self._currentStep = currentStep
  }
  
  public var body: some View {
    HStack(
      spacing: spacing
    ) {
      ForEach(
        0..<totalSteps,
        id: \.self
      ) { index in
        let isActive = index < currentStep
        
        RoundedRectangle(
          cornerRadius: segmentHeight / 2
        )
        .fill(isActive ? activeColor : inactiveColor)
        .frame(
          height: segmentHeight
        )
        .animation(
          .easeInOut(
            duration: animationDuration
          ),
          value: isActive
        )
      }
    }
  }
}
