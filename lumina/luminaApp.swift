//
//  luminaApp.swift
//  lumina
//
//  Created by Martin Thomas on 29/05/2026.
//

import SwiftUI

@main
struct luminaApp: App {
    @StateObject private var appModel: AppModel

    init() {
        #if DEBUG
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("-uiTestingDetail") {
            _appModel = StateObject(wrappedValue: AppModel.uiTestingModel(showsDetail: true))
            return
        }
        if arguments.contains("-uiTestingSearch") {
            _appModel = StateObject(wrappedValue: AppModel.uiTestingModel(tab: .search))
            return
        }
        if arguments.contains("-uiTestingSettings") {
            _appModel = StateObject(wrappedValue: AppModel.uiTestingModel(tab: .settings))
            return
        }
        if arguments.contains("-uiTestingSignIn") {
            _appModel = StateObject(wrappedValue: AppModel.uiTestingModel(signedIn: false))
            return
        }
        if arguments.contains("-uiTestingHome") {
            _appModel = StateObject(wrappedValue: AppModel.uiTestingModel())
            return
        }
        #endif
        _appModel = StateObject(wrappedValue: AppModel())
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appModel)
        }
    }
}
