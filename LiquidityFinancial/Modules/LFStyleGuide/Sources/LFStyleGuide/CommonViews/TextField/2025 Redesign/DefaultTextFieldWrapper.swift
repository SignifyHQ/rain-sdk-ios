import LFUtilities
import SwiftUI

public struct DefaultTextFieldWrapper<Content: View>: View {
  @Binding var errorValue: String?
  
  @Binding var isLoading: Bool
  
  let isDividerShown: Bool
  let content: Content
  
  public init(
    errorValue: Binding<String?> = .constant(nil),
    isLoading: Binding<Bool> = .constant(false),
    isDividerShown: Bool = true,
    @ViewBuilder content: () -> Content
  ) {
    self._errorValue = errorValue
    self._isLoading = isLoading
    self.isDividerShown = isDividerShown
    self.content = content()
  }
  
  public var body: some View {
    VStack(
      spacing: 8
    ) {
      HStack(
        spacing: 10
      ) {
        content
        
        if errorValue != nil {
          GenImages.Images.icoError.swiftUIImage
            .resizable()
            .frame(20)
            .foregroundColor(Colors.accentError.swiftUIColor)
        }
        
        if isLoading {
          Spacer()
          
          lottieAnimation
        }
      }
      
      if isDividerShown {
        Divider()
          .background(errorValue == nil ? Colors.textSecondary2.swiftUIColor : Colors.accentError.swiftUIColor)
          .frame(height: 1, alignment: .center)
      }
      
      if let errorValue,
         !errorValue.isEmpty {
        Text(errorValue)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(Colors.accentError.swiftUIColor)
          .frame(
            maxWidth: .infinity,
            alignment: .leading
          )
      }
    }
  }
  
  private var lottieAnimation: some View {
    Group {
      DefaultLottieView(
        loading: .ctaFast,
        tint: Colors.buttonPrimary.swiftUIColor.uiColor
      )
      .frame(
        width: 20,
        height: 20
      )
    }
  }
}
