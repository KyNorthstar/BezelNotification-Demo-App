//
//  ToastDemoHarness.swift
//  Howl Demo App
//
//  Created by Ky on 2026-04-09.
//

import SwiftUI

@testable import Howl
import FunctionTools



struct ToastDemoHarness<Style: ToastStyle, ExtraConfiguration: View>: View {
    
    @State
    private var showToast = false
    
    @State
    private var text = "Hello, toast!"
    
    @State
    private var duration: ToastConfiguration.Duration = .actionFeedback
    
    @State
    private var useIcon = false
    
    @State
    private var icon: Image? = nil
    
    @State
    private var useCallToAction = false
    
    @State
    private var callToActionString = "Say hi"
    
    private let style: Style
    private let supportedFeatures: Set<SupportedFeature>
    private let extraConfiguration: (() -> ExtraConfiguration)?
    
    
    init(style: Style, supportedFeatures: Set<SupportedFeature>, @ViewBuilder extraConfiguration: @escaping () -> ExtraConfiguration) {
        self.style = style
        self.supportedFeatures = supportedFeatures
        self.extraConfiguration = extraConfiguration
    }
    
    
    init(style: Style, supportedFeatures: Set<SupportedFeature>)
    where ExtraConfiguration == EmptyView
    {
        self.style = style
        self.supportedFeatures = supportedFeatures
        self.extraConfiguration = nil
    }
    
    
    var body: some View {
        DemoHarness {
            
            positionedForm
            
                .toast(
                    isPresented: $showToast,
                    configuration: configuration)
                .toastStyle(style)
            
            
        }
        additionalPrimaryControls: {
            Button("Hide") {
                showToast = false
            }
            .disabled(!showToast)
        }
        didPressShow: {
            showToast = true
        }
        .animation(.bouncy, value: useCallToAction)
        .animation(.bouncy, value: useIcon)
//        .environment(\.debugOverlay, true)
    }
    
    
    var positionedForm: some View {
#if os(macOS)
            ZStack {
                form
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
#elseif os(iOS)
        ZStack {
            Rectangle()
                .fill(.clear)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            form
                .scrollDisabled(true)
                .formStyle(.grouped)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
#endif
    }
    
    
    var form: some View {
            Form {
                Section {
                    TextField("Text (Markdown)", text: $text)
                    
                    Picker("Duration", selection: $duration) {
                        ForEach(ToastConfiguration.Duration.allCases) { duration in
                            Text(verbatim: "\(duration)")
                                .tag(duration)
                        }
                    }
                }
                footer: {
                    Group {
                        switch duration {
                        case .actionFeedback,
                                .importantText:
                            Text("This toast will show for \(configuration.secondsText) seconds.")
                            
                        case .manualDismiss:
                            Text("This toast will show until dismissed.")
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                
                if supports(.icon) {
#if os(macOS)
                    Divider()
#endif
                    
                    Section {
                        Toggle("Use icon?", isOn: $useIcon)
                        
                        Group {
                            if useIcon {
                                ImageWell($icon)
                            }
                        }
                        .transition(.move(edge: .top).combined(with: .opacity).animation(.bouncy))
                    }
                    .animation(.bouncy, value: useIcon)
                }
                
                if supports(.callToAction) {
#if os(macOS)
                    Divider()
#endif
                    
                    Section {
                        Toggle("Use call-to-action?", isOn: $useCallToAction)
                        
                        Group {
                            if useCallToAction {
                                TextField("CTA label", text: $callToActionString)
                            }
                        }
                        .transition(.move(edge: .top).combined(with: .opacity).animation(.bouncy))
                    }
                    footer: {
                        if useCallToAction {
                            Text("""
                            Demo toast CTA ignores presses.
                            You can specify CTA actions as a dev.
                            """)
                            .layoutPriority(-1)
                            .fixedSize(horizontal: false, vertical: false)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .transition(.move(edge: .top).combined(with: .opacity).animation(.bouncy))
                        }
                    }
                }
                
                if let extraConfiguration {
#if os(macOS)
                    Divider()
#endif
                    
                    extraConfiguration()
                }
            }
#if os(macOS)
            .fixedSize()
            .padding(8)
#else
            .frame(maxHeight: 12 * 30)
            .padding(.vertical)
#endif
            
            .glassEffect(in: RoundedRectangle(cornerRadius: 12))
    }
}



extension ToastDemoHarness {
    enum SupportedFeature: String, CaseIterable, Identifiable {
        case icon
        case callToAction
        
        var id: Self { self }
    }
}



private extension ToastDemoHarness {
    var configuration: ToastConfiguration {
        ToastConfiguration(
            text: (try? .init(markdown: text)) ?? .init(text),
            duration: duration,
            icon: useIcon ? (icon ?? Image(.notificationTest)) : nil,
            callToAction: useCallToAction ? callToAction : nil
        )
    }
    
    
    var callToAction: ToastConfiguration.CallToAction? {
        .init(label: callToActionString, userDidInteract: null)
    }
    
    
    func supports(_ feature: SupportedFeature) -> Bool {
        supportedFeatures.contains(feature)
    }
}



extension ToastConfiguration.Duration: @retroactive Identifiable {
    public var id: Int {
        hashValue
    }
}



extension ToastConfiguration {
    func durationInSecondsIfAppearingNow() -> TimeInterval {
        let now = Date.now
        return disappearDate(appearingAt: now).timeIntervalSince(now)
    }
    
    
    var secondsText: String {
        durationInSecondsIfAppearingNow()
            .formatted(.number
                .rounded(increment: 0.1)
                .precision(.integerAndFractionLength(
                    integerLimits: 1...,
                    fractionLimits: 0...2))
            )
    }
}



#Preview("Bezel") {
    ToastDemoHarness(style: .bezel, supportedFeatures: [.icon])
}

#Preview("Snackbar") {
    ToastDemoHarness(style: .snackbar, supportedFeatures: [.callToAction])
}

#Preview("Capsule") {
    ToastDemoHarness(style: .capsule, supportedFeatures: [.callToAction])
}
