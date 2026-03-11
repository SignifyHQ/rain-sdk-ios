import SwiftUI
import RainSDK

struct GetBalancesDemoView: View {
  @StateObject private var viewModel = GetBalancesDemoViewModel()
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    ScrollView {
      VStack(spacing: 24) {
        headerSection
        statusSection
        inputSection
        fetchSection
        if !viewModel.balances.isEmpty {
          balancesSection
        }
      }
      .padding()
    }
    .navigationTitle("Get Balances")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button("Done") {
          dismiss()
        }
      }
    }
  }

  // MARK: - Header

  private var headerSection: some View {
    VStack(spacing: 8) {
      Image(systemName: "dollarsign.circle.fill")
        .font(.system(size: 50))
        .foregroundColor(.blue)

      Text("Get Balances")
        .font(.title2)
        .fontWeight(.bold)

      Text("Fetch native and ERC-20 token balances for the current wallet")
        .font(.subheadline)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
    }
    .padding(.vertical)
  }

  // MARK: - Status

  private var statusSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Circle()
          .fill(
            viewModel.isLoading
              ? Color.orange
              : (viewModel.balances.isEmpty ? Color.gray : Color.green)
          )
          .frame(width: 12, height: 12)

        Text(viewModel.statusMessage)
          .font(.body)
      }

      if let error = viewModel.error {
        Text("Error: \(error.localizedDescription)")
          .font(.caption)
          .foregroundColor(.red)
          .padding(8)
          .frame(maxWidth: .infinity, alignment: .leading)
          .background(Color.red.opacity(0.1))
          .cornerRadius(8)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }

  // MARK: - Input

  private var inputSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Chain ID")
        .font(.subheadline)
        .foregroundColor(.secondary)

      TextField("e.g. 43113 (Avalanche Fuji), 1 (Ethereum)", text: $viewModel.chainId)
        .textFieldStyle(.roundedBorder)
        .keyboardType(.numberPad)
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }

  // MARK: - Fetch

  private var fetchSection: some View {
    Button(action: {
      Task { await viewModel.fetchBalances() }
    }) {
      HStack {
        if viewModel.isLoading {
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
        } else {
          Image(systemName: "arrow.clockwise.circle.fill")
        }
        Text("Get Balances")
      }
      .frame(maxWidth: .infinity)
      .padding()
      .background(viewModel.canFetch ? Color.blue : Color.gray)
      .foregroundColor(.white)
      .cornerRadius(12)
    }
    .disabled(!viewModel.canFetch || viewModel.isLoading)
  }

  // MARK: - Balances list

  private var balancesSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Balances")
        .font(.headline)

      VStack(spacing: 0) {
        ForEach(viewModel.sortedEntries, id: \.key) { entry in
          HStack {
            Text(GetBalancesDemoViewModel.label(for: entry.key))
              .font(.system(.subheadline, design: .monospaced))
            Spacer()
            Text(formatBalance(entry.value))
              .font(.subheadline)
              .fontWeight(.medium)
          }
          .padding(.vertical, 10)
          .padding(.horizontal, 12)

          if entry.key != viewModel.sortedEntries.last?.key {
            Divider()
          }
        }
      }
      .background(Color(.systemBackground))
      .cornerRadius(8)
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }

  private func formatBalance(_ value: Double) -> String {
    if value >= 1_000_000 {
      return String(format: "%.2f", value)
    }
    if value >= 1 {
      return String(format: "%.4f", value)
    }
    if value > 0 {
      return String(format: "%.6f", value)
    }
    return "0"
  }
}

#Preview {
  NavigationStack {
    GetBalancesDemoView()
  }
}
