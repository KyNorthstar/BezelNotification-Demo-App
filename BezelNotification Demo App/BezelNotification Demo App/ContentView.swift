//
//  ContentView.swift
//  BezelNotification Demo App
//
//  Created by Ky on 2026-04-09.
//

import SwiftUI



struct ContentView: View {
    var body: some View {
        TabView {
            #if os(macOS)
            Tab("System Bezel", systemImage: "inset.filled.center.rectangle") {
                SystemBezelDemo()
            }
            #endif
            
//            Tab("Bezel", systemImage: "dot.square") {
//                BezelDemo()
//            }
            
            Tab("Snackbar", systemImage: "exclamationmark.bubble") {
                SnackbarToastDemo()
            }
        }
        .tabViewStyle(.tabBarOnly)
    }
}



#Preview {
    ContentView()
}
