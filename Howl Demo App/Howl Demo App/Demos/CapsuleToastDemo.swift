//
//  CapsuleToastDemo.swift
//  Howl Demo App
//
//  Created by Ky on 2026-04-10.
//

import SwiftUI

import Howl



struct CapsuleToastDemo: View {
    var body: some View {
        ToastDemoHarness(style: .capsule, supportedFeatures: [.callToAction])
    }
}



#Preview {
    CapsuleToastDemo()
}
