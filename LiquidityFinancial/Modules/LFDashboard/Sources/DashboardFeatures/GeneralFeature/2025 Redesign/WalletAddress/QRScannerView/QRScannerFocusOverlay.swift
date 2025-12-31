import SwiftUI
import LFStyleGuide

// MARK: - QR Scanner Focus Overlay
struct QRScannerFocusOverlay: View {
  private let additionalPadding: CGFloat = 12
  
  let focusRect: CGRect
  let overlayColor: Color
  let focusCornerRadius: CGFloat
  
  init(
    focusRect: CGRect,
    overlayColor: Color = Color.black.opacity(0.5),
    focusCornerRadius: CGFloat = 24
  ) {
    self.focusRect = focusRect
    self.overlayColor = overlayColor
    self.focusCornerRadius = focusCornerRadius
  }
  
  var body: some View {
    GeometryReader { geometry in
      ZStack {
        // Overlay with cutout
        FocusMaskShape(
          focusRect: focusRect,
          containerSize: geometry.size,
          cornerRadius: focusCornerRadius
        )
        .fill(overlayColor, style: FillStyle(eoFill: true))
        
        GenImages.Images.cameraOverlay.swiftUIImage
          .resizable()
          .frame(width: focusRect.width + additionalPadding * 2, height: focusRect.height + additionalPadding * 2)
      }
    }
  }
}

// MARK: - Focus Mask Shape
struct FocusMaskShape: Shape {
  let focusRect: CGRect
  let containerSize: CGSize
  let cornerRadius: CGFloat
  
  func path(in rect: CGRect) -> Path {
    var path = Path()
    
    // Add the full container rectangle
    path.addRect(CGRect(origin: .zero, size: containerSize))
    
    // Add the focus rectangle with rounded corners (will be subtracted due to evenOdd fill rule)
    let roundedRect = RoundedRectangle(cornerRadius: cornerRadius)
    path.addPath(roundedRect.path(in: focusRect))
    
    return path
  }
}
