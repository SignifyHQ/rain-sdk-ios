import SwiftUI

/// View shown before Portal Withdraw: user enters access token, verifies by loading credit contracts, then continues to Portal Withdraw.
struct PortalWithdrawEntryView: View {
  @StateObject private var viewModel = PortalWithdrawEntryViewModel()

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
    .navigationTitle("Portal Withdraw")
    .navigationBarTitleDisplayMode(.inline)
    .navigationDestination(item: $viewModel.navigationRoute) { route in
      destinationView(for: route)
    }
  }

  @ViewBuilder
  private func destinationView(for route: PortalWithdrawEntryViewModel.PortalWithdrawRoute) -> some View {
    switch route {
    case .portalWithdraw(let contract):
      PortalWithdrawDemoView(initialContract: contract)
        .onDisappear {
          viewModel.navigationRoute = nil
        }
    }
  }

  // MARK: - Header

  private var headerSection: some View {
    VStack(spacing: 8) {
      Image(systemName: "key.fill")
        .font(.system(size: 50))
        .foregroundColor(.blue)

      Text("User Access Token")
        .font(.title2)
        .fontWeight(.bold)

      Text("Enter your access token to continue to Portal Withdraw")
        .font(.subheadline)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
    }
    .padding(.vertical)
  }

  // MARK: - Input

  private var inputSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("User Access Token")
        .font(.subheadline)
        .foregroundColor(.secondary)

      TextField("Enter user access token", text: $viewModel.userAccessToken)
        .textFieldStyle(.roundedBorder)
        .autocapitalization(.none)
        .disableAutocorrection(true)
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
        await viewModel.verifyAndLoadContracts()
      }
    }) {
      HStack {
        if viewModel.isLoading {
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
        } else {
          Image(systemName: "arrow.right.circle.fill")
        }
        Text("Continue to Portal Withdraw")
      }
      .frame(maxWidth: .infinity)
      .padding()
      .background(Color.blue)
      .foregroundColor(.white)
      .cornerRadius(12)
    }
    .disabled(viewModel.userAccessToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading)
    .opacity(viewModel.userAccessToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1)
  }
}

#Preview {
  NavigationView {
    PortalWithdrawEntryView()
  }
}
