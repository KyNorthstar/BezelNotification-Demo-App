//
//  SystemBezelDemo.swift
//  Howl Demo App
//
//  Created by Ky on 2026-04-07.
//

import Combine
import SwiftUI

import CollectionTools
import CrossKitTypes
import FunctionTools
import RectangleTools



private let copyrightLinkUrl = URL(string: "https://github.com/BlueHuskyStudios/BezelNotification")!



struct DemoHarness<Content: View, AdditionalPrimaryControls: View>: View {
    
    @Environment(\.openURL)
    private var openUrl
    
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass
    
    private let allowedBackgrounds: [PreviewBackground]
    private var content: () -> Content
    private var additionalPrimaryControls: () -> AdditionalPrimaryControls
    private var didPressShow: () -> Void
    
    @State
    private var background: PreviewBackground = .image
    
    @State
    private var showContent = true
    
    
    init(allowedBackgrounds: Set<PreviewBackground>? = nil,
         @ViewBuilder content: @escaping () -> Content,
         @ViewBuilder additionalPrimaryControls: @escaping () -> AdditionalPrimaryControls,
         didPressShow: @escaping () -> Void)
    {
        self.allowedBackgrounds = allowedBackgrounds?.nonEmptyOrNil.map { Array($0) } ?? PreviewBackground.allCases
        self.background = self.allowedBackgrounds.contains(.image)
            ? .image
            : (self.allowedBackgrounds.first ?? .image)
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
            if showContent {
                content()
            }
            Spacer()
            
            bottomBar
        }
        .previewBackground(background)
        
        .toolbar {
            if allowedBackgrounds.count > 1 {
                ToolbarItem(placement: .secondaryAction) {
                    Picker("Background", selection: $background) {
                        ForEach(allowedBackgrounds) { background in
                            Label(background.localizedDescription,
                                  systemImage: background.systemImage)
                                .id(background)
                                .tag(background)
                        }
                    }
                    .pickerStyle(.inline)
                }
            }
        }
#else
        NavigationStack {
            ZStack {
                Rectangle().fill(.clear)
                
                if showContent {
                    content()
                }
            }
            .toolbar {
                ToolbarItem(placement: .title) {
                    creatorLink
//                                .padding(EdgeInsets(eachVertical: 2, eachHorizontal: 4))
//                                .background {
//                                    RoundedRectangle(cornerRadius: 12)
//                                        .fill(.thinMaterial)
//                                }
                }
                
                if allowedBackgrounds.count > 1 {
                    ToolbarItem(placement: .secondaryAction) {
                        Picker("Background", selection: $background) {
                            ForEach(allowedBackgrounds) { background in
                                Label(background.localizedDescription,
                                      systemImage: background.systemImage)
                                    .id(background)
                                    .tag(background)
                            }
                        }
                    }
                    .sharedBackgroundVisibility(.hidden)
                }
                
                ToolbarItem(placement: .primaryAction) {
                    additionalPrimaryControls()
                }
                ToolbarItem(placement: .primaryAction) {
                    showButton
                }
            }
            .toolbarBackground(Material.thinMaterial)
            .toolbarBackgroundVisibility(.visible)
            .toolbarTitleDisplayMode(.inlineLarge)
            .previewBackground(background)
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
            HStack {
                Image(.logoMonochrome)
                
                switch horizontalSizeClass {
                case .regular:
                    VStack(alignment: .leading, spacing: -2) {
                        Text("Howl")
                            .font(.title)
                        Text("Toasts for SwiftUI")
                            .font(.subheadline)
                    }
                    .padding(.bottom, 2)
                    
                case .compact,
                        .none:
                    Spacer()
                    
                @unknown default:
                    Spacer()
                }
            }
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



enum PreviewBackground: CaseIterable, Identifiable, Hashable {
    case image
    case fakeApp
    
    var id: Self { self }
    
    var localizedDescription: LocalizedStringKey {
        switch self {
        case .image:   "Photo"
        case .fakeApp: "Fake app"
        }
    }
    
    
    var systemImage: String {
        switch self {
        case .image:   "photo"
        case .fakeApp: "app.dashed"
        }
    }
}



private extension View {
    func previewBackground(_ previewBackground: PreviewBackground) -> some View {
        self
            .background {
                switch previewBackground {
                case .image:
                    backgroundImage
                case .fakeApp:
                    FakeApp()
                }
            }
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
        Button("Other control", systemImage: "character.book.closed.ko", action: null)
    }
    didPressShow: {}
}
