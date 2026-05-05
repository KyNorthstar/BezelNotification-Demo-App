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
#if os(macOS)
        identifiedToastView(for: selectedToast)
            .toolbar(id: "Toasts") {
                ToolbarItem(id: "Selected toast", placement: .secondaryAction) {
                    Picker("Selected toast", selection: $selectedToast) {
                        ForEach(DemoableToast.allCases) {
                            Label($0.localizedTitle,
                                  systemImage: $0.systemImage)
                                .tag($0)
                                .labelStyle(.titleAndIcon)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
#elseif os(iOS)
        TabView(selection: $selectedToast) {
            ForEach(DemoableToast.allCases, id: \.id) { toast in
                Tab(toast.localizedTitle, systemImage: toast.systemImage, value: toast) {
                    identifiedToastView(for: toast)
                }
            }
        }
#endif
    }
}



private extension AllToastsDemo {
    func identifiedToastView(for tab: DemoableToast) -> some View {
        toastView(for: tab)
            .id(tab)
            .tag(tab)
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



extension DemoableToast {
    var localizedTitle: LocalizedStringKey {
        switch self {
        case .bezel:    "Bezel"
        case .snackbar: "Snackbar"
        case .capsule:  "Capsule"
        }
    }
    
    
    var systemImage: String {
        switch self {
        case .bezel:    "square.inset.filled"
        case .snackbar: "inset.filled.bottomleading.rectangle"
        case .capsule:  "capsule"
        }
    }
}



extension DemoableToast: CaseIterable {}
extension DemoableToast: Identifiable {
    var id: Self { self }
}



#Preview {
    AllToastsDemo()
}
