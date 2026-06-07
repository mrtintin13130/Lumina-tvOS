//
//  L10n.swift
//  lumina
//

import Foundation

enum L10n {
    static func text(_ key: String.LocalizationValue) -> String {
        String(localized: key)
    }

    static func format(_ key: String, _ arguments: CVarArg...) -> String {
        String(format: NSLocalizedString(key, comment: ""), locale: .current, arguments: arguments)
    }

    static func watchedPercent(_ percent: Int) -> String {
        format("%d%% watched", percent)
    }

    static func watchedPercentAccessibility(_ percent: Int) -> String {
        format("%d percent watched", percent)
    }

    static func titleCount(_ count: Int) -> String {
        format("%d titles", count)
    }

    static func loading(_ title: String) -> String {
        format("Loading %@", title.lowercased())
    }

    static func routeNotFound(_ path: String) -> String {
        format("Server reached, but the app tried %@.", path)
    }

    static func httpStatus(_ statusCode: Int) -> String {
        format("Server returned HTTP %d.", statusCode)
    }

    static func playbackStatusFailure(_ statusCode: Int) -> String {
        format("Playback failed with status %d.", statusCode)
    }

    static func browsingNotReady(_ title: String) -> String {
        format("%@ browsing is not wired yet.", title)
    }

    static func personDetailsNotReady(_ name: String) -> String {
        format("%@ details are not wired yet.", name)
    }
}

