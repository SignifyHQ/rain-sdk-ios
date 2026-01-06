import SwiftUI
import LFUtilities

// MARK: - View Extension
extension View {
  public func defaultNavBar(
    buttonTypes: [NavBarButtonType] = [.support],
    navigationTitle: String? = nil,
    navigationImage: Image? = GenImages.Images.imgLogoNavBar.swiftUIImage,
    dismissAction: (() -> Void)? = nil,
    onRightButtonTap: (() -> Void)? = nil,
    edgeInsets: EdgeInsets = .bottom(12),
    isBackButtonHidden: Bool = false
  ) -> some View {
    modifier(
      NavBarModifier(
        buttonTypes: buttonTypes,
        navigationTitle: navigationTitle,
        navigationImage: navigationImage,
        dismissAction: dismissAction,
        onRightButtonTap: onRightButtonTap,
        edgeInsets: edgeInsets,
        isBackButtonHidden: isBackButtonHidden
      )
    )
  }
  
  public func appNavBar(
    buttonTypes: [NavBarButtonType] = [],
    navigationTitle: String? = nil,
    navigationImage: Image? = GenImages.Images.imgLogoNavBar.swiftUIImage,
    dismissAction: (() -> Void)? = nil,
    onRightButtonTap: (() -> Void)? = nil,
    edgeInsets: EdgeInsets = .bottom(12),
    isBackButtonHidden: Bool = false
  ) -> some View {
    modifier(
      NavBarModifier(
        buttonTypes: buttonTypes,
        navigationTitle: navigationTitle,
        navigationImage: navigationImage,
        dismissAction: dismissAction,
        onRightButtonTap: onRightButtonTap,
        edgeInsets: edgeInsets,
        isBackButtonHidden: isBackButtonHidden
      )
    )
  }
  
  public func tabNavBar(
    buttonTypes: [NavBarButtonType] = [.support],
    leadingTitle: String? = nil,
    navigationTitle: String? = nil,
    navigationImage: Image? = nil,
    onRightButtonTap: (() -> Void)? = nil,
    edgeInsets: EdgeInsets = .init(top: 12, leading: 8, bottom: 12, trailing: 8)
  ) -> some View {
    modifier(
      NavBarModifier(
        buttonTypes: buttonTypes,
        leadingTitle: leadingTitle,
        navigationTitle: navigationTitle,
        navigationImage: navigationImage,
        dismissAction: nil,
        onRightButtonTap: onRightButtonTap,
        edgeInsets: edgeInsets,
        isBackButtonHidden: true
      )
    )
  }
}

// MARK: - View Modifier
private struct NavBarModifier: ViewModifier {
  @Environment(\.dismiss) private var dismiss
  
  let buttonTypes: [NavBarButtonType]
  let leadingTitle: String?
  
  let navigationTitle: String?
  let navigationImage: Image?
  
  let dismissAction: (() -> Void)?
  let onRightButtonTap: (() -> Void)?
  
  let edgeInsets: EdgeInsets
  
  let isBackButtonHidden: Bool
  
  init(
    buttonTypes: [NavBarButtonType] = [],
    leadingTitle: String? = nil,
    navigationTitle: String?,
    navigationImage: Image?,
    dismissAction: (() -> Void)?,
    onRightButtonTap: (() -> Void)?,
    edgeInsets: EdgeInsets,
    isBackButtonHidden: Bool
  ) {
    self.buttonTypes = buttonTypes
    self.leadingTitle = leadingTitle
    self.navigationTitle = navigationTitle
    self.navigationImage = navigationImage
    self.dismissAction = dismissAction
    self.onRightButtonTap = onRightButtonTap
    self.edgeInsets = edgeInsets
    self.isBackButtonHidden = isBackButtonHidden
  }
  
  func body(
    content: Content
  ) -> some View {
    content
      .navigationBarTitleDisplayMode(.inline)
    // Only hide the native back button if it is explicitly hidden or
    // if custom dismiss action is set in order to preserve the native
    // swipe-to-pop gesture
      .navigationBarBackButtonHidden(dismissAction != nil || isBackButtonHidden)
      .toolbar {
        // Only show the custom back button if dismissAction is set
        if !isBackButtonHidden && dismissAction != nil {
          ToolbarItem(
            placement: .navigationBarLeading
          ) {
            Button(
              action: {
                if let dismissAction {
                  dismissAction()
                } else {
                  dismiss()
                }
              }
            ) {
              GenImages.Images.icoArrowNavBack.swiftUIImage
                .foregroundColor(Colors.label.swiftUIColor)
                .padding(.leading, 8)
                .padding(.bottom, 12)
            }
          }
        }
        
        if let leadingTitle {
          ToolbarItem(placement: .topBarLeading) {
            Text(leadingTitle)
              .foregroundColor(Colors.label.swiftUIColor)
              .font(Fonts.semiBold.swiftUIFont(size: Constants.FontSize.main.value))
              .padding(edgeInsets)
          }
        }
        
        // If both are set, title overrides the image
        if let navigationTitle {
          ToolbarItem(
            placement: .principal
          ) {
            Text(navigationTitle)
              .foregroundColor(Colors.label.swiftUIColor)
              .font(Fonts.semiBold.swiftUIFont(size: Constants.FontSize.medium.value))
              .padding(edgeInsets)
          }
        } else if let navigationImage {
          ToolbarItem(
            placement: .principal
          ) {
            navigationImage
              .padding(edgeInsets)
          }
        }
        
        ToolbarItem(
          placement: .topBarTrailing
        ) {
          if buttonTypes.contains(.support) {
            Button {
              onRightButtonTap?()
            } label: {
              GenImages.Images.icoSupport.swiftUIImage
                .foregroundColor(Colors.label.swiftUIColor)
                .padding(edgeInsets)
            }
          }
        }
      }
  }
}

// MARK: - Enums
public enum NavBarButtonType {
  case support
}
