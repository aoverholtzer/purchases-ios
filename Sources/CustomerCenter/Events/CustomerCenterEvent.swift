//
//  Copyright RevenueCat Inc. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  CustomerCenterEvent.swift
//
//  Created by Cesar de la Vega on 21/10/24.

import Foundation

/// An event to be sent by the `RevenueCatUI` SDK.
public enum CustomerCenterEvent: FeatureEvent {

    // swiftlint:disable type_name

    /// An identifier that represents a customer center event.
    public typealias ID = UUID

    // swiftlint:enable type_name

    /// An identifier that represents a paywall session.
    public typealias SessionID = UUID

    var feature: Feature {
        return .customerCenter
    }

    /// The Customer Center was displayed.
    case impression(CreationData, Data)

}

extension CustomerCenterEvent {

    /// The creation data of a ``CustomerCenterEvent``.
    public struct CreationData {

        // swiftlint:disable missing_docs
        public var id: ID
        public var date: Date

        public init(
            id: ID = .init(),
            date: Date = .init()
        ) {
            self.id = id
            self.date = date
        }

    }

}

extension CustomerCenterEvent {

    /// The content of a ``CustomerCenterEvent``.
    public struct Data {

        // swiftlint:disable missing_docs
        public var localeIdentifier: String
        public var darkMode: Bool
        public var isSandbox: Bool
        public var displayMode: CustomerCenterPresentationMode

        public init(
            locale: Locale,
            darkMode: Bool,
            isSandbox: Bool,
            displayMode: CustomerCenterPresentationMode
        ) {
            self.localeIdentifier = locale.identifier
            self.darkMode = darkMode
            self.isSandbox = isSandbox
            self.displayMode = displayMode
        }
        // swiftlint:enable missing_docs

    }

}

extension CustomerCenterEvent {

    /// - Returns: the underlying ``CustomerCenterEvent/CreationData-swift.struct`` for this event.
    public var creationData: CreationData {
        switch self {
        case let .impression(creationData, _): return creationData
        }
    }

    /// - Returns: the underlying ``CustomerCenterEvent/Data-swift.struct`` for this event.
    public var data: Data {
        switch self {
        case let .impression(_, data): return data
        }
    }

}

// MARK: -

extension CustomerCenterEvent.CreationData: Equatable, Codable, Sendable {}
extension CustomerCenterEvent.Data: Equatable, Codable, Sendable {}
extension CustomerCenterEvent: Equatable, Codable, Sendable {}
