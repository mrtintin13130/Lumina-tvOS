//
//  DiagnosticsRecorder.swift
//  lumina
//

import Foundation

enum DiagnosticsSeverity: String, Equatable {
    case info
    case warning
    case error
}

enum DiagnosticsPhase: String, Equatable {
    case setup
    case auth
    case catalog
    case playback
    case networking
}

struct DiagnosticsEvent: Equatable {
    let operation: String
    let phase: DiagnosticsPhase
    let severity: DiagnosticsSeverity
    let category: String?
    let routeKey: String?
    let statusCode: Int?
    let correlationId: String?
    let supportId: String?
    let message: String
}

final class DiagnosticsRecorder {
    private(set) var events: [DiagnosticsEvent] = []

    func record(
        operation: String,
        phase: DiagnosticsPhase = .networking,
        severity: DiagnosticsSeverity = .error,
        category: String? = nil,
        routeKey: String? = nil,
        statusCode: Int? = nil,
        correlationId: String? = nil,
        supportId: String? = nil,
        message: String
    ) {
        let safeCorrelationId = correlationId.map(Self.redact)
        let safeSupportId = supportId.map(Self.redact) ?? safeCorrelationId
        events.append(
            DiagnosticsEvent(
                operation: operation,
                phase: phase,
                severity: severity,
                category: category.map(Self.redact),
                routeKey: routeKey,
                statusCode: statusCode,
                correlationId: safeCorrelationId,
                supportId: safeSupportId,
                message: Self.redact(message)
            )
        )
    }

    func record(
        error: LuminaClientError,
        operation: String,
        phase: DiagnosticsPhase,
        routeKey: String? = nil,
        statusCode: Int? = nil
    ) {
        let correlationId: String?
        let category: String?
        if case .server(let body) = error {
            correlationId = body.correlationId
            category = body.category
        } else {
            correlationId = nil
            category = nil
        }
        record(
            operation: operation,
            phase: phase,
            severity: .error,
            category: category,
            routeKey: routeKey,
            statusCode: statusCode,
            correlationId: correlationId,
            message: error.safeMessage
        )
    }

    static func redact(_ value: String) -> String {
        var redacted = value
        let patterns = [
            #"Bearer\s+[A-Za-z0-9._\-]+"#,
            #"(?i)password[=:]\S+"#,
            #"(?i)(username|email)[=:]\S+"#,
            #"(?i)"password"\s*:\s*"[^"]+""#,
            #"(?i)"(username|email)"\s*:\s*"[^"]+""#,
            #"(?i)(stream_token|access_token|refresh_token|signature|signed)[=][^&\s]+"#,
            #"(?i)"(stream_token|access_token|refresh_token|signature|signed|token|jwt|authorization)"\s*:\s*"[^"]+""#,
            #"(?i)(token|jwt|authorization)[=:]\S+"#,
            #"(https?://[^\s?]+)\?[^\s]+"#,
            #"/Users/[^ ]+"#,
            #"/private/var/[^ ]+"#,
            #"/var/mobile/[^ ]+"#,
            #"file://[^ \n]+"#,
            #"(?i)(select|insert|update|delete)\s+.+\s+(from|into|set)\s+.+"#,
            #"(?i)(sqlite|sql error|database error)[^\n]*"#,
            #"(?m)^\s*at\s+.+$"#,
            #"(?m)^#\d+\s+.+$"#,
            #"(?m)^Thread\s+\d+:.+$"#,
            #"(?s)Command line invocation:.+"#,
            #"(?m)^\s*(stdout|stderr):.+$"#
        ]
        for pattern in patterns {
            redacted = redacted.replacingOccurrences(of: pattern, with: "[redacted]", options: .regularExpression)
        }
        return redacted
    }
}
