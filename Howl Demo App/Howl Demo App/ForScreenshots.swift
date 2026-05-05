//
//  ForScreenshots.swift
//  Howl Demo App
//
//  Created by Ky on 2026-05-04.
//

import SwiftUI

@testable import Howl
import RectangleTools



struct ForScreenshots: View {
    
    @Environment(\.self)
    var environment
    
    var body: some View {
        ZStack {
            Color(hue: 155/360, saturation: 0.24, brightness: 0.98)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Text("""
                    Howl is a way to present toasts in your apps in Apple platforms.
                    
                    Toasts are brief messages that appear on-screen for a moment, to tell the user that something happened, and then go away.
                    
                    They're a very common paradigm in Android, and Apple system-level things sometimes use them as well, though folks have historically called these things like "bezel notifications" "popup UI", etc.. Things like the volume UI coming up when you change the volume, or Xcode's "Build Succeeded", or the Apple Pencil charging UI when you place it on the side of your iPad.
                    
                    This package is designed to strike a balance between ease-of-use and customizability. For instance, this is the primary way it is intended to be used in the general case:
                    """)
                .padding(.bottom, -100)
                .padding(.leading, 200)
            }
            .ignoresSafeArea(.all, edges: .vertical)
            
            VStack(alignment: .trailing) {
                Spacer()
                    .layoutPriority(1)
                
                HStack(alignment: .lastTextBaseline) {
                    Spacer()
                    
                    snackbar
                    //                    SnackbarToastStyle.snackbar.body(
                    //                        ToastConfiguration(
                    //                            text: "Marked as read",
                    //                            duration: .manualDismiss,
                    //                            icon: nil,
                    //                            callToAction: .init(label: "Undo", dismissOnInteraction: true, userDidInteract: {})),
                    //                        environment: environment)
                    
                    capsule
                    //                    CapsuleToastStyle.capsule.body(
                    //                        ToastConfiguration(
                    //                            text: "Link copied",
                    //                            duration: .manualDismiss,
                    //                            icon: nil,
                    //                            callToAction: nil),
                    //                        environment: environment)
                    
                    bezel
                        .offset(x: 10, y: 21)
                }
                .padding(.trailing, 45)
            }
        }
        //            .toast(isPresented: .constant(true), text: "Marked as read", duration: .manualDismiss, icon: nil, action: .init(label: "Undo", dismissOnInteraction: true, userDidInteract: {}))
        //            .toastStyle(.snackbar)
    }
}



extension ForScreenshots {
    var capsule: some View {
        Text("Link copied")
            .padding(EdgeInsets(eachVertical: 8, eachHorizontal: 12))
            .background {
                Capsule()
                        .glassEffect(.regular.tint(.black))
            }
            .shadow(radius: 6, y: 2)
            .font(.body)
            .geometryGroup()
            .colorScheme(.dark)
    }
}



extension ForScreenshots {
    var snackbar: some View {
        HStack(spacing: 0) {
            HStack(spacing: 12) {
                Text("Email sent")
                    .contentTransition(.interpolate)
                
                Button("Undo", action: {})
                    .fontWeight(.medium)
                    .foregroundStyle(ctaButtonForegroundColor)
                    .shadow(color: .accentColor.opacity(0.5), radius: 8)
                    .buttonStyle(.plain)
                    .contentTransition(.interpolate)
                    .transition(.move(edge: .leading).combined(with: .blurReplace).animation(.bouncy))
            }
            .font(.body)
            .padding()
            .background {
                shape
                    .fill(.clear)
                    .glassEffect(.regular.tint(glassEffectTint(in: environment)), in: shape)
                    .shadow(radius: 6, y: 2)
            }
            .padding()
        }
    }
    
    
    private var shape: some Shape { RoundedRectangle(cornerRadius: 8) }
    
    
    /// The foreground color of the call-to-action button
    var ctaButtonForegroundColor: Color {
        Color.accentColor.mix(with: .primary, by: 0.1)
    }
    
    
    /// The most-appropriate tint of the glass effect in the current environment
    ///
    /// - Parameter environment: The current environment values, so the snackbar can be built correctly
    func glassEffectTint(in environment: EnvironmentValues) -> Color {
        switch environment.colorScheme {
        case .dark:  .black.opacity(0.6)
        case .light: .clear
            
        @unknown default: .clear
        }
    }
}



extension ForScreenshots {
    var bezel: some View {
        bezel(environment: environment) {
            VStack {
                let bezelSize = BezelNotificationParameters.defaultSize.cgSize
                let idealImageSize = CGSize(square: (bezelSize * 0.6).minMeasurement)
                
                VStack(spacing: 0) {
                    Spacer()
                    Image(.notificationTest)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: idealImageSize.width, maxHeight: idealImageSize.height)
                    Spacer()
                }
                .transition(.blurReplace)
                
                Text("Made by Ky")
                #if os(macOS)
                    .font(.system(.title, weight: .medium))
                #else
                    .font(.system(.title3, weight: .medium))
                #endif
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .frame(maxHeight: nil)
                    .contentTransition(.interpolate)
                    .padding(.horizontal)
                    .id("Message")
                    .padding(.bottom, nil)
            }
        }
    }
    
    
    @ViewBuilder
    private func bezel<Content: View>(
        environment: EnvironmentValues,
        @ViewBuilder content: () -> Content)
    -> some View {
        Rectangle()
            .glassEffect(in: RoundedRectangle(cornerRadius: BezelNotificationParameters.defaultCornerRadius))
            .frame(width: environment.dynamicTypeSize.isAccessibilitySize ? nil : 200,
                   height: 200)
            .overlay {
                ZStack {
                    Color(.clear)
                    content()
                        .foregroundStyle(.secondary)
                }
                .compositingGroup()
                .blendMode(bestForegroundBlendMode(in: environment.colorScheme))
            }
            .clipShape(RoundedRectangle(cornerRadius: BezelNotificationParameters.defaultCornerRadius))
            .materialActiveAppearance(.active)
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
    ForScreenshots()
}
