import Combine
import SwiftUI
import AccountData
import LFStyleGuide

extension View {
  func swipeWalletCell(buttons: [SwipeWalletCellButton],
                       item: APIWalletAddress,
                       buttonWidth: CGFloat = 56,
                       buttonSpacing: CGFloat = 10,
                       appearWidth: CGFloat = 10,
                       dismissWidth: CGFloat = 10,
                       action: @escaping () -> Void) -> some View
  {
    modifier(
      SwipeWalletCellModifier(
        buttons: buttons,
        item: item,
        buttonWidth: buttonWidth,
        spacing: buttonSpacing,
        appearWidth: appearWidth,
        dismissWidth: dismissWidth,
        action: action
      )
    )
  }
}

struct SwipeWalletCellModifier: ViewModifier {
  @State private var shouldResetStatusOnAppear = true
  @State private var status: WalletCellStatus = .showCell
  @State private var offset: CGFloat = 0.0
  @State private var frameWidth: CGFloat = 0
  @State private var currentCellID: UUID? = nil
  @State private var cancellables: Set<AnyCancellable> = []

  private let cellID = UUID()
  private let buttons: [SwipeWalletCellButton]
  private let item: APIWalletAddress
  private let buttonWidth: CGFloat
  private let spacing: CGFloat
  private let appearWidth: CGFloat
  private let dismissWidth: CGFloat
  private let action: (() -> Void)?
  private let appearAnimation: Animation = .easeOut(duration: 0.5)

  private var buttonsWidth: CGFloat {
    CGFloat(buttons.count) * buttonWidth
  }

  init(
    buttons: [SwipeWalletCellButton],
    item: APIWalletAddress,
    buttonWidth: CGFloat,
    spacing: CGFloat,
    appearWidth: CGFloat,
    dismissWidth: CGFloat,
    action: @escaping () -> Void
  ) {
    self.buttons = buttons
    self.item = item
    self.buttonWidth = buttonWidth
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
            slotView(with: buttons[index])
              .offset(
                x: cellOffset(index: index, count: buttons.count, width: proxy.frame(in: .local).width)
              )
              .padding(.leading, spacing)
              .zIndex(Double(index))
          }
        }
      }
      .zIndex(2)
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
extension SwipeWalletCellModifier {
  private func mainContent(content: Content) -> some View {
    ZStack(alignment: .leading) {
      Color.clear
      content
        .environment(\.walletCellStatus, status)
    }
    .zIndex(3)
    .highPriorityGesture(
      TapGesture(count: 1),
      including: currentCellID == nil ? .subviews : .none
    )
    .contentShape(Rectangle())
    .onTapGesture {
      action?()
      if currentCellID != nil {
        resetStatus()
        dismissNotification()
      }
    }
    .offset(x: offset)
  }

  private func slotView(with button: SwipeWalletCellButton) -> some View {
    SquareButton(
      image: button.image,
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

// MARK: - UI Helpers

extension SwipeWalletCellModifier {
  private func cellOffset(index: Int, count: Int, width: CGFloat) -> CGFloat {
    if frameWidth == 0 {
      DispatchQueue.main.async {
        frameWidth = width
      }
    }
    let cellOffset = offset * (CGFloat(count - index) / CGFloat(count)) - (index == 0 ? 0 : 0)
    return width + cellOffset
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
      currentCellID = notice.object as? UUID ?? nil
    }
  }

  private func onAppear() {
    if shouldResetStatusOnAppear {
      resetStatus()
    }
  }
}

// MARK: - Drag Gesture

extension SwipeWalletCellModifier {
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
          offset = -(buttonsWidth + spacing * CGFloat(buttons.count))
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
