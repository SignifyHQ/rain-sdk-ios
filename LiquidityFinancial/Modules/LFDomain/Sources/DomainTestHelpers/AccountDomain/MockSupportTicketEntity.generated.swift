// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import AccountDomain

public class MockSupportTicketEntity: SupportTicketEntity {

    public init() {}

    public var id: String {
        get { return underlyingId }
        set(value) { underlyingId = value }
    }
    public var underlyingId: String!
    public var userId: String {
        get { return underlyingUserId }
        set(value) { underlyingUserId = value }
    }
    public var underlyingUserId: String!
    public var title: String?
    public var description: String?
    public var type: String?
    public var status: String {
        get { return underlyingStatus }
        set(value) { underlyingStatus = value }
    }
    public var underlyingStatus: String!
    public var createdAt: String?
    public var updatedAt: String?
    public var deletedAt: String?

}
