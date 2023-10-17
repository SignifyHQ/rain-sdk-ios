// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import AccountData
import Foundation
import RewardData

public class MockRewardAPIProtocol: RewardAPIProtocol {

    public init() {}


    //MARK: - selectRewardType

    public var selectRewardTypeBodyThrowableError: Error?
    public var selectRewardTypeBodyCallsCount = 0
    public var selectRewardTypeBodyCalled: Bool {
        return selectRewardTypeBodyCallsCount > 0
    }
    public var selectRewardTypeBodyReceivedBody: [String: Any]?
    public var selectRewardTypeBodyReceivedInvocations: [[String: Any]] = []
    public var selectRewardTypeBodyReturnValue: APIUser!
    public var selectRewardTypeBodyClosure: (([String: Any]) async throws -> APIUser)?

    public func selectRewardType(body: [String: Any]) async throws -> APIUser {
        if let error = selectRewardTypeBodyThrowableError {
            throw error
        }
        selectRewardTypeBodyCallsCount += 1
        selectRewardTypeBodyReceivedBody = body
        selectRewardTypeBodyReceivedInvocations.append(body)
        if let selectRewardTypeBodyClosure = selectRewardTypeBodyClosure {
            return try await selectRewardTypeBodyClosure(body)
        } else {
            return selectRewardTypeBodyReturnValue
        }
    }

    //MARK: - getDonationCategories

    public var getDonationCategoriesLimitOffsetThrowableError: Error?
    public var getDonationCategoriesLimitOffsetCallsCount = 0
    public var getDonationCategoriesLimitOffsetCalled: Bool {
        return getDonationCategoriesLimitOffsetCallsCount > 0
    }
    public var getDonationCategoriesLimitOffsetReceivedArguments: (limit: Int, offset: Int)?
    public var getDonationCategoriesLimitOffsetReceivedInvocations: [(limit: Int, offset: Int)] = []
    public var getDonationCategoriesLimitOffsetReturnValue: APIRewardCategoriesList!
    public var getDonationCategoriesLimitOffsetClosure: ((Int, Int) async throws -> APIRewardCategoriesList)?

    public func getDonationCategories(limit: Int, offset: Int) async throws -> APIRewardCategoriesList {
        if let error = getDonationCategoriesLimitOffsetThrowableError {
            throw error
        }
        getDonationCategoriesLimitOffsetCallsCount += 1
        getDonationCategoriesLimitOffsetReceivedArguments = (limit: limit, offset: offset)
        getDonationCategoriesLimitOffsetReceivedInvocations.append((limit: limit, offset: offset))
        if let getDonationCategoriesLimitOffsetClosure = getDonationCategoriesLimitOffsetClosure {
            return try await getDonationCategoriesLimitOffsetClosure(limit, offset)
        } else {
            return getDonationCategoriesLimitOffsetReturnValue
        }
    }

    //MARK: - getCategoriesFundraisers

    public var getCategoriesFundraisersCategoryIDLimitOffsetThrowableError: Error?
    public var getCategoriesFundraisersCategoryIDLimitOffsetCallsCount = 0
    public var getCategoriesFundraisersCategoryIDLimitOffsetCalled: Bool {
        return getCategoriesFundraisersCategoryIDLimitOffsetCallsCount > 0
    }
    public var getCategoriesFundraisersCategoryIDLimitOffsetReceivedArguments: (categoryID: String, limit: Int, offset: Int)?
    public var getCategoriesFundraisersCategoryIDLimitOffsetReceivedInvocations: [(categoryID: String, limit: Int, offset: Int)] = []
    public var getCategoriesFundraisersCategoryIDLimitOffsetReturnValue: APICategoriesFundraisersList!
    public var getCategoriesFundraisersCategoryIDLimitOffsetClosure: ((String, Int, Int) async throws -> APICategoriesFundraisersList)?

    public func getCategoriesFundraisers(categoryID: String, limit: Int, offset: Int) async throws -> APICategoriesFundraisersList {
        if let error = getCategoriesFundraisersCategoryIDLimitOffsetThrowableError {
            throw error
        }
        getCategoriesFundraisersCategoryIDLimitOffsetCallsCount += 1
        getCategoriesFundraisersCategoryIDLimitOffsetReceivedArguments = (categoryID: categoryID, limit: limit, offset: offset)
        getCategoriesFundraisersCategoryIDLimitOffsetReceivedInvocations.append((categoryID: categoryID, limit: limit, offset: offset))
        if let getCategoriesFundraisersCategoryIDLimitOffsetClosure = getCategoriesFundraisersCategoryIDLimitOffsetClosure {
            return try await getCategoriesFundraisersCategoryIDLimitOffsetClosure(categoryID, limit, offset)
        } else {
            return getCategoriesFundraisersCategoryIDLimitOffsetReturnValue
        }
    }

    //MARK: - getFundraisersDetail

    public var getFundraisersDetailFundraiserIDThrowableError: Error?
    public var getFundraisersDetailFundraiserIDCallsCount = 0
    public var getFundraisersDetailFundraiserIDCalled: Bool {
        return getFundraisersDetailFundraiserIDCallsCount > 0
    }
    public var getFundraisersDetailFundraiserIDReceivedFundraiserID: String?
    public var getFundraisersDetailFundraiserIDReceivedInvocations: [String] = []
    public var getFundraisersDetailFundraiserIDReturnValue: APIFundraisersDetail!
    public var getFundraisersDetailFundraiserIDClosure: ((String) async throws -> APIFundraisersDetail)?

    public func getFundraisersDetail(fundraiserID: String) async throws -> APIFundraisersDetail {
        if let error = getFundraisersDetailFundraiserIDThrowableError {
            throw error
        }
        getFundraisersDetailFundraiserIDCallsCount += 1
        getFundraisersDetailFundraiserIDReceivedFundraiserID = fundraiserID
        getFundraisersDetailFundraiserIDReceivedInvocations.append(fundraiserID)
        if let getFundraisersDetailFundraiserIDClosure = getFundraisersDetailFundraiserIDClosure {
            return try await getFundraisersDetailFundraiserIDClosure(fundraiserID)
        } else {
            return getFundraisersDetailFundraiserIDReturnValue
        }
    }

    //MARK: - selectFundraiser

    public var selectFundraiserBodyThrowableError: Error?
    public var selectFundraiserBodyCallsCount = 0
    public var selectFundraiserBodyCalled: Bool {
        return selectFundraiserBodyCallsCount > 0
    }
    public var selectFundraiserBodyReceivedBody: [String: Any]?
    public var selectFundraiserBodyReceivedInvocations: [[String: Any]] = []
    public var selectFundraiserBodyReturnValue: APISelectFundraiser!
    public var selectFundraiserBodyClosure: (([String: Any]) async throws -> APISelectFundraiser)?

    public func selectFundraiser(body: [String: Any]) async throws -> APISelectFundraiser {
        if let error = selectFundraiserBodyThrowableError {
            throw error
        }
        selectFundraiserBodyCallsCount += 1
        selectFundraiserBodyReceivedBody = body
        selectFundraiserBodyReceivedInvocations.append(body)
        if let selectFundraiserBodyClosure = selectFundraiserBodyClosure {
            return try await selectFundraiserBodyClosure(body)
        } else {
            return selectFundraiserBodyReturnValue
        }
    }

    //MARK: - setRoundUpDonation

    public var setRoundUpDonationBodyThrowableError: Error?
    public var setRoundUpDonationBodyCallsCount = 0
    public var setRoundUpDonationBodyCalled: Bool {
        return setRoundUpDonationBodyCallsCount > 0
    }
    public var setRoundUpDonationBodyReceivedBody: [String: Any]?
    public var setRoundUpDonationBodyReceivedInvocations: [[String: Any]] = []
    public var setRoundUpDonationBodyReturnValue: APIRoundUpDonation!
    public var setRoundUpDonationBodyClosure: (([String: Any]) async throws -> APIRoundUpDonation)?

    public func setRoundUpDonation(body: [String: Any]) async throws -> APIRoundUpDonation {
        if let error = setRoundUpDonationBodyThrowableError {
            throw error
        }
        setRoundUpDonationBodyCallsCount += 1
        setRoundUpDonationBodyReceivedBody = body
        setRoundUpDonationBodyReceivedInvocations.append(body)
        if let setRoundUpDonationBodyClosure = setRoundUpDonationBodyClosure {
            return try await setRoundUpDonationBodyClosure(body)
        } else {
            return setRoundUpDonationBodyReturnValue
        }
    }

    //MARK: - getContributionList

    public var getContributionListLimitOffsetThrowableError: Error?
    public var getContributionListLimitOffsetCallsCount = 0
    public var getContributionListLimitOffsetCalled: Bool {
        return getContributionListLimitOffsetCallsCount > 0
    }
    public var getContributionListLimitOffsetReceivedArguments: (limit: Int, offset: Int)?
    public var getContributionListLimitOffsetReceivedInvocations: [(limit: Int, offset: Int)] = []
    public var getContributionListLimitOffsetReturnValue: APIContributionList!
    public var getContributionListLimitOffsetClosure: ((Int, Int) async throws -> APIContributionList)?

    public func getContributionList(limit: Int, offset: Int) async throws -> APIContributionList {
        if let error = getContributionListLimitOffsetThrowableError {
            throw error
        }
        getContributionListLimitOffsetCallsCount += 1
        getContributionListLimitOffsetReceivedArguments = (limit: limit, offset: offset)
        getContributionListLimitOffsetReceivedInvocations.append((limit: limit, offset: offset))
        if let getContributionListLimitOffsetClosure = getContributionListLimitOffsetClosure {
            return try await getContributionListLimitOffsetClosure(limit, offset)
        } else {
            return getContributionListLimitOffsetReturnValue
        }
    }

    //MARK: - getContribution

    public var getContributionContributionIDThrowableError: Error?
    public var getContributionContributionIDCallsCount = 0
    public var getContributionContributionIDCalled: Bool {
        return getContributionContributionIDCallsCount > 0
    }
    public var getContributionContributionIDReceivedContributionID: String?
    public var getContributionContributionIDReceivedInvocations: [String] = []
    public var getContributionContributionIDReturnValue: APIContribution!
    public var getContributionContributionIDClosure: ((String) async throws -> APIContribution)?

    public func getContribution(contributionID: String) async throws -> APIContribution {
        if let error = getContributionContributionIDThrowableError {
            throw error
        }
        getContributionContributionIDCallsCount += 1
        getContributionContributionIDReceivedContributionID = contributionID
        getContributionContributionIDReceivedInvocations.append(contributionID)
        if let getContributionContributionIDClosure = getContributionContributionIDClosure {
            return try await getContributionContributionIDClosure(contributionID)
        } else {
            return getContributionContributionIDReturnValue
        }
    }

    //MARK: - getCategoriesTrending

    public var getCategoriesTrendingThrowableError: Error?
    public var getCategoriesTrendingCallsCount = 0
    public var getCategoriesTrendingCalled: Bool {
        return getCategoriesTrendingCallsCount > 0
    }
    public var getCategoriesTrendingReturnValue: APICategoriesFundraisersList!
    public var getCategoriesTrendingClosure: (() async throws -> APICategoriesFundraisersList)?

    public func getCategoriesTrending() async throws -> APICategoriesFundraisersList {
        if let error = getCategoriesTrendingThrowableError {
            throw error
        }
        getCategoriesTrendingCallsCount += 1
        if let getCategoriesTrendingClosure = getCategoriesTrendingClosure {
            return try await getCategoriesTrendingClosure()
        } else {
            return getCategoriesTrendingReturnValue
        }
    }

    //MARK: - postDonationsSuggest

    public var postDonationsSuggestNameThrowableError: Error?
    public var postDonationsSuggestNameCallsCount = 0
    public var postDonationsSuggestNameCalled: Bool {
        return postDonationsSuggestNameCallsCount > 0
    }
    public var postDonationsSuggestNameReceivedName: String?
    public var postDonationsSuggestNameReceivedInvocations: [String] = []
    public var postDonationsSuggestNameReturnValue: Bool!
    public var postDonationsSuggestNameClosure: ((String) async throws -> Bool)?

    public func postDonationsSuggest(name: String) async throws -> Bool {
        if let error = postDonationsSuggestNameThrowableError {
            throw error
        }
        postDonationsSuggestNameCallsCount += 1
        postDonationsSuggestNameReceivedName = name
        postDonationsSuggestNameReceivedInvocations.append(name)
        if let postDonationsSuggestNameClosure = postDonationsSuggestNameClosure {
            return try await postDonationsSuggestNameClosure(name)
        } else {
            return postDonationsSuggestNameReturnValue
        }
    }

    //MARK: - getUserDonationSummary

    public var getUserDonationSummaryThrowableError: Error?
    public var getUserDonationSummaryCallsCount = 0
    public var getUserDonationSummaryCalled: Bool {
        return getUserDonationSummaryCallsCount > 0
    }
    public var getUserDonationSummaryReturnValue: APIUserDonationSummary!
    public var getUserDonationSummaryClosure: (() async throws -> APIUserDonationSummary)?

    public func getUserDonationSummary() async throws -> APIUserDonationSummary {
        if let error = getUserDonationSummaryThrowableError {
            throw error
        }
        getUserDonationSummaryCallsCount += 1
        if let getUserDonationSummaryClosure = getUserDonationSummaryClosure {
            return try await getUserDonationSummaryClosure()
        } else {
            return getUserDonationSummaryReturnValue
        }
    }

    //MARK: - searchFundraisers

    public var searchFundraisersTextsLimitOffsetThrowableError: Error?
    public var searchFundraisersTextsLimitOffsetCallsCount = 0
    public var searchFundraisersTextsLimitOffsetCalled: Bool {
        return searchFundraisersTextsLimitOffsetCallsCount > 0
    }
    public var searchFundraisersTextsLimitOffsetReceivedArguments: (texts: [String], limit: Int, offset: Int)?
    public var searchFundraisersTextsLimitOffsetReceivedInvocations: [(texts: [String], limit: Int, offset: Int)] = []
    public var searchFundraisersTextsLimitOffsetReturnValue: APICategoriesFundraisersList!
    public var searchFundraisersTextsLimitOffsetClosure: (([String], Int, Int) async throws -> APICategoriesFundraisersList)?

    public func searchFundraisers(texts: [String], limit: Int, offset: Int) async throws -> APICategoriesFundraisersList {
        if let error = searchFundraisersTextsLimitOffsetThrowableError {
            throw error
        }
        searchFundraisersTextsLimitOffsetCallsCount += 1
        searchFundraisersTextsLimitOffsetReceivedArguments = (texts: texts, limit: limit, offset: offset)
        searchFundraisersTextsLimitOffsetReceivedInvocations.append((texts: texts, limit: limit, offset: offset))
        if let searchFundraisersTextsLimitOffsetClosure = searchFundraisersTextsLimitOffsetClosure {
            return try await searchFundraisersTextsLimitOffsetClosure(texts, limit, offset)
        } else {
            return searchFundraisersTextsLimitOffsetReturnValue
        }
    }

}
