import CodeScanner
import LFStyleGuide
import SwiftUI

public struct QRScannerView: View {
  @Environment(\.dismiss) var dismiss
  @State private var focusRect: CGRect = CGRect(
    x: 50,
    y: 200,
    width: 240,
    height: 240
  )
  
  let completion: (Result<ScanResult, ScanError>) -> Void
  
  public init(completion: @escaping (Result<ScanResult, ScanError>) -> Void) {
    self.completion = completion
  }
  
  public var body: some View {
    ZStack {
      // Camera preview would go here
      CodeScannerView(codeTypes: [.qr], completion: completion)
        .ignoresSafeArea(.all)
      // Focus overlay
      QRScannerFocusOverlay(
        focusRect: focusRect,
        overlayColor: Color.black.opacity(0.5),
        focusCornerRadius: 24
      )
      .ignoresSafeArea(.all)
      
      VStack(alignment: .leading) {
        HStack(alignment: .top) {
          CircleButton(style: .left)
            .onTapGesture {
              dismiss()
            }
            .padding(.leading, 20)
            .padding(.top, 8)
          Spacer()
        }
        Spacer()
      }
    }
    
    .onAppear {
      // Update focus rect when view appears or layout changes
      updateFocusRect()
    }
  }
  
  private func updateFocusRect() {
    // Calculate focus rect based on screen size
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    let focusSize: CGFloat = min(screenWidth - 100, 250)
    let focusX = (screenWidth - focusSize) / 2
    let focusY = (screenHeight - focusSize) / 2
    
    focusRect = CGRect(
      x: focusX,
      y: focusY,
      width: focusSize,
      height: focusSize
    )
  }
}
