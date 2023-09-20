//
//  Copyright RevenueCat Inc. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  PurchaseHandler+TestData.swift
//
//  Created by Nacho Soto on 9/12/23.

import Foundation
import RevenueCat

#if DEBUG

@available(iOS 15.0, macOS 12.0, tvOS 15.0, *)
extension PurchaseHandler {

    static func mock() -> Self {
        return self.init(
            purchases: MockPurchases { _ in
                return (
                    transaction: nil,
                    customerInfo: TestData.customerInfo,
                    userCancelled: false
                )
            } restorePurchases: {
                return TestData.customerInfo
            } trackEvent: { event in
                Logger.debug("Tracking event: \(event)")
            }
        )
    }

    static func cancelling() -> Self {
        return .mock()
            .map { block in {
                    var result = try await block($0)
                    result.userCancelled = true
                    return result
                }
            } restore: { $0 }
    }

    /// Creates a copy of this `PurchaseHandler` with a delay.
    func with(delay seconds: TimeInterval) -> Self {
        return self.map { purchaseBlock in {
            await Task.sleep(seconds: seconds)

            return try await purchaseBlock($0)
        }
        } restore: { restoreBlock in {
            await Task.sleep(seconds: seconds)

            return try await restoreBlock()
        }
        }
    }

}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension Task where Success == Never, Failure == Never {

    static func sleep(seconds: TimeInterval) async {
        try? await Self.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }

}

#endif