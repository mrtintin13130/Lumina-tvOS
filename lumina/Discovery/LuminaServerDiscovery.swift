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

    private let browser = NetServiceBrowser()
    private var services: [NetService] = []
    private var resolveRetryCounts: [String: Int] = [:]

    override init() {
        super.init()
        browser.delegate = self
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
    nonisolated func netServiceBrowser(
        _ browser: NetServiceBrowser,
        didFind service: NetService,
        moreComing: Bool
    ) {
        Task { @MainActor in
            services.append(service)
            resolveRetryCounts[serviceKey(for: service)] = 0
            service.delegate = self
            service.resolve(withTimeout: 10)
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
            resolveRetryCounts[serviceKey(for: service)] = nil
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
            guard let host = sender.hostName ?? NetServiceAddressResolver.host(from: sender.addresses),
                  sender.port > 0 else {
                return
            }
            let txt = parseTXTRecords(from: sender)
            let server = LuminaDiscoveredServer(
                name: sender.name,
                host: host,
                port: sender.port,
                isSecure: txt["secure"] == "true",
                serverVersion: txt["serverVersion"],
                apiVersion: txt["apiVersion"]
            )
            addOrUpdateServer(server)
            resolveRetryCounts[serviceKey(for: sender)] = nil
        }
    }

    nonisolated func netService(
        _ sender: NetService,
        didNotResolve errorDict: [String: NSNumber]
    ) {
        Task { @MainActor in
            let key = serviceKey(for: sender)
            let retryCount = resolveRetryCounts[key, default: 0]
            if retryCount == 0 {
                resolveRetryCounts[key] = 1
                sender.resolve(withTimeout: 10)
                return
            }
            if discoveredServers.isEmpty {
                errorMessage = L10n.text("A Lumina server was found, but its address could not be resolved.")
            }
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
