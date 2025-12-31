import SwiftUI

struct FullScreenLoaderView: View {
  public var size: CGFloat = 165
  public var backgroundColor: Color = Colors.backgroundPrimary.swiftUIColor
  
  public var body: some View {
    VStack {
      Spacer()
      
      DefaultLottieView(
        loading: .branded
      )
      .frame(size)
      
      Spacer()
    }
    .frame(max: .infinity)
    .background(backgroundColor)
  }
}
