final class TokenizationReceiptStore {
  static let shared = TokenizationReceiptStore()
  private init() {}
  
  private var store: [String: String] = [:]
  
  func save(_ receipt: String, for identifier: String) {
    store[identifier] = receipt
  }
  
  func retrieve(for identifier: String) -> String? {
    store[identifier]
  }
  
  func clear() {
    store.removeAll()
  }
}
