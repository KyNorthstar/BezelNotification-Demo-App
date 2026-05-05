//
//  App.swift
//  Howl Demo App
//
//  Created by Ky on 2026-04-07.
//

import SwiftUI



@main
struct App: SwiftUI.App {
    var body: some Scene {
        WindowGroup {
//            ForScreenshots()
            ContentView()
                .navigationTitle("Howl demo app")
        }
#if os(macOS)
        .windowToolbarLabelStyle(fixed: .titleAndIcon)
#endif
    }
}


