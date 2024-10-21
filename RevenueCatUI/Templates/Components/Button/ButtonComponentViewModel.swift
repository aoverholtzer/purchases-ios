//
//  Copyright RevenueCat Inc. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  ButtonComponentViewModel.swift
//
//  Created by Jay Shortway on 02/10/2024.
//
// swiftlint:disable missing_docs

import Foundation
import RevenueCat

#if PAYWALL_COMPONENTS

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public class ButtonComponentViewModel {

    /// A mirror of ButtonComponent.Action, with the sole purpose of being able to change the type of urlLid parameters
    /// of some Destination's to actual URLs.
    internal enum Action {
        case restorePurchases
        case navigateTo(destination: Destination)
        case navigateBack
    }

    /// A mirror of ButtonComponent.Destination, with any urlLid parameters changed to be of the actual URL type. This
    /// allows us to verify the URLs exist and are properly formatted, before making them available to the view layer.
    /// This way the view layer doesn't need to handle this error scenario.
    internal enum Destination {
        case customerCenter
        case URL(url: URL, method: PaywallComponent.ButtonComponent.URLMethod)
        case privacyPolicy(url: URL, method: PaywallComponent.ButtonComponent.URLMethod)
        case terms(url: URL, method: PaywallComponent.ButtonComponent.URLMethod)
    }

    internal let component: PaywallComponent.ButtonComponent
    internal let localizedStrings: PaywallComponent.LocalizationDictionary
    internal let action: Action
    let stackViewModel: StackComponentViewModel

    init(
        component: PaywallComponent.ButtonComponent,
        localizedStrings: PaywallComponent.LocalizationDictionary,
        offering: Offering
    ) throws {
        self.component = component
        self.localizedStrings = localizedStrings
        self.stackViewModel = try StackComponentViewModel(
            component: component.stack,
            localizedStrings: localizedStrings,
            offering: offering
        )

        // Mapping ButtonComponent.Action to ButtonComponentViewModel.Action to verify that any passed-in urlLids exist
        // in localizedStrings:
        switch component.action {
        case .restorePurchases:
            self.action = .restorePurchases
        case .navigateTo(let destination):
            switch destination {
            case .customerCenter:
                self.action = .navigateTo(destination: .customerCenter)
            case .URL(let urlLid, let method):
                self.action = .navigateTo(
                    destination: .URL(url: try localizedStrings.urlFromLid(urlLid), method: method)
                )
            case .privacyPolicy(let urlLid, let method):
                self.action = .navigateTo(
                    destination: .privacyPolicy(url: try localizedStrings.urlFromLid(urlLid), method: method)
                )
            case .terms(let urlLid, let method):
                self.action = .navigateTo(
                    destination: .terms(url: try localizedStrings.urlFromLid(urlLid), method: method)
                )
            }
        case .navigateBack:
            self.action = .navigateBack
        }
    }

}

fileprivate extension PaywallComponent.LocalizationDictionary {

    func urlFromLid(_ urlLid: String) throws -> URL {
        let urlString = try string(key: urlLid)
        let url = URL(string: urlString)
        if url == nil {
            Logger.error(Strings.paywall_invalid_url(urlLid))
        }
        return url!
    }

}

#endif