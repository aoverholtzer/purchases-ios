//
//  Copyright RevenueCat Inc. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  BaseBackendTest.swift
//
//  Created by Nacho Soto on 3/7/22.

import Foundation
import Nimble
import SnapshotTesting
import XCTest

@testable import RevenueCat

class BaseBackendTests: TestCase {

    private(set) var systemInfo: SystemInfo!
    private(set) var httpClient: MockHTTPClient!
    private(set) var diagnosticsTracker: DiagnosticsTrackerType?
    private(set) var operationDispatcher: MockOperationDispatcher!
    private(set) var mockProductEntitlementMappingFetcher: MockProductEntitlementMappingFetcher!
    private(set) var mockOfflineCustomerInfoCreator: MockOfflineCustomerInfoCreator!
    private(set) var mockPurchasedProductsFetcher: MockPurchasedProductsFetcher!
    private(set) var backend: Backend!
    private(set) var offerings: OfferingsAPI!
    private(set) var offlineEntitlements: OfflineEntitlementsAPI!
    private(set) var identity: IdentityAPI!
    private(set) var internalAPI: InternalAPI!
    private(set) var customerCenterConfig: CustomerCenterConfigAPI!
    private(set) var redeemWebPurchaseAPI: RedeemWebPurchaseAPI!
    private(set) var virtualCurrenciesAPI: VirtualCurrenciesAPI!

    static let apiKey = "asharedsecret"
    static let userID = "user"

    override func setUpWithError() throws {
        try super.setUpWithError()

        self.createDependencies(dangerousSettings: self.dangerousSettings)
    }

    final func createDependencies(dangerousSettings: DangerousSettings? = nil,
                                  localesProvider: PreferredLocalesProvider = .mock()) {
        // Need to force StoreKit 1 because we use iOS 13 snapshots
        // for watchOS tests which contain StoreKit 1 headers
        #if os(watchOS)
        let storeKitVersion = StoreKitVersion.storeKit1
        #else
        let storeKitVersion = StoreKitVersion.default
        #endif
        self.systemInfo =  SystemInfo(
            platformInfo: nil,
            finishTransactions: true,
            storefrontProvider: MockStorefrontProvider(),
            storeKitVersion: storeKitVersion,
            responseVerificationMode: self.responseVerificationMode,
            dangerousSettings: dangerousSettings,
            isAppBackgrounded: false,
            preferredLocalesProvider: localesProvider
        )
        self.httpClient = self.createClient()
        self.operationDispatcher = MockOperationDispatcher()
        self.mockProductEntitlementMappingFetcher = MockProductEntitlementMappingFetcher()
        self.mockOfflineCustomerInfoCreator = MockOfflineCustomerInfoCreator()
        self.mockPurchasedProductsFetcher = MockPurchasedProductsFetcher()

        let attributionFetcher = AttributionFetcher(attributionFactory: MockAttributionTypeFactory(),
                                                    systemInfo: self.systemInfo)
        let backendConfig = BackendConfiguration(
            httpClient: self.httpClient,
            operationDispatcher: self.operationDispatcher,
            operationQueue: MockBackend.QueueProvider.createBackendQueue(),
            diagnosticsQueue: MockBackend.QueueProvider.createDiagnosticsQueue(),
            systemInfo: self.systemInfo,
            offlineCustomerInfoCreator: self.mockOfflineCustomerInfoCreator,
            dateProvider: MockDateProvider(stubbedNow: MockBackend.referenceDate)
        )

        let customer = CustomerAPI(backendConfig: backendConfig, attributionFetcher: attributionFetcher)
        self.identity = IdentityAPI(backendConfig: backendConfig)
        self.offerings = OfferingsAPI(backendConfig: backendConfig)
        self.offlineEntitlements = OfflineEntitlementsAPI(backendConfig: backendConfig)
        self.internalAPI = InternalAPI(backendConfig: backendConfig)
        self.customerCenterConfig = CustomerCenterConfigAPI(backendConfig: backendConfig)
        self.redeemWebPurchaseAPI = RedeemWebPurchaseAPI(backendConfig: backendConfig)
        self.virtualCurrenciesAPI = VirtualCurrenciesAPI(backendConfig: backendConfig)

        self.backend = Backend(backendConfig: backendConfig,
                               customerAPI: customer,
                               identityAPI: self.identity,
                               offeringsAPI: self.offerings,
                               offlineEntitlements: self.offlineEntitlements,
                               internalAPI: self.internalAPI,
                               customerCenterConfig: self.customerCenterConfig,
                               redeemWebPurchaseAPI: self.redeemWebPurchaseAPI,
                               virtualCurrenciesAPI: self.virtualCurrenciesAPI)
    }

    var verificationMode: Configuration.EntitlementVerificationMode {
        return .disabled
    }

    var dangerousSettings: DangerousSettings {
        return .init()
    }

    func createClient() -> MockHTTPClient {
        XCTFail("\(#function) must be overriden by subclasses")
        return self.createClient(#file)
    }

}

extension BaseBackendTests {

    final func createClient(_ file: StaticString) -> MockHTTPClient {
        let eTagManager = MockETagManager()

        if #available(iOS 15.0, tvOS 15.0, macOS 12.0, watchOS 8.0, *) {
            self.diagnosticsTracker = MockDiagnosticsTracker()
        } else {
            self.diagnosticsTracker = nil
        }

        return MockHTTPClient(apiKey: Self.apiKey,
                              systemInfo: self.systemInfo,
                              eTagManager: eTagManager,
                              diagnosticsTracker: self.diagnosticsTracker,
                              sourceTestFile: file)
    }

    private var responseVerificationMode: Signing.ResponseVerificationMode {
        return Signing.verificationMode(with: self.verificationMode)
    }

}

extension BaseBackendTests {

    static let serverErrorResponse = [
        "code": "7225",
        "message": "something is bad up in the cloud"
    ]

    static let validCustomerResponse: [String: Any] = [
        "request_date": "2019-08-16T10:30:42Z",
        "subscriber": [
            "first_seen": "2019-07-17T00:05:54Z",
            "original_app_user_id": "",
            "subscriptions": [
                "onemonth_freetrial": [
                    "purchase_date": "2017-07-30T02:40:36Z",
                    "expires_date": "2017-08-30T02:40:36Z"
                ]
            ]
        ] as [String: Any]
    ]

}

final class MockStorefrontProvider: StorefrontProviderType {

    var currentStorefront: StorefrontType? {
        // Simulate `DefaultStorefrontProvider` availability.
        if #available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, macCatalyst 13.1, *) {
            return MockStorefront(countryCode: "USA")
        } else {
            return nil
        }
    }

}
