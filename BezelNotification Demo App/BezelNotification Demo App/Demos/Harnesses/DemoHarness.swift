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



struct DemoHarness<Content: View, AdditionalBottomBarControls: View>: View {
    
    @Environment(\.openURL)
    private var openUrl
    
    private var content: () -> Content
    private var additionalBottomBarControls: () -> AdditionalBottomBarControls
    private var didPressShow: () -> Void
    
    
    init(@ViewBuilder content: @escaping () -> Content,
         @ViewBuilder additionalBottomBarControls: @escaping () -> AdditionalBottomBarControls,
         didPressShow: @escaping () -> Void)
    {
        self.content = content
        self.additionalBottomBarControls = additionalBottomBarControls
        self.didPressShow = didPressShow
    }
    
    
    init(@ViewBuilder content: @escaping () -> Content,
         didPressShow: @escaping () -> Void)
    where AdditionalBottomBarControls == EmptyView
    {
        self.init(content: content,
                  additionalBottomBarControls: EmptyView.init,
                  didPressShow: didPressShow)
    }
    
    
    var body: some View {
        VStack {
            Spacer()
                content()
            Spacer()
            
            bottomBar
        }
        
        .background {
            Image(.previewBackground)
                .resizable(resizingMode: .stretch)
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
        }
        .background(ignoresSafeAreaEdges: .all)
    }
}



private extension DemoHarness {
    
    
    var bottomBar: some View {
        HStack {
            Button {
                openUrl(copyrightLinkUrl)
            }
            label: {
                Text("Made by Ky")
            }
            .buttonStyle(.borderless)
            .controlSize(.mini)
            
            Spacer()
            
            additionalBottomBarControls()
            
            
            Button("Show", action: didPressShow)
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
        }
        .padding()
        .background(Material.ultraThin)
        .materialActiveAppearance(.matchWindow)
    }
}
