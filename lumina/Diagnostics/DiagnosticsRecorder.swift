//
//  DiagnosticsRecorder.swift
//  lumina
//

import Foundation

struct DiagnosticsEvent: Equatable {
    let operation: String
    let routeKey: String?
    let statusCode: Int?
    let correlationId: String?
    let message: String
}

final class DiagnosticsRecorder {
    private(set) var events: [DiagnosticsEvent] = []

    func record(operation: String, routeKey: String? = nil, statusCode: Int? = nil, correlationId: String? = nil, message: String) {
        events.append(
            DiagnosticsEvent(
                operation: operation,
                routeKey: routeKey,
                statusCode: statusCode,
                correlationId: correlationId,
                message: Self.redact(message)
            )
        )
    }

    static func redact(_ value: String) -> String {
        var redacted = value
        let patterns = [
            #"Bearer\s+[A-Za-z0-9._\-]+"#,
            #"(?i)password[=:]\S+"#,
            #"(?i)(stream_token|access_token|refresh_token|signature|signed)[=][^&\s]+"#,
            #"(?i)(token|jwt|authorization)[=:]\S+"#,
            #"/Users/[^ ]+"#,
            #"(?i)select\s+.+\s+from\s+.+"#
        ]
        for pattern in patterns {
            redacted = redacted.replacingOccurrences(of: pattern, with: "[redacted]", options: .regularExpression)
        }
        return redacted
    }
}
