import Foundation

struct EncryptedField: Decodable {
    let iv: String
    let data: String
}

struct ActiveCard: Decodable {
    let id: String
    let userId: String
    let type: String
    let status: String
    let processorCardId: String
    let timeBasedSecret: String
    let encryptedPan: EncryptedField
    let encryptedCvc: EncryptedField
}
