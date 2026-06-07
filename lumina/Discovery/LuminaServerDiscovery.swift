//
//  LuminaServerDiscovery.swift
//  lumina
//

import Foundation

@MainActor
final class LuminaServerDiscovery: NSObject, ObservableObject {
    @Published private(set) var discoveredServers: [LuminaDiscoveredServer] = []
    @Published private(set) var isSearching = false
    @Published private(set) var errorMessage: String?

    private let browser = NetServiceBrowser()
    private var services: [NetService] = []

    override init() {
        super.init()
        browser.delegate = self
    }

    func startSearching() {
        stopSearching()
        discoveredServers = []
        services = []
        errorMessage = nil
        isSearching = true
        browser.searchForServices(ofType: "_lumina._tcp.", inDomain: "local.")
    }

    func stopSearching() {
        browser.stop()
        services.forEach { $0.stop() }
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
}

extension LuminaServerDiscovery: NetServiceBrowserDelegate {
    nonisolated func netServiceBrowser(
        _ browser: NetServiceBrowser,
        didFind service: NetService,
        moreComing: Bool
    ) {
        Task { @MainActor in
            services.append(service)
            service.delegate = self
            service.resolve(withTimeout: 5)
        }
    }

    nonisolated func netServiceBrowser(
        _ browser: NetServiceBrowser,
        didRemove service: NetService,
        moreComing: Bool
    ) {
        Task { @MainActor in
            discoveredServers.removeAll { server in
                server.name == service.name || server.host == service.hostName
            }
        }
    }

    nonisolated func netServiceBrowser(
        _ browser: NetServiceBrowser,
        didNotSearch errorDict: [String: NSNumber]
    ) {
        Task { @MainActor in
            isSearching = false
            errorMessage = L10n.text("Local network search failed.")
        }
    }
}

extension LuminaServerDiscovery: NetServiceDelegate {
    nonisolated func netServiceDidResolveAddress(_ sender: NetService) {
        Task { @MainActor in
            guard let hostName = sender.hostName, sender.port > 0 else {
                return
            }
            let txt = parseTXTRecords(from: sender)
            let server = LuminaDiscoveredServer(
                name: sender.name,
                host: hostName,
                port: sender.port,
                isSecure: txt["secure"] == "true",
                serverVersion: txt["serverVersion"],
                apiVersion: txt["apiVersion"]
            )
            addOrUpdateServer(server)
        }
    }

    nonisolated func netService(
        _ sender: NetService,
        didNotResolve errorDict: [String: NSNumber]
    ) {
        Task { @MainActor in
            errorMessage = L10n.text("A Lumina server was found, but its address could not be resolved.")
        }
    }
}
