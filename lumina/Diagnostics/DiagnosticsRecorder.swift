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
    let routeKey: String?
    let statusCode: Int?
    let correlationId: String?
    let message: String
}

final class DiagnosticsRecorder {
    private(set) var events: [DiagnosticsEvent] = []

    func record(
        operation: String,
        phase: DiagnosticsPhase = .networking,
        severity: DiagnosticsSeverity = .error,
        routeKey: String? = nil,
        statusCode: Int? = nil,
        correlationId: String? = nil,
        message: String
    ) {
        events.append(
            DiagnosticsEvent(
                operation: operation,
                phase: phase,
                severity: severity,
                routeKey: routeKey,
                statusCode: statusCode,
                correlationId: correlationId,
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
        if case .server(let body) = error {
            correlationId = body.correlationId
        } else {
            correlationId = nil
        }
        record(
            operation: operation,
            phase: phase,
            severity: .error,
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
            #"(?i)"password"\s*:\s*"[^"]+""#,
            #"(?i)(stream_token|access_token|refresh_token|signature|signed)[=][^&\s]+"#,
            #"(?i)"(stream_token|access_token|refresh_token|signature|signed|token|jwt|authorization)"\s*:\s*"[^"]+""#,
            #"(?i)(token|jwt|authorization)[=:]\S+"#,
            #"/Users/[^ ]+"#,
            #"/private/var/[^ ]+"#,
            #"/var/mobile/[^ ]+"#,
            #"file://[^ \n]+"#,
            #"(?i)(select|insert|update|delete)\s+.+\s+(from|into|set)\s+.+"#,
            #"(?m)^\s*at\s+.+$"#
        ]
        for pattern in patterns {
            redacted = redacted.replacingOccurrences(of: pattern, with: "[redacted]", options: .regularExpression)
        }
        return redacted
    }
}
