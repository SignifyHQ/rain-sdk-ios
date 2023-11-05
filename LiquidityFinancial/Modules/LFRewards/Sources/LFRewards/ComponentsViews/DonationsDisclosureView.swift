import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable

public struct DonationsDisclosureView: View {
  public init() {}
  
  public var body: some View {
    content
      .fixedSize(horizontal: false, vertical: true)
      .popup(isPresented: $showPopup) {
        alert
      }
  }
  
  @State private var showPopup = false
  @Environment(\.openURL) private var openURL
  
  private var content: some View {
    Group {
      
      Text(LFLocalizable.DonationsDisclosure.text("100%"))
      +
      Text(GenImages.CommonImages.info.swiftUIImage)
    }
    .onTapGesture {
      showPopup = true
    }
    .frame(maxWidth: .infinity)
    .font(Fonts.regular.swiftUIFont(size: 12))
    .foregroundColor(ModuleColors.label.swiftUIColor.opacity(0.5))
    .multilineTextAlignment(.center)
    .padding(.horizontal, 24)
  }
  
  private var alert: some View {
    PopupAlert {
      VStack(spacing: 16) {
        GenImages.Images.icLogo.swiftUIImage
          .resizable()
          .frame(width: 80, height: 80)
        
        Text(LFLocalizable.DonationsDisclosure.Alert.title)
          .font(Fonts.regular.swiftUIFont(size: 18))
          .foregroundColor(ModuleColors.label.swiftUIColor)
          .padding(.top, 8)
        
        VStack(spacing: 0) {
          ShoppingGivesAlert(type: .taxDeductions)
            .frame(height: 156)
          Text(LFLocalizable.DonationsDisclosure.Alert.poweredBy)
        }
        .font(Fonts.regular.swiftUIFont(size: 16))
        .foregroundColor(ModuleColors.label.swiftUIColor.opacity(0.75))
        .lineSpacing(1.33)
        .multilineTextAlignment(.center)
        FullSizeButton(title: LFLocalizable.Button.Ok.title, isDisable: false, type: .primary) {
          showPopup = false
        }
      }
    }
  }
}

#if DEBUG

// MARK: - DonationsDisclosureView_Previews

struct DonationsDisclosureView_Previews: PreviewProvider {
  static var previews: some View {
    DonationsDisclosureView()
      .padding(.horizontal, 30)
  }
}
#endif
