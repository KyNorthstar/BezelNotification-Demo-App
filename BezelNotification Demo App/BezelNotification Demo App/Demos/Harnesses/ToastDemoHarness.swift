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
    private var useCallToAction = false
    
    @State
    private var callToActionString = "Say hi"
    
    private let style: Style
    private let extraConfiguration: () -> ExtraConfiguration
    
    
    init(style: Style, @ViewBuilder extraConfiguration: @escaping () -> ExtraConfiguration) {
        self.style = style
        self.extraConfiguration = extraConfiguration
    }
    
    
    init(style: Style)
    where ExtraConfiguration == EmptyView
    {
        self.init(style: style, extraConfiguration: EmptyView.init)
    }
    
    
    var body: some View {
        DemoHarness {
            ZStack {
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
                    
                    Divider()
                    
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
                .fixedSize()
                .padding(8)
                .glassEffect(in: RoundedRectangle(cornerRadius: 12))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            
                .toast(
                    isPresented: $showToast,
                    configuration: configuration)
                .toastStyle(style)
            
            
        }
        additionalBottomBarControls: {
            Button("Hide") {
                showToast = false
            }
            .disabled(!showToast)
        }
        didPressShow: {
            showToast = true
        }
        .animation(.bouncy, value: useCallToAction)
//        .environment(\.debugOverlay, true)
    }
    
    
    private var configuration: ToastConfiguration {
        ToastConfiguration(
            text: (try? .init(markdown: text)) ?? .init(text),
            duration: duration,
            icon: icon,
            callToAction: useCallToAction ? callToAction : nil
        )
    }
    
    
    private var callToAction: ToastConfiguration.CallToAction? {
        .init(label: callToActionString, userDidInteract: null)
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
