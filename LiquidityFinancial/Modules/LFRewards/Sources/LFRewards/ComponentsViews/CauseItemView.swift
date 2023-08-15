import SwiftUI
import LFStyleGuide
import LFUtilities

struct CauseItemView: View {
  let cause: CauseModel
  let isLoading: Bool
  
  init(cause: CauseModel, isLoading: Bool = false) {
    self.cause = cause
    self.isLoading = isLoading
  }
  
  var body: some View {
    ZStack {
      VStack(spacing: 6) {
        CachedAsyncImage(url: cause.logoUrl) { image in
          image
            .resizable()
            .aspectRatio(1.0, contentMode: .fit)
        } placeholder: {
          Rectangle()
            .fill(ModuleColors.primary.swiftUIColor)
            .cornerRadius(10)
        }
        
        Text(cause.name)
          .font(Fonts.regular.swiftUIFont(size: 12))
          .foregroundColor(ModuleColors.label.swiftUIColor)
          .frame(height: 36)
          .multilineTextAlignment(.center)
      }
      .hidden(isLoading)
      
      LottieView(loading: .primary)
        .frame(width: 30, height: 20)
        .hidden(!isLoading)
    }
    .padding(6)
    .background(ModuleColors.secondaryBackground.swiftUIColor)
    .cornerRadius(10)
  }
}
