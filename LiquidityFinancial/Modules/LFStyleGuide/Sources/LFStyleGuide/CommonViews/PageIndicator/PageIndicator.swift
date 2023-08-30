import SwiftUI

  // MARK: - Dot Indicator -
public struct DotIndicator: View {
  let minScale: CGFloat = 1
  let maxScale: CGFloat = 1.35
  let minOpacity: Double = 0.5
  
  let pageIndex: Int
  @Binding var slectedPage: Int
  
  public var body: some View {
    
    Button {
      self.slectedPage = self.pageIndex
    } label: {
      Text("\(pageIndex)")
        .padding(slectedPage == pageIndex ? 8 : 4)
        .font(Fonts.medium.swiftUIFont(size: slectedPage == pageIndex ? 15 : 13))
        .background(
          Circle()
            .fill(
              slectedPage == pageIndex
              ? Colors.primary.swiftUIColor
              : Colors.primary.swiftUIColor.opacity(minOpacity)
            )
        )
        .foregroundColor(
          slectedPage == pageIndex
          ? Colors.label.swiftUIColor
          : Colors.label.swiftUIColor.opacity(minOpacity)
        )
        .animation(.spring(), value: 1.3)
    }
  }
}

// MARK: - Page Indicator -
public struct PageIndicator: View {
    // Constants
  private let spacing: CGFloat = 2
  private let diameter: CGFloat = 8
  
    // Settings
  let numPages: Int
  @Binding var selectedIndex: Int
  
  public init(numPages: Int, currentPage: Binding<Int>) {
    self.numPages = numPages
    self._selectedIndex = currentPage
  }
  
  public var body: some View {
    VStack {
      HStack(alignment: .center, spacing: 3) {
        ForEach(0 ..< numPages, id: \.self) {
          DotIndicator(
            pageIndex: $0,
            slectedPage: self.$selectedIndex
          )
        }
        .padding(.horizontal, 5)
      }
    }
  }
}
