import Foundation

/// `RequestResponseExportOption` is the type used to handle different export representations of HTTP requests and responses collected by Wormholy.
enum RequestResponseExportOption {
  /// Export a request and its response in a "human" readable mode.
  case flat
  /// Request is exported as a cURL command; response is exported in a "human" readable mode.
  case curl
}
