//
//  AllToastsDemo.swift
//  Howl Demo App
//
//  Created by Ky on 2026-04-23.
//

import SwiftUI



struct AllToastsDemo: View {
    
    @State
    private var selectedToast: DemoableToast = .bezel
    
    var body: some View {
        identifiedToastView(for: selectedToast)
            .toolbar(id: "Toasts") {
                ToolbarItem(id: "Selected toast") {
                    Picker("Selected toast", selection: $selectedToast) {
                        ForEach(DemoableToast.allCases) {
                            Text($0.rawValue.capitalized)
                                .tag($0)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
    }
}



private extension AllToastsDemo {
    func identifiedToastView(for tab: DemoableToast) -> some View {
        toastView(for: tab)
            .id(tab)
    }
    
    
    @ViewBuilder
    func toastView(for tab: DemoableToast) -> some View {
        switch tab {
            case .bezel:
            BezelToastDemo()
        case .snackbar:
            SnackbarToastDemo()
        case .capsule:
            CapsuleToastDemo()
        }
    }
}



private enum DemoableToast: String {
    case bezel
    case snackbar
    case capsule
}



extension DemoableToast: CaseIterable {}
extension DemoableToast: Identifiable {
    var id: Self { self }
}



#Preview {
    AllToastsDemo()
}
