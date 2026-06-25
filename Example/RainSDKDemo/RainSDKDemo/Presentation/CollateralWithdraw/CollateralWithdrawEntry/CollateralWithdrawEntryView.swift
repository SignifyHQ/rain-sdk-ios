import SwiftUI

/// Entry for Collateral Withdraw: the Rain Api-Key + User ID are required to mint a Client
/// Session Token and load collateral contracts and withdrawal signatures.
struct CollateralWithdrawEntryView: View {
  @StateObject private var viewModel = CollateralWithdrawEntryViewModel()
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    ScrollView {
      VStack(spacing: 24) {
        headerSection
        inputSection
        if let error = viewModel.error {
          errorSection(error)
        }
        continueSection
      }
      .padding()
    }
    .navigationTitle("Collateral Withdraw")
    .navigationBarTitleDisplayMode(.inline)
    .navigationDestination(item: $viewModel.pendingContract) { contract in
      CollateralWithdrawDemoView(initialContract: contract, popToRoot: {
        viewModel.pendingContract = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { dismiss() }
      })
      .onDisappear { viewModel.pendingContract = nil }
    }
  }

  // MARK: - Header

  private var headerSection: some View {
    VStack(spacing: 8) {
      Image(systemName: "key.fill")
        .font(.system(size: 50))
        .foregroundColor(.blue)

      Text("Rain API Credentials")
        .font(.title2)
        .fontWeight(.bold)

      Text("Rain Api-Key and User ID required for collateral contracts and withdrawal signatures (CST flow). Wallet signing uses your initialized Portal or Turnkey provider.")
        .font(.subheadline)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
    }
    .padding(.vertical)
  }

  // MARK: - Input

  private var inputSection: some View {
    VStack(alignment: .leading, spacing: 16) {
      VStack(alignment: .leading, spacing: 8) {
        Text("Rain Api-Key")
          .font(.subheadline)
          .foregroundColor(.secondary)

        TextField("Enter Rain Api-Key", text: $viewModel.rainApiKey)
          .textFieldStyle(.roundedBorder)
          .autocapitalization(.none)
          .disableAutocorrection(true)
      }

      VStack(alignment: .leading, spacing: 8) {
        Text("Rain User ID")
          .font(.subheadline)
          .foregroundColor(.secondary)

        TextField("Enter Rain User ID", text: $viewModel.userId)
          .textFieldStyle(.roundedBorder)
          .autocapitalization(.none)
          .disableAutocorrection(true)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }

  private func errorSection(_ error: Error) -> some View {
    HStack {
      Text("Error: \(error.localizedDescription)")
        .font(.caption)
        .foregroundColor(.red)
      Spacer()
      Button("Dismiss") {
        hideKeyboard()
        viewModel.clearError()
      }
        .font(.caption)
    }
    .padding()
    .background(Color.red.opacity(0.1))
    .cornerRadius(12)
  }

  // MARK: - Continue

  private var continueSection: some View {
    Button(action: {
      hideKeyboard()
      Task {
        await viewModel.verifyAndContinue()
      }
    }) {
      HStack {
        if viewModel.isLoading {
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
        } else {
          Image(systemName: "arrow.down.circle.fill")
        }
        Text("Continue to Collateral Withdraw")
      }
      .frame(maxWidth: .infinity)
      .padding()
      .background(Color.blue)
      .foregroundColor(.white)
      .cornerRadius(12)
    }
    .disabled(!viewModel.canContinue || viewModel.isLoading)
    .opacity(viewModel.canContinue ? 1 : 0.6)
  }
}

#Preview {
  NavigationView {
    CollateralWithdrawEntryView()
  }
}
