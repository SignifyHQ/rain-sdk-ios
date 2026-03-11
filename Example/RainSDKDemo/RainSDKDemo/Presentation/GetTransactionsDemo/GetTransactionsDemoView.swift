import SwiftUI
import RainSDK

struct GetTransactionsDemoView: View {
  @StateObject private var viewModel = GetTransactionsDemoViewModel()
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    ScrollView {
      VStack(spacing: 24) {
        headerSection
        statusSection
        inputSection
        fetchSection
        if !viewModel.transactions.isEmpty {
          transactionsSection
        }
      }
      .padding()
    }
    .navigationTitle("Get Transactions")
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
      Image(systemName: "list.bullet.rectangle.fill")
        .font(.system(size: 50))
        .foregroundColor(.blue)

      Text("Get Transactions")
        .font(.title2)
        .fontWeight(.bold)

      Text("Fetch transaction history for the current wallet")
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
              : (viewModel.transactions.isEmpty ? Color.gray : Color.green)
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
    VStack(alignment: .leading, spacing: 12) {
      VStack(alignment: .leading, spacing: 8) {
        Text("Chain ID")
          .font(.subheadline)
          .foregroundColor(.secondary)
        TextField("e.g. 43113, 1", text: $viewModel.chainId)
          .textFieldStyle(.roundedBorder)
          .keyboardType(.numberPad)
      }

      VStack(alignment: .leading, spacing: 8) {
        Text("Limit")
          .font(.subheadline)
          .foregroundColor(.secondary)
        TextField("e.g. 20", text: $viewModel.limit)
          .textFieldStyle(.roundedBorder)
          .keyboardType(.numberPad)
      }

      VStack(alignment: .leading, spacing: 8) {
        Text("Order")
          .font(.subheadline)
          .foregroundColor(.secondary)
        Picker("Order", selection: $viewModel.orderOption) {
          Text("Newest first").tag(WalletTransactionOrder.DESC)
          Text("Oldest first").tag(WalletTransactionOrder.ASC)
        }
        .pickerStyle(.menu)
      }
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }

  // MARK: - Fetch

  private var fetchSection: some View {
    Button(action: {
      Task { await viewModel.fetchTransactions() }
    }) {
      HStack {
        if viewModel.isLoading {
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
        } else {
          Image(systemName: "arrow.clockwise.circle.fill")
        }
        Text("Get Transactions")
      }
      .frame(maxWidth: .infinity)
      .padding()
      .background(viewModel.canFetch ? Color.blue : Color.gray)
      .foregroundColor(.white)
      .cornerRadius(12)
    }
    .disabled(!viewModel.canFetch || viewModel.isLoading)
  }

  // MARK: - Transactions list

  private var transactionsSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Transactions")
        .font(.headline)

      LazyVStack(spacing: 0) {
        ForEach(Array(viewModel.transactions.enumerated()), id: \.element.uniqueId) { _, tx in
          transactionRow(tx)
          if tx.uniqueId != viewModel.transactions.last?.uniqueId {
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

  private func transactionRow(_ tx: WalletTransaction) -> some View {
    VStack(alignment: .leading, spacing: 6) {
      HStack {
        Text(shortHash(tx.hash))
          .font(.system(.caption, design: .monospaced))
        Spacer()
        if let value = tx.value {
          Text(String(format: "%.4f", value))
            .font(.subheadline)
            .fontWeight(.medium)
        }
      }
      Text(tx.category)
        .font(.caption2)
        .foregroundColor(.secondary)
      if let asset = tx.asset, !asset.isEmpty {
        Text(asset)
          .font(.caption2)
          .foregroundColor(.secondary)
      }
      Text(tx.metadata.blockTimestamp)
        .font(.caption2)
        .foregroundColor(.secondary)
    }
    .padding(.vertical, 10)
    .padding(.horizontal, 12)
  }

  private func shortHash(_ hash: String) -> String {
    guard hash.count > 12 else { return hash }
    return "\(hash.prefix(6))...\(hash.suffix(6))"
  }
}

#Preview {
  NavigationStack {
    GetTransactionsDemoView()
  }
}
