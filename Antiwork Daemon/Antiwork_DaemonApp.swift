//
//  Antiwork_DaemonApp.swift
//  Antiwork Daemon
//
//  Created by Ankur Taxali on 2025-09-26.
//

import SwiftUI

@main
struct Antiwork_DaemonApp: App {
    @StateObject private var menuBarManager = MenuBarManager()
    
    var body: some Scene {
        WindowGroup {
            LotusView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        
        WindowGroup("Demo Window") {
            DemoView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultPosition(.center)
    }
}
