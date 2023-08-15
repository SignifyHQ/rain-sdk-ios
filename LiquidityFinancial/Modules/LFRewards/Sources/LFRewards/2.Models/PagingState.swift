import Foundation

enum PagingState: Equatable {
  case idle
  case loadingFirstPage
  case loadingNextPage
  case loaded
  case failure
  
    /// The threshold from which to start loading next page.
    /// For example: if the first page has 10 items, we will load the second page when item 7 is shown.
  static let threshold = 3
}
