//
//  Image + CrossKitTypes.swift
//  Howl Demo App
//
//  Created by Ky on 2026-04-08.
//

import SwiftUI

import CrossKitTypes



public extension Image {
    init(nativeImage: NativeImage) {
        #if canImport(AppKit)
        self.init(nsImage: nativeImage)
        #elseif canImport(UIKit)
        self.init(uiImage: nativeImage)
        #else
        #error("Unsupported platform")
        #endif
    }
}
