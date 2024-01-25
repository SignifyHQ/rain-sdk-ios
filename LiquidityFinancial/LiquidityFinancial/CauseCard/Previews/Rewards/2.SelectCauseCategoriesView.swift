import SwiftUI
import LFRewards
import LFUtilities

var causeModel: [CauseModel] {
  let models = FileHelpers.readJSONFile(forName: "CauseCategory", type: [CauseModel].self)
  return models ?? []
}

#Preview {
  SelectCauseCategoriesView(viewModel: SelectCauseCategoriesViewModel(causes: causeModel))
    .embedInNavigation()
}
