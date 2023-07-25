import SwiftUI
import LFLocalizable
import LFStyleGuide
import LFUtilities

struct PreFilledGridView: View {
  @Binding private var selectedValue: GridValue?
  private let preFilledValues: [GridValue]
  private let action: ((GridValue) -> Void)?
  private let items: [GridItem] = Array(repeating: .init(.adaptive(minimum: 120)), count: 3)

  init(selectedValue: Binding<GridValue?>, preFilledValues: [GridValue], action: @escaping ((GridValue) -> Void)) {
    _selectedValue = selectedValue
    self.preFilledValues = preFilledValues
    self.action = action
  }

  var body: some View {
    LazyVGrid(columns: items, spacing: 10) {
      ForEach(preFilledValues, id: \.self) { recommendValue in
        ZStack {
          Rectangle()
            .fill(Colors.primary.swiftUIColor)
            .frame(maxWidth: .infinity)
            .cornerRadius(10)
            .padding(selectedValue == recommendValue ? -1 : 2)
          Text(recommendValue.display)
            .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.small.value))
            .foregroundColor(Colors.label.swiftUIColor)
            .frame(height: 56)
            .frame(maxWidth: .infinity)
            .background(Colors.secondaryBackground.swiftUIColor)
            .cornerRadius(10)
        }
        .onTapGesture {
          action?(recommendValue)
        }
      }
    }
  }
}
