//
//  SystemBezelDemo.swift
//  Howl Demo App
//
//  Created by Ky on 2026-04-07.
//

import Combine
import SwiftUI

import CrossKitTypes
import FunctionTools
import RectangleTools



private let copyrightLinkUrl = URL(string: "https://KyLeggiero.me")!



struct DemoHarness<Content: View, AdditionalPrimaryControls: View>: View {
    
    @Environment(\.openURL)
    private var openUrl
    
    private var content: () -> Content
    private var additionalPrimaryControls: () -> AdditionalPrimaryControls
    private var didPressShow: () -> Void
    
    
    init(@ViewBuilder content: @escaping () -> Content,
         @ViewBuilder additionalPrimaryControls: @escaping () -> AdditionalPrimaryControls,
         didPressShow: @escaping () -> Void)
    {
        self.content = content
        self.additionalPrimaryControls = additionalPrimaryControls
        self.didPressShow = didPressShow
    }
    
    
    init(@ViewBuilder content: @escaping () -> Content,
         didPressShow: @escaping () -> Void)
    where AdditionalPrimaryControls == EmptyView
    {
        self.init(content: content,
                  additionalPrimaryControls: EmptyView.init,
                  didPressShow: didPressShow)
    }
    
    
    var body: some View {
        controls
        
    }
    
    
    var controls: some View {
#if os(macOS)
        VStack {
            Spacer()
            content()
            Spacer()
            
            bottomBar
        }
        .previewBackground()
#else
        NavigationStack {
            ZStack {
                Rectangle().fill(.clear)
                
                content()
                    .toolbar {
                        ToolbarItem(placement: .title) {
                            creatorLink
//                                .padding(EdgeInsets(eachVertical: 2, eachHorizontal: 4))
//                                .background {
//                                    RoundedRectangle(cornerRadius: 12)
//                                        .fill(.thinMaterial)
//                                }
                        }
                        
                        ToolbarItem(placement: .confirmationAction) {
                            additionalPrimaryControls()
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            showButton
                        }
                    }
                    .toolbarBackground(Material.thinMaterial)
                    .toolbarBackgroundVisibility(.visible)
                    .toolbarTitleDisplayMode(.inlineLarge)
            }
            .previewBackground()
        }
#endif
    }
}



private extension DemoHarness {
    
#if os(macOS)
    var bottomBar: some View {
        HStack {
            creatorLink
            
            Spacer()
            
            additionalPrimaryControls()
            
            showButton
        }
        .padding()
        .background(Material.ultraThin)
        .materialActiveAppearance(.matchWindow)
    }
#endif
    
    
    var creatorLink: some View {
        Button {
            openUrl(copyrightLinkUrl)
        }
        label: {
            VStack(alignment: .leading, spacing: -2) {
                Text("Howl")
                    .font(.title)
                Text("Toasts for SwiftUI")
                    .font(.subheadline)
            }
            .padding(.bottom, 2)
        }
#if os(macOS)
        .buttonStyle(.borderless)
#endif
        .controlSize(.mini)
    }
    
    
    var showButton: some View {
        Button("Show", action: didPressShow)
            .buttonStyle(.borderedProminent)
            .keyboardShortcut(.defaultAction)
    }
}



private extension View {
    func previewBackground() -> some View {
        self
            .background {
                backgroundImage
            }
//            .background(Image(.previewBackground))
            .background(ignoresSafeAreaEdges: .all)
    }
    
    
    var backgroundImage: some View {
        Image(.previewBackground)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .ignoresSafeArea()
    }
}



#Preview {
    DemoHarness {
        ZStack {
            Text("Awoo, World!")
                .padding()
                .glassEffect(in: RoundedRectangle(cornerRadius: 12))
        }
    }
    additionalPrimaryControls: {
        Button("Howl") {}
    }
    didPressShow: {}
}
