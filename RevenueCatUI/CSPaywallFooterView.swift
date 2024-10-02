//
//  CSPaywallFooterView.swift
//  purchases-ios
//
//  Created by Adam Overholtzer on 10/2/24.
//


import RevenueCat
import SwiftUI

#if !os(macOS) && !os(tvOS) && !os(watchOS)

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
@available(macOS, unavailable, message: "RevenueCatUI does not support macOS yet")
@available(tvOS, unavailable, message: "RevenueCatUI does not support tvOS yet")
@available(watchOS, unavailable, message: "Footers not supported on watchOS")
public struct CSPaywallFooterView: View {
    let offering: Offering?
    let condensed: Bool
    let onCompleted: PurchaseOrRestoreCompletedHandler?
    
    public init(offering: Offering?, condensed: Bool = false, onCompleted: PurchaseOrRestoreCompletedHandler? = nil) {
        self.offering = offering
        self.condensed = condensed
        self.onCompleted = onCompleted
    }
    
    public var body: some View {
        PaywallView(configuration: .init(
            content: .optionalOffering(offering),
            mode: condensed ? .condensedFooter : .footer,
            displayCloseButton: false,
            purchaseHandler: PurchaseHandler.default()
        ))
        .onPurchaseCompleted {
            self.onCompleted?($0)
        }
        .onRestoreCompleted {
            self.onCompleted?($0)
        }
    }
}

#endif
