//
//  SystemBezelDemo.swift
//  Howl Demo App
//
//  Created by Ky on 2026-04-07.
//

import Combine
import SwiftUI

@testable import Howl
import CrossKitTypes
import FunctionTools
import RectangleTools



private let copyrightLinkUrl = URL(string: "https://KyLeggiero.me")!
private let previewBezelSize = CGSize(square: 222)



#if os(macOS)
struct SystemBezelDemo: View {
    
    @Environment(\.colorScheme)
    private var colorScheme
    
    @State
    private var draftParameters = SystemBezelNotification.Parameters(messageText: "Hello, bezel!")
    
    @State
    private var publishers = Set<AnyCancellable>()
    
    @FocusState
    private var focusTextField: Bool
    
    
    var body: some View {
        DemoHarness {
            ZStack {
                preview
                
                HStack {
                    Spacer()
                        .layoutPriority(2)
                    
                    Rectangle()
                        .fill(.clear)
                        .frame(width: previewBezelSize.width, height: previewBezelSize.height)
                    
                    HStack {
                        Spacer(minLength: 8).fixedSize()
                        
                        Form {
                            unLaidOutParameters
                        }
                        .padding(8)
                        .glassEffect(
                            //.regular.tint(Color(nsColor: .windowBackgroundColor)),
                            in: RoundedRectangle(cornerRadius: 20)
                        )
                        .fixedSize()
                        
                        Spacer()
                    }
                    .layoutPriority(2)
                }
            }
        }
        additionalPrimaryControls: {
            hideAllButton
        }
        didPressShow: {
            didPressShow()
        }
        
        .onChange(of: publishers) { oldPublishers, newPublishers in
            oldPublishers
                .subtracting(newPublishers)
                .forEach { $0.cancel() }
        }
        .onAppear {
            Task { @MainActor in
                // I hate that I have to do this...
                try? await Task.sleep(for: .milliseconds(0))
                focusTextField = true
            }

        }
    }
}



private extension SystemBezelDemo {
    
    var preview: some View {
        previewBezel {
            VStack {
                let bezelSize = draftParameters.size.cgSize
                let imageWellSize = CGSize(square: 999)
                    .scaled(within: bezelSize * 0.6,
                            method: .fit,
                            direction: .upOrDown)
                
                Spacer()
                
                ImageWell(Binding {
                    draftParameters.icon.map { Image(nativeImage: $0) }
                } set: { newValue in
                    draftParameters.icon = newValue?.nativeImage()
                })
                .frame(maxWidth: imageWellSize.width, maxHeight: imageWellSize.height)
                
                Spacer()
                
                TextField("Message text", text: $draftParameters.messageText)
                    .textFieldStyle(.plain)
                    .focused($focusTextField)
                    .font(.init(draftParameters.messageLabelFont))
                    .multilineTextAlignment(.center)
                    .padding(EdgeInsets(eachVertical: 2, eachHorizontal: 6))
                    .background {
                        RoundedRectangle(cornerRadius: draftParameters.messageLabelFont.pointSize)
                            .stroke(.gray.blendMode(.screen), lineWidth: 1.5)
                    }
                    .padding(.horizontal)
            }
            .padding(.bottom)
        }
    }
    
    
    private func previewBezel<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Rectangle()
                    .fill(.thinMaterial)
                    .materialActiveAppearance(.active)
                    .frame(width: draftParameters.size.cgSize.width,
                           height: draftParameters.size.cgSize.height)
                    .overlay {
                        ZStack {
                            Color(draftParameters.backgroundTint)
                            content()
                        }
                        .compositingGroup()
                        .blendMode(bestForegroundBlendMode(in: colorScheme))
                    }
                    .clipShape(RoundedRectangle(cornerRadius: SystemBezelNotification.Parameters.defaultCornerRadius))
                
                Spacer()
            }
            Spacer()
        }
    }
    
    
    @ViewBuilder
    var unLaidOutParameters: some View {
        Picker("Timeout", selection: $draftParameters.timeToLive) {
            Text("Short")
                .tag(BezelNotificationParameters.TimeToLive.short)
            
            Text("Long")
                .tag(BezelNotificationParameters.TimeToLive.long)
            
            Text("Forever")
                .tag(BezelNotificationParameters.TimeToLive.forever)
        }
        .buttonBorderShape(.capsule)
        
        ColorPicker(
            "Tint",
            selection: Binding {
                Color(draftParameters.rawBackgroundTint)
            } set: { newValue in
                draftParameters.rawBackgroundTint = .init(newValue)
            },
            supportsOpacity: true,
        )
    }
    
    
    var hideAllButton: some View {
        Button("Hide all") {
            publishers = []
        }
        .disabled(publishers.isEmpty)
    }
    
    
    func didPressShow() {
            var parameters = draftParameters
            if parameters.icon == nil {
                parameters.icon = .notificationTest
            }
            
            SystemBezelNotification.show(with: parameters)
                .sink(receiveValue: null)
                .store(in: &publishers)
    }
    
    
    private func bestForegroundBlendMode(in colorScheme: ColorScheme) -> BlendMode {
        switch colorScheme {
        case .dark: .plusLighter
        case .light: .plusDarker
        @unknown default: .normal
        }
    }
}



#Preview {
    SystemBezelDemo()
}
#endif
