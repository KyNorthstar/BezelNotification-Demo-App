//
//  NativeImage + SwiftUI.swift
//  BezelNotification Demo App
//
//  Created by Ky on 2026-04-08.
//

import SwiftUI

import CrossKitTypes



extension Image {
    func nativeImage(scale: CGFloat = 1) -> NativeImage? {
        let renderer = ImageRenderer(content: self)
        renderer.scale = scale
        
        #if canImport(AppKit)
        return renderer.nsImage
        #elseif canImport(UIKit)
        return renderer.uiImage
        #endif
    }
}
