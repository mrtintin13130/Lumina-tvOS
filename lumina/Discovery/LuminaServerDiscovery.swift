//
//  LuminaServerDiscovery.swift
//  lumina
//

import Foundation
import Darwin

@MainActor
final class LuminaServerDiscovery: NSObject, ObservableObject {
    @Published private(set) var discoveredServers: [LuminaDiscoveredServer] = []
    @Published private(set) var isSearching = false
    @Published private(set) var errorMessage: String?

    private static let resolveTimeout: TimeInterval = 20
    private static let maximumResolveAttempts = 3

    private let browser = NetServiceBrowser()
    private var services: [NetService] = []
    private var resolveRetryCounts: [String: Int] = [:]

    override init() {
        super.init()
        browser.delegate = self
        browser.includesPeerToPeer = true
    }

    func startSearching() {
        stopSearching()
        discoveredServers = []
        services = []
        resolveRetryCounts = [:]
        errorMessage = nil
        isSearching = true
        browser.searchForServices(ofType: "_lumina._tcp.", inDomain: "local.")
    }

    func stopSearching() {
        browser.stop()
        services.forEach { $0.stop() }
        resolveRetryCounts = [:]
        isSearching = false
    }

    private func addOrUpdateServer(_ server: LuminaDiscoveredServer) {
        if let index = discoveredServers.firstIndex(where: { $0.id == server.id }) {
            discoveredServers[index] = server
        } else {
            discoveredServers.append(server)
        }
    }

    private func parseTXTRecords(from service: NetService) -> [String: String] {
        guard let data = service.txtRecordData() else {
            return [:]
        }
        return NetService.dictionary(fromTXTRecord: data).reduce(into: [String: String]()) { result, item in
            result[item.key] = String(data: item.value, encoding: .utf8)
        }
    }

    private func serviceKey(for service: NetService) -> String {
        "\(service.name)|\(service.type)|\(service.domain)"
    }
}

extension LuminaServerDiscovery: NetServiceBrowserDelegate {
    func netServiceBrowser(
        _ browser: NetServiceBrowser,
        didFind service: NetService,
        moreComing: Bool
    ) {
        services.append(service)
        resolveRetryCounts[serviceKey(for: service)] = 0
        service.delegate = self
        service.includesPeerToPeer = true
        service.resolve(withTimeout: Self.resolveTimeout)
    }

    func netServiceBrowser(
        _ browser: NetServiceBrowser,
        didRemove service: NetService,
        moreComing: Bool
    ) {
        discoveredServers.removeAll { server in
            server.name == service.name || server.host == service.hostName
        }
        resolveRetryCounts[serviceKey(for: service)] = nil
    }

    func netServiceBrowser(
        _ browser: NetServiceBrowser,
        didNotSearch errorDict: [String: NSNumber]
    ) {
        isSearching = false
        errorMessage = L10n.text("Local network search failed.")
    }
}

extension LuminaServerDiscovery: NetServiceDelegate {
    func netServiceDidResolveAddress(_ sender: NetService) {
        let txt = parseTXTRecords(from: sender)
        guard let host = NetServiceAddressResolver.host(from: sender.addresses)
            ?? LuminaDiscoveryTXTRecords.addressHint(from: txt)
            ?? sender.hostName,
              sender.port > 0 else {
            return
        }
        guard let server = LuminaDiscoveryTXTRecords.discoveredServer(
            name: sender.name,
            host: host,
            port: sender.port,
            txt: txt
        ) else { return }
        addOrUpdateServer(server)
        resolveRetryCounts[serviceKey(for: sender)] = nil
    }

    func netService(
        _ sender: NetService,
        didNotResolve errorDict: [String: NSNumber]
    ) {
        let key = serviceKey(for: sender)
        let retryCount = resolveRetryCounts[key, default: 0]
        if retryCount + 1 < Self.maximumResolveAttempts {
            resolveRetryCounts[key] = retryCount + 1
            sender.resolve(withTimeout: Self.resolveTimeout)
            return
        }
        let txt = parseTXTRecords(from: sender)
        if sender.port > 0,
           let host = LuminaDiscoveryTXTRecords.addressHint(from: txt),
           let server = LuminaDiscoveryTXTRecords.discoveredServer(
            name: sender.name,
            host: host,
            port: sender.port,
            txt: txt
           ) {
            addOrUpdateServer(server)
            resolveRetryCounts[key] = nil
            return
        }
        if discoveredServers.isEmpty {
            errorMessage = L10n.text("A Lumina server was found, but its address could not be resolved.")
        }
    }
}

enum NetServiceAddressResolver {
    static func host(from addresses: [Data]?) -> String? {
        guard let addresses else { return nil }

        for address in addresses {
            let host = address.withUnsafeBytes { buffer -> String? in
                guard let baseAddress = buffer.baseAddress else { return nil }

                var hostBuffer = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                let result = getnameinfo(
                    baseAddress.assumingMemoryBound(to: sockaddr.self),
                    socklen_t(address.count),
                    &hostBuffer,
                    socklen_t(hostBuffer.count),
                    nil,
                    0,
                    NI_NUMERICHOST
                )

                guard result == 0 else { return nil }
                let resolvedHost = String(cString: hostBuffer)
                return resolvedHost.isEmpty ? nil : resolvedHost
            }

            if let host {
                return host
            }
        }

        return nil
    }
}

enum LuminaDiscoveryTXTRecords {
    static func addressHint(from txt: [String: String]) -> String? {
        sanitizedAddress(txt["address"]) ?? sanitizedAddress(txt["host"])
    }

    static func discoveredServer(
        name: String,
        host: String,
        port: Int,
        txt: [String: String]
    ) -> LuminaDiscoveredServer? {
        guard txt["app"]?.localizedCaseInsensitiveCompare("lumina") == .orderedSame else {
            return nil
        }

        return LuminaDiscoveredServer(
            name: name,
            host: host,
            port: port,
            isSecure: txt["secure"] == "true",
            serverID: txt["id"],
            serverVersion: txt["version"],
            apiVersion: txt["apiVersion"],
            apiPath: txt["api"] ?? "/api/v1",
            capabilitiesPath: txt["capabilities"] ?? "/api/v1/system/capabilities"
        )
    }

    private static func sanitizedAddress(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed.rangeOfCharacter(from: .whitespacesAndNewlines) == nil else {
            return nil
        }
        return trimmed
    }
}
