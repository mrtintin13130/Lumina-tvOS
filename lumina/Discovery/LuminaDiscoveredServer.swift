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
    let serverID: String?
    let serverVersion: String?
    let apiVersion: String?
    let apiPath: String
    let capabilitiesPath: String

    var id: String {
        serverID ?? "\(urlHost.lowercased())-\(port)"
    }

    var baseURL: URL? {
        var components = URLComponents()
        components.scheme = isSecure ? "https" : "http"
        components.host = urlHost
        components.port = port
        return components.url
    }

    var displayAddress: String {
        "\(urlHost):\(port)"
    }

    var capabilitiesURL: URL? {
        URL(string: capabilitiesPath, relativeTo: baseURL)?.absoluteURL
    }

    private var urlHost: String {
        host.hasSuffix(".") ? String(host.dropLast()) : host
    }

    init(
        name: String,
        host: String,
        port: Int,
        isSecure: Bool,
        serverID: String? = nil,
        serverVersion: String? = nil,
        apiVersion: String? = nil,
        apiPath: String = "/api/v1",
        capabilitiesPath: String = "/api/v1/system/capabilities"
    ) {
        self.name = name
        self.host = host
        self.port = port
        self.isSecure = isSecure
        self.serverID = serverID
        self.serverVersion = serverVersion
        self.apiVersion = apiVersion
        self.apiPath = apiPath
        self.capabilitiesPath = capabilitiesPath
    }
}
