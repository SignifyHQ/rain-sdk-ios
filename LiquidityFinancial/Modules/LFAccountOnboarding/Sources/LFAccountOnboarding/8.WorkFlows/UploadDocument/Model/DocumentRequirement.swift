import Foundation

struct DocumentRequirement: Identifiable {
  let id = UUID()
  let title: String
  let details: [String]
}
