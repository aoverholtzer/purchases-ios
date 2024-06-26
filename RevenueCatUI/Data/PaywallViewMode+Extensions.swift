//
//  Copyright RevenueCat Inc. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  PaywallViewMode+Extensions.swift
//
//  Created by Nacho Soto on 8/9/23.

import RevenueCat

extension PaywallViewMode {

    var displayAllPlansByDefault: Bool {
        switch self {
        case .fullScreen: return true
#if !os(watchOS)
        case .footer: return true
        case .condensedFooter: return false
#endif
        }
    }

    var displayAllPlansButton: Bool {
        switch self {
        case .fullScreen: return false
#if !os(watchOS)
        case .footer: return false
        case .condensedFooter: return true
#endif
        }
    }

    var shouldDisplayBackground: Bool {
        switch self {
        case .fullScreen: return true
#if !os(watchOS)
        case .footer, .condensedFooter: return false
#endif
        }
    }

    func shouldDisplayInlineOfferDetails(displayingAllPlans: Bool) -> Bool {
        switch self {
        case .fullScreen: return false
#if !os(watchOS)
        case .footer: return false
        case .condensedFooter: return !displayingAllPlans
#endif
        }
    }

}
