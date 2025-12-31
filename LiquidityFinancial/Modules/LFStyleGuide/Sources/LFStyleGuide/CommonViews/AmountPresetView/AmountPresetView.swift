import SwiftUI
import LFLocalizable
import LFUtilities

public struct AmountPresetView: View {
  @Binding private var selectedValue: AmountPresetItem?
  private let preFilledValues: [AmountPresetItem]
  private let action: ((AmountPresetItem) -> Void)?
  private let items: [GridItem] = Array(repeating: .init(.adaptive(minimum: 120)), count: 3)
  
  public init(selectedValue: Binding<AmountPresetItem?>, preFilledValues: [AmountPresetItem], action: @escaping ((AmountPresetItem) -> Void)) {
    _selectedValue = selectedValue
    self.preFilledValues = preFilledValues
    self.action = action
  }
  
  public var body: some View {
    LazyVGrid(columns: items, spacing: 12) {
      ForEach(preFilledValues, id: \.self) { recommendValue in
        Text(recommendValue.display)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(Colors.textPrimary.swiftUIColor)
          .padding(.horizontal, 20)
          .padding(.vertical, 16)
          .frame(maxWidth: .infinity)
          .background(
            Capsule()
              .stroke(
                selectedValue == recommendValue ? Colors.primary.swiftUIColor : Colors.greyDefault.swiftUIColor,
                lineWidth: 1
              )
          )
        .onTapGesture {
          action?(recommendValue)
        }
      }
    }
  }
}
