//
//  RouteTemplateResolver.swift
//  lumina
//

import Foundation

struct RouteTemplateResolver: Equatable {
    let routes: [String: String]

    init(routes: [String: String] = [:]) {
        self.routes = routes
    }

    func path(
        key: String,
        fallback: String,
        parameters: [String: String] = [:]
    ) -> String {
        render(template: routes[key] ?? fallback, parameters: parameters)
    }

    func path(
        keys: [String],
        fallback: String,
        parameters: [String: String] = [:]
    ) -> String {
        let template = keys.lazy.compactMap { routes[$0] }.first ?? fallback
        return render(template: template, parameters: parameters)
    }

    func render(template: String, parameters: [String: String]) -> String {
        var path = template
        for (name, value) in parameters {
            path = path.replacingOccurrences(of: ":\(name)", with: Self.encodedPathSegment(value))
        }
        return path
    }

    static func encodedPathSegment(_ value: String) -> String {
        var allowed = CharacterSet.urlPathAllowed
        allowed.remove(charactersIn: "/?#[]@!$&'()*+,;=%")
        return value.addingPercentEncoding(withAllowedCharacters: allowed) ?? value
    }
}
