import SwiftUI

// MARK: - View Extension
public extension View {
  func sheetWithContentHeight<Content: View>(
    isPresented: Binding<Bool>,
    backgroundColor: Color? = nil,
    interactiveDismissDisabled: Bool = false,
    onDismiss: (() -> Void)? = nil,
    @ViewBuilder content: @escaping () -> Content
  ) -> some View {
    self.sheet(isPresented: isPresented, onDismiss: onDismiss) {
      SheetContentWithHeight(
        backgroundColor: backgroundColor,
        content: content()
      )
      .interactiveDismissDisabled(interactiveDismissDisabled)
    }
  }
  
  func sheetWithContentHeight<Item: Identifiable, Content: View>(
    item: Binding<Item?>,
    backgroundColor: Color? = nil,
    interactiveDismissDisabled: Bool = false,
    onDismiss: ((Item?) -> Void)? = nil,
    @ViewBuilder content: @escaping (Item) -> Content
  ) -> some View {
    self.sheet(
      item: item,
      onDismiss: {
        onDismiss?(item.wrappedValue)
      }
    ) { value in
      SheetContentWithHeight(
        backgroundColor: backgroundColor,
        content: content(value)
      )
      .interactiveDismissDisabled(interactiveDismissDisabled)
    }
  }
}

private struct SheetContentWithHeight<Content: View>: View {
  let backgroundColor: Color?
  let content: Content
  
  @State private var contentHeight: CGFloat = 500
  
  var body: some View {
    ScrollView(showsIndicators: false) {
      content
        .readGeometry { proxy in
          let measuredHeight = proxy.size.height
          if measuredHeight > 0 {
            contentHeight = measuredHeight
          }
        }
        .presentationDetents([.height(contentHeight)])
        .presentationDragIndicator(.hidden)
    }
    .background(backgroundColor ?? Colors.grey900.swiftUIColor)
  }
}
