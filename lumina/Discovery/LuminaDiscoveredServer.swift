//
//  LuminaDiscoveredServer.swift
//  lumina
//

import Foundation

struct LuminaDiscoveredServer: Identifiable, Hashable {
    let name: String
    let host: String
    let port: Int
    let isSecure: Bool
    let serverVersion: String?
    let apiVersion: String?

    var id: String {
        "\(host.lowercased())-\(port)"
    }

    var baseURL: URL? {
        var components = URLComponents()
        components.scheme = isSecure ? "https" : "http"
        components.host = host
        components.port = port
        return components.url
    }

    var displayAddress: String {
        "\(host):\(port)"
    }
}
