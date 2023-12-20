import Foundation
import SwiftUI
import LFUtilities
import LFStyleGuide

// TODO: Temporarily test this solution for Doge-no-bank first, if it has no errors, then apply it to the remaining applications.
struct CustomTabBar: View {
  @Binding var selectedTab: TabOption
  
  var getSafeAreaBottom: CGFloat {
    let keyWindow = UIApplication.shared.connectedScenes
      .filter({$0.activationState == .foregroundActive})
      .map({$0 as? UIWindowScene})
      .compactMap({$0})
      .first?.windows
      .filter({$0.isKeyWindow}).first
    return (keyWindow?.safeAreaInsets.bottom) ?? 32
  }
  
  var body: some View {
    VStack {
      HStack {
        ForEach(TabOption.allCases, id: \.rawValue) { tab in
          Spacer()
          VStack(spacing: 2) {
            tab.imageAsset
              .foregroundColor(
                selectedTab == tab ? Colors.primary.swiftUIColor : Colors.label.swiftUIColor
              )
              .tint(Colors.primary.swiftUIColor)
            Text(tab.title)
              .foregroundColor(
                selectedTab == tab ? Colors.label.swiftUIColor : Colors.label.swiftUIColor.opacity(0.75)
              )
              .font(Fonts.orbitronMedium.swiftUIFont(size: 10))
          }
          .padding(.top, 5)
          .onTapGesture {
            withAnimation(.easeIn(duration: 0.1)){
              selectedTab = tab
            }
          }
          Spacer()
        }
      }
      .background(Colors.secondaryBackground.swiftUIColor)
      .frame(width: nil, height: 68 + getSafeAreaBottom)
    }
  }
}
