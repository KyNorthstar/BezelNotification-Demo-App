//
//  ContentView.swift
//  BezelNotification Demo App
//
//  Created by Ky on 2026-04-07.
//

import Combine
import SwiftUI

@testable import BlueToast
import CrossKitTypes
import FunctionTools
import RectangleTools



private let copyrightLinkUrl = URL(string: "https://KyLeggiero.me")!
private let previewBezelSize = CGSize(square: 222)




struct ContentView: View {
    
    @Environment(\.openURL)
    private var openUrl
    
    @State
    private var draftParameters = SystemBezelNotification.Parameters(messageText: "Hello, bezel!")
    
    @State
    private var publishers = Set<AnyCancellable>()
    
    @FocusState
    private var focusTextField: Bool
    
    
    var body: some View {
        VStack {
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
            
            bottomBar
        }
        
        .background {
            Image(.previewBackground)
                .resizable(resizingMode: .stretch)
                .aspectRatio(contentMode: .fill)
        }
        .background(ignoresSafeAreaEdges: .all)
        
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



private extension ContentView {
    
    var preview: some View {
        previewBezel {
            VStack {
                let bezelSize = draftParameters.size.cgSize
                let imageWellSize = (CGSize.square(999)).scaled(within: bezelSize * 0.6, method: .fit, direction: .upOrDown)
                let iconSize = (draftParameters.icon?.size ?? .square(999)).scaled(within: bezelSize * 0.6, method: .fit, direction: .down)
                
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
                        .blendMode(.plusLighter)
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
                .tag(SystemBezelNotification.TimeToLive.short)
            
            Text("Long")
                .tag(SystemBezelNotification.TimeToLive.long)
            
            Text("Forever")
                .tag(SystemBezelNotification.TimeToLive.forever)
        }
        .buttonBorderShape(.capsule)
        
        ColorPicker(
            "Tint",
            selection: Binding {
                Color(draftParameters.backgroundTint)
            } set: { newValue in
                draftParameters.backgroundTint = .init(newValue)
            },
            supportsOpacity: true,
        )
    }
    
    
    var bottomBar: some View {
        HStack {
            Button {
                openUrl(copyrightLinkUrl)
            }
            label: {
                Text("Made by Ky")
//                    .font(.caption2)
            }
            .buttonStyle(.borderless)
            .controlSize(.mini)
            
            Spacer()
            
            Button("Hide all") {
                publishers = []
            }
            .disabled(publishers.isEmpty)
            
            
            Button("Show") {
                var parameters = draftParameters
                if parameters.icon == nil {
                    parameters.icon = .notificationTest
                }
                
                SystemBezelNotification.show(with: parameters)
                    .sink(receiveValue: null)
                    .store(in: &publishers)
            }
            .buttonStyle(.borderedProminent)
            .keyboardShortcut(.defaultAction)
        }
        .padding()
        .background(Material.ultraThin)
        .materialActiveAppearance(.matchWindow)
    }
}



#Preview {
    ContentView()
}
