import SwiftUI
import PortalSwift

/// Alert-style popup: choose iCloud or password to recover wallet. Shown after opening Portal Withdraw (access token from entry view).
struct RecoverChoiceView: View {
  @ObservedObject var viewModel: RecoverViewModel

  private static let recoverOptions: [BackupMethods] = [.iCloud, .Password]

  var body: some View {
    VStack(spacing: 20) {
      Text("Recover Wallet")
        .font(.headline)

      Text("Would you like to recover your wallet from a backup?")
        .font(.subheadline)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)

      HStack {
        Text("Recovery method")
          .font(.subheadline)
          .foregroundColor(.secondary)
        Spacer()
        Picker("Method", selection: Binding(
          get: { viewModel.selectedRecoverMethod ?? .iCloud },
          set: { viewModel.selectRecoverMethod($0) }
        )) {
          ForEach(RecoverChoiceView.recoverOptions, id: \.self) { method in
            Text(methodDisplayName(method)).tag(method)
          }
        }
        .pickerStyle(.menu)
      }

      if viewModel.selectedRecoverMethod == .Password {
        VStack(alignment: .leading, spacing: 8) {
          Text("Password")
            .font(.subheadline)
            .foregroundColor(.secondary)
          SecureField("Enter password", text: $viewModel.recoverPassword)
            .textFieldStyle(.roundedBorder)
            .autocapitalization(.none)
        }
      }

      if let error = viewModel.recoverError {
        Text(error.localizedDescription)
          .font(.caption)
          .foregroundColor(.red)
          .padding(8)
          .frame(maxWidth: .infinity, alignment: .leading)
          .background(Color.red.opacity(0.1))
          .cornerRadius(8)
      }

      HStack(spacing: 12) {
        Button("Skip") {
          viewModel.dismissRecoverSheet()
        }
        .buttonStyle(.bordered)

        Button {
          Task { await viewModel.performRecover() }
        } label: {
          HStack {
            if viewModel.isRecovering {
              ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else {
              Text("Recover")
            }
          }
          .frame(maxWidth: .infinity)
          .padding(.vertical, 8)
        }
        .buttonStyle(.borderedProminent)
        .disabled(
          viewModel.isRecovering
          || (viewModel.selectedRecoverMethod == .Password && viewModel.recoverPassword.isEmpty)
        )
      }
    }
    .padding(24)
    .frame(width: 320)
    .background(Color(.systemBackground))
    .cornerRadius(16)
    .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
  }

  private func methodDisplayName(_ method: BackupMethods) -> String {
    switch method {
    case .iCloud: return "iCloud"
    case .Password: return "Password"
    default: return "\(method)"
    }
  }
}

#Preview {
  RecoverChoiceView(viewModel: RecoverViewModel())
}
