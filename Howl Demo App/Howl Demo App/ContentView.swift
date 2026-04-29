//
//  ContentView.swift
//  Howl Demo App
//
//  Created by Ky on 2026-04-09.
//

import SwiftUI



struct ContentView: View {
    var body: some View {
#if os(macOS)
        TabView {
            TabSection("macOS Only") {
                Tab("System Bezel", systemImage: "inset.filled.center.rectangle") {
                    SystemBezelDemo()
                }
            }
            
            Tab("Toasts", systemImage: "info.bubble") {
                AllToastsDemo()
            }
            
//            Tab("Bezel", systemImage: "square.inset.filled") {
//                SnackbarToastDemo()
//            }
//            Tab("Snackbar", systemImage: "inset.filled.bottomleading.rectangle") {
//                SnackbarToastDemo()
//            }
//            Tab("Capsule", systemImage: "capsule") {
//                CapsuleToastDemo()
//            }
        }
        .tabViewStyle(.tabBarOnly)
#else
        AllToastsDemo()
#endif
    }
}



#Preview {
    ContentView()
}
