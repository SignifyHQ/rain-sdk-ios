import LFLocalizable
import LFStyleGuide
import SwiftUI
import LFUtilities
import Services
import Factory

struct BlockingFiatView: View {
  
  @Injected(\.customerSupportService) var customerSupportService
  
  var body: some View {
    GeometryReader { geometry in
      ZStack {
        GenImages.Images.bgDashboardBlockCash.swiftUIImage
          .resizable()
          .aspectRatio(geometry.size, contentMode: .fill)
          .edgesIgnoringSafeArea(.all)
        
        VStack(alignment: .center) {
          GenImages.Images.icLogo.swiftUIImage
            .resizable()
            .frame(100)
            .padding(.top, 32)
          
          VStack(spacing: 16) {
            Text(LFLocalizable.BlockingFiatView.title)
              .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.main.value))
              .foregroundColor(Colors.label.swiftUIColor)
              .padding(.top, 16)
            
            Text(LFLocalizable.BlockingFiatView.description)
              .font(Fonts.regular.swiftUIFont(fixedSize: Constants.FontSize.medium.value))
              .foregroundColor(Colors.label.swiftUIColor)
              .multilineTextAlignment(.center)
          }
          .padding(.top, 12)
          .padding(.horizontal, 26)
          
          FullSizeButton(
            title: LFLocalizable.Button.ContactSupport.title,
            isDisable: false
          ) {
            customerSupportService.openSupportScreen()
          }
          .padding(.top, 20)
          .padding(.bottom, 8)
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, 16)
        .foregroundColor(.clear)
        .background(Colors.tertiaryBackground.swiftUIColor)
        .cornerRadius(20)
        .padding(.horizontal, 24)
      }
    }
  }
}
