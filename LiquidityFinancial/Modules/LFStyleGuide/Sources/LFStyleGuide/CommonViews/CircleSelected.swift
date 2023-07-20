import SwiftUI

public struct CircleSelected: View {
  let isSelected: Bool
  let size: CGFloat
  
  public init(isSelected: Bool, size: CGFloat = 20) {
    self.isSelected = isSelected
    self.size = size
  }
  
  public var body: some View {
    Circle()
      .stroke(Colors.label.swiftUIColor.opacity(0.25), lineWidth: 1)
      .background(
        ZStack {
          if isSelected {
            Circle()
              .fill(Colors.primary.swiftUIColor)
              .overlay {
                GenImages.CommonImages.checkmark.swiftUIImage
                  .foregroundColor(Colors.label.swiftUIColor)
              }
          }
        }
      )
      .frame(size)
  }
}
