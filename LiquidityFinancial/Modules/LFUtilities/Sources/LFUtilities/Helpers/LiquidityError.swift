import Foundation

public enum LiquidityError: Error {
  /// An error thrown when there is an error in the business logic that cannot be continued.
  case logic

  /// An error thrown when certain data or object cannot be initialized.
  case invalidData
}
