//
//  luminaApp.swift
//  lumina
//
//  Created by Martin Thomas on 29/05/2026.
//

import SwiftUI

@main
struct luminaApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appModel)
        }
    }
}
