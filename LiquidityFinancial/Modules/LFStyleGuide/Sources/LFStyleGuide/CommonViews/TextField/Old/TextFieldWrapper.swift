import SwiftUI
import LFUtilities

public struct TextFieldWrapper<Content: View>: View {
  public init(
    errorValue: Binding<String?> = .constant(nil),
    isLoading: Binding<Bool> = .constant(false),
    isDividerShown: Bool = true,
    @ViewBuilder content: () -> Content
  ) {
    self.content = content()
    self.isDividerShown = isDividerShown
    _errorValue = errorValue
    _isLoading = isLoading
  }
  
  let content: Content
  
  let isDividerShown: Bool
  
  @Binding var errorValue: String?
  @Binding var isLoading: Bool
  
  public var body: some View {
    VStack(spacing: 8) {
      HStack {
        content
        
        if errorValue != nil {
          GenImages.CommonImages.icError.swiftUIImage
            .foregroundColor(Colors.error.swiftUIColor)
        }
        
        if isLoading {
          Spacer()
          
          CircleIndicatorView()
        }
      }
      
      if isDividerShown {
        Divider()
          .background(errorValue == nil ? Colors.dividerPrimary.swiftUIColor : Colors.error.swiftUIColor)
          .frame(height: 1, alignment: .center)
      }
      
      if let errorValue {
        Text(errorValue)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(Colors.error.swiftUIColor)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
  }
}
