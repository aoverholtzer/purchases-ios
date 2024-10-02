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
    let configuration: PaywallViewConfiguration
    let onCompleted: PurchaseOrRestoreCompletedHandler?
    
    public init(offering: Offering?, condensed: Bool = false, onCompleted: PurchaseOrRestoreCompletedHandler? = nil) {
        self.onCompleted = onCompleted
        self.configuration = .init(
            content: .optionalOffering(offering),
            mode: condensed ? .condensedFooter : .footer,
            displayCloseButton: false,
            purchaseHandler: PurchaseHandler.default()
        )
    }
    
    public var body: some View {
        PaywallView(configuration: configuration)
        .onPurchaseCompleted {
            self.onCompleted?($0)
        }
        .onRestoreCompleted {
            self.onCompleted?($0)
        }
    }
}

#endif
