import Combine
import SwiftUI
import AccountData
import LFStyleGuide

extension View {
  func walletSwipeCell(
    buttons: [WalletSwipeCellButton],
    item: APIWalletAddress? = nil,
    buttonWidth: CGFloat = 56,
    cornerRadius: CGFloat = 9,
    buttonSpacing: CGFloat = 10,
    appearWidth: CGFloat = 10,
    dismissWidth: CGFloat = 10,
    action: (() -> Void)? = nil
  ) -> some View {
    modifier(
      WalletSwipeCellModifier(
        buttons: buttons,
        item: item,
        buttonWidth: buttonWidth,
        cornerRadius: cornerRadius,
        spacing: buttonSpacing,
        appearWidth: appearWidth,
        dismissWidth: dismissWidth,
        action: action
      )
    )
  }
}

struct WalletSwipeCellModifier: ViewModifier {
  @State private var shouldResetStatusOnAppear = true
  @State private var status: WalletSwipeCellStatus = .showCell
  @State private var offset: CGFloat = 0.0
  @State private var frameWidth: CGFloat = 0
  @State private var currentCellID: UUID?
  @State private var cancellables: Set<AnyCancellable> = []
  
  private let cellID = UUID()
  private let buttons: [WalletSwipeCellButton]
  private let item: APIWalletAddress?
  private let buttonWidth: CGFloat
  private let cornerRadius: CGFloat
  private let spacing: CGFloat
  private let appearWidth: CGFloat
  private let dismissWidth: CGFloat
  private let action: (() -> Void)?
  private let appearAnimation: Animation = .easeOut(duration: 0.5)
  
  private var buttonsWidth: CGFloat {
    CGFloat(buttons.count) * buttonWidth
  }
  
  init(
    buttons: [WalletSwipeCellButton],
    item: APIWalletAddress?,
    buttonWidth: CGFloat,
    cornerRadius: CGFloat,
    spacing: CGFloat,
    appearWidth: CGFloat,
    dismissWidth: CGFloat,
    action: (() -> Void)?
  ) {
    self.buttons = buttons
    self.item = item
    self.buttonWidth = buttonWidth
    self.cornerRadius = cornerRadius
    self.spacing = spacing
    self.appearWidth = appearWidth
    self.dismissWidth = dismissWidth
    self.action = action
  }
  
  func body(content: Content) -> some View {
    ZStack(alignment: .topLeading) {
      GeometryReader { proxy in
        ZStack {
          ForEach(0 ..< buttons.count, id: \.self) { index in
            slotView(
              with: buttons[index],
              index: index,
              isRightmost: index == 0,
              cellHeight: proxy.frame(in: .local).height
            )
            .offset(
              x: cellOffset(index: index, count: buttons.count, width: proxy.frame(in: .local).width)
            )
            .padding(.leading, index == 0 ? 0 : spacing)
            .zIndex(status == .showRightSlot ? Double(10 + index) : Double(index))
          }
        }
      }
      .zIndex(status == .showRightSlot ? 4 : 2)
      
      mainContent(content: content)
    }
    .contentShape(Rectangle())
    .swipeCellGesture(onUpdate: onChangedDragGesture, onEnd: onEndedDragGesture)
    .clipShape(Rectangle())
    .onAppear(perform: onAppear)
    .onReceive(NotificationCenter.default.publisher(for: .swipeWalletCellReset), perform: onReceiveResetNotice)
    .listRowInsets(EdgeInsets())
  }
}

  // MARK: - View Components
extension WalletSwipeCellModifier {
  private func mainContent(content: Content) -> some View {
    ZStack(alignment: .leading) {
      Color.clear
      content
        .environment(\.walletSwipeCellStatus, status)
    }
    .zIndex(3)
    .contentShape(Rectangle())
    .allowsHitTesting(status == .showCell)
    .onTapGesture {
      action?()
      if currentCellID != nil {
        resetStatus()
        dismissNotification()
      }
    }
  }
  
  private func slotView(
    with button: WalletSwipeCellButton,
    index: Int,
    isRightmost: Bool,
    cellHeight: CGFloat
  ) -> some View {
    Button(action: {
      button.action(item)
      resetStatus()
    }) {
      if isRightmost {
        // Full-height button with rounded corners on the right side
        Rectangle()
          .fill(button.backgroundColor)
          .frame(width: buttonWidth, height: cellHeight)
          .cornerRadius(cornerRadius, corners: [.topRight, .bottomRight])
          .overlay {
            button.image
              .foregroundColor(.white)
          }
      } else {
        // Square button for other buttons
        SquareButton(
          image: button.image,
          edgeSize: buttonWidth,
          cornerSize: cornerRadius,
          backgroundColor: button.backgroundColor,
          action: {
            button.action(item)
            resetStatus()
          }
        )
        .contentShape(Rectangle())
        .frame(width: buttonWidth, height: buttonWidth)
      }
    }
    .buttonStyle(PlainButtonStyle())
    .contentShape(Rectangle())
    .allowsHitTesting(true)
  }
}

  // MARK: - UI Helpers

extension WalletSwipeCellModifier {
  private func cellOffset(index: Int, count: Int, width: CGFloat) -> CGFloat {
    if frameWidth == 0 {
      DispatchQueue.main.async {
        frameWidth = width
      }
    }
    
    if index == 0 {
      // Rightmost button (delete) should align with the right edge when fully revealed
      // When offset = -buttonsWidth, button should be at width - buttonWidth
      return width + offset
    } else {
      // Other buttons positioned to the left of the rightmost button
      // They should move proportionally with the offset
      let rightmostPosition = width + offset
      let spacingOffset = spacing * CGFloat(index)
      return rightmostPosition - (buttonWidth * CGFloat(index)) - spacingOffset
    }
  }
  
    /// Set the status and associated values to ``CellStatus.showCell``
  private func resetStatus() {
    status = .showCell
    withAnimation(.easeInOut) {
      offset = 0
    }
    cancellables.removeAll()
    currentCellID = nil
    shouldResetStatusOnAppear = false
  }
  
  private func dismissNotification() {
    NotificationCenter.default.post(name: .swipeWalletCellReset, object: nil)
  }
  
  private func onReceiveResetNotice(notice: NotificationCenter.Publisher.Output) {
    if cellID != notice.object as? UUID {
      resetStatus()
      currentCellID = notice.object as? UUID
    }
  }
  
  private func onAppear() {
    if shouldResetStatusOnAppear {
      resetStatus()
    }
  }
}

  // MARK: - Drag Gesture

extension WalletSwipeCellModifier {
  private func onChangedDragGesture(value: DragGesture.Value) {
    cancellables.removeAll()
    shouldResetStatusOnAppear = false
    
    var width = value.translation.width
    if currentCellID != cellID {
      currentCellID = cellID
      NotificationCenter.default.post(Notification(name: .swipeWalletCellReset, object: cellID))
    }
    
    switch status {
    case .showCell:
      width = min(0, width)
      withAnimation(.easeInOut) {
        offset = (width < 0 && width < -buttonsWidth) ? (width - buttonsWidth) / 2 : width
      }
    case .showRightSlot:
      withAnimation(.easeInOut) {
        offset = (width > 0 ? width : width / 10) - buttonsWidth
      }
    }
  }
  
  private func onEndedDragGesture(width: Double) {
    if currentCellID != cellID {
      currentCellID = cellID
      NotificationCenter.default.post(Notification(name: .swipeWalletCellReset, object: cellID))
    }
    switch status {
    case .showCell:
      if abs(width) < appearWidth {
        resetStatus()
        return
      }
      if width <= appearWidth {
        withAnimation(appearAnimation) {
          // Only count spacing for buttons that have spacing (exclude rightmost button)
          let spacingWidth = buttons.count > 1 ? spacing * CGFloat(buttons.count - 1) : 0
          offset = -(buttonsWidth + spacingWidth)
          status = .showRightSlot
        }
      }
    case .showRightSlot:
      if width > 0, width >= dismissWidth {
        resetStatus()
        return
      }
      withAnimation(appearAnimation) {
        offset = -buttonsWidth
        status = .showRightSlot
      }
    }
  }
}
