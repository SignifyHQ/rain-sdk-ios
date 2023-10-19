// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import AccountDomain

public class MockRewardEntity: RewardEntity {

    public init() {}

    public var status: String {
        get { return underlyingStatus }
        set(value) { underlyingStatus = value }
    }
    public var underlyingStatus: String!
    public var type: String?
    public var amount: Double?
    public var stickerUrl: String?
    public var backgroundColor: String?
    public var description: String?
    public var fundraiserName: String?
    public var charityName: String?

    //MARK: - init

    public var initStatusTypeAmountStickerUrlBackgroundColorDescriptionFundraiserNameCharityNameReceivedArguments: (status: String, type: String?, amount: Double?, stickerUrl: String?, backgroundColor: String?, description: String?, fundraiserName: String?, charityName: String?)?
    public var initStatusTypeAmountStickerUrlBackgroundColorDescriptionFundraiserNameCharityNameReceivedInvocations: [(status: String, type: String?, amount: Double?, stickerUrl: String?, backgroundColor: String?, description: String?, fundraiserName: String?, charityName: String?)] = []
    public var initStatusTypeAmountStickerUrlBackgroundColorDescriptionFundraiserNameCharityNameClosure: ((String, String?, Double?, String?, String?, String?, String?, String?) -> Void)?

    public required init(status: String, type: String?, amount: Double?, stickerUrl: String?, backgroundColor: String?, description: String?, fundraiserName: String?, charityName: String?) {
        initStatusTypeAmountStickerUrlBackgroundColorDescriptionFundraiserNameCharityNameReceivedArguments = (status: status, type: type, amount: amount, stickerUrl: stickerUrl, backgroundColor: backgroundColor, description: description, fundraiserName: fundraiserName, charityName: charityName)
        initStatusTypeAmountStickerUrlBackgroundColorDescriptionFundraiserNameCharityNameReceivedInvocations.append((status: status, type: type, amount: amount, stickerUrl: stickerUrl, backgroundColor: backgroundColor, description: description, fundraiserName: fundraiserName, charityName: charityName))
        initStatusTypeAmountStickerUrlBackgroundColorDescriptionFundraiserNameCharityNameClosure?(status, type, amount, stickerUrl, backgroundColor, description, fundraiserName, charityName)
    }
}
