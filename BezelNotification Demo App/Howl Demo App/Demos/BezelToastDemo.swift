//
//  BezelToastDemo.swift
//  Howl Demo App
//
//  Created by Ky on 2026-04-10.
//

import SwiftUI

import Howl



struct BezelToastDemo: View {
    
    @State
    var effect: BezelToastStyle.Effect? = nil
    
    var body: some View {
        ToastDemoHarness(style: .bezel(effect: effect), supportedFeatures: [.icon]) {
            Picker("Effect", selection: $effect) {
                Text("Default")
                    .tag(BezelToastStyle.Effect?.none)
                
                ForEach(BezelToastStyle.Effect.allCases) { effect in
                    Text(effect.localizedDescription)
                        .tag(effect)
                }
            }
        }
    }
}



#Preview {
    BezelToastDemo()
}
