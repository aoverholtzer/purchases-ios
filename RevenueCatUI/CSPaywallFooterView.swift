//
//  CSPaywallFooterView.swift
//  purchases-ios
//
//  Created by Adam Overholtzer on 10/2/24.
//


import RevenueCat
import SwiftUI

public struct CSPaywallFooterView: View {
    let offering: Offering?
    let condensed: Bool
    let displayCloseButton: Bool
    let onCompleted: PurchaseOrRestoreCompletedHandler?
    
    init(offering: Offering?, condensed: Bool = false, displayCloseButton = false, onCompleted: PurchaseOrRestoreCompletedHandler? = nil) {
        self.offering = offering
        self.condensed = condensed
        self.displayCloseButton = displayCloseButton
        self.onCompleted = onCompleted
    }
    
    var body: some View {
        PaywallView(configuration: .init(
            content: .optionalOffering(offering),
            mode: condensed ? .condensedFooter : .footer,
            displayCloseButton: displayCloseButton,
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
