import LFUtilities
import SwiftUI

public struct DropdownView<T: Identifiable & Hashable>: View {
  @Binding var selectedItem: T?
  @Binding var showDropdown: Bool

  let items: [T]
  let onItemSelected: (T) -> Void
  let itemDisplayName: (T) -> String
  let itemDisplayIcon: (T) -> Image?

  private var selectedOptionIndex: Int {
    guard let selectedItem else {
      return 0
    }
    return items.firstIndex(of: selectedItem) ?? 0
  }
  private var buttonHeight: CGFloat = 36
  private var maxItemDisplayed: Int = 5
  private var menuWidth: CGFloat {
    return UIScreen.main.bounds.width - 48
  }

  public var body: some View {
    VStack {
      VStack(spacing: 0) {
        // selection menu with pull-down animation
        if showDropdown {
          let scrollViewHeight: CGFloat =
            items.count > maxItemDisplayed
            ? (buttonHeight * CGFloat(maxItemDisplayed)) : (buttonHeight * CGFloat(items.count))
          ScrollViewReader { proxy in
            ScrollView {
              LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, option in
                  OptionRow(
                    item: option,
                    isSelected: selectedItem == option,
                    displayName: itemDisplayName,
                    displayIcon: itemDisplayIcon,
                    onTap: {
                      withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        selectedItem = option
                        onItemSelected(option)
                        showDropdown.toggle()
                      }
                    }
                  )
                  .frame(width: menuWidth, height: buttonHeight, alignment: .leading)
                  .id(index)
                }
              }
            }
            .scrollDisabled(items.count <= 3)
            .frame(height: scrollViewHeight)
            .onAppear {
              withAnimation {
                proxy.scrollTo(selectedOptionIndex, anchor: .center)
              }
            }
            .background(Colors.grey400.swiftUIColor)
            .cornerRadius(12)
            .transition(
              .asymmetric(
                insertion: .opacity.combined(with: .scale(scale: 0.8, anchor: .top)).combined(
                  with: .offset(y: -10)),
                removal: .opacity.combined(with: .scale(scale: 0.8, anchor: .top)).combined(
                  with: .offset(y: -10))
              )
            )
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showDropdown)
          }
        }
      }
    }
    .frame(width: menuWidth, height: buttonHeight, alignment: .top)
    .zIndex(100)
  }
}

// MARK: - Enhanced Filter Option Row
struct OptionRow<T: Identifiable>: View {
  let item: T
  let isSelected: Bool
  let displayName: (T) -> String
  let displayIcon: (T) -> Image?
  let onTap: () -> Void

  var body: some View {
    Button(action: onTap) {
      HStack(spacing: 8) {
        if let icon = displayIcon(item) {
          icon.resizable()
            .frame(width: 20, height: 20)
        }
        Text(displayName(item))
          .foregroundColor(Colors.textPrimary.swiftUIColor)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
      }
      .padding(.horizontal, 10)
      .padding(.vertical, 8)
    }
  }
}

// MARK: - Convenience Initializers
public extension DropdownView {
  /// Simple dropdown without subtitles
  static func simple(
    items: [T],
    selectedItem: Binding<T?>,
    showDropdown: Binding<Bool>,
    onItemSelected: @escaping (T) -> Void,
    itemDisplayName: @escaping (T) -> String,
    itemDisplayIcon: @escaping (T) -> Image?
  ) -> DropdownView<T> {
    return DropdownView(
      selectedItem: selectedItem,
      showDropdown: showDropdown,
      items: items,
      onItemSelected: onItemSelected,
      itemDisplayName: itemDisplayName,
      itemDisplayIcon: itemDisplayIcon
    )
  }
}
