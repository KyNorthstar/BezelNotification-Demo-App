//
//  SnackbarToastDemo.swift
//  Howl Demo App
//
//  Created by Ky on 2026-04-10.
//

import SwiftUI

import Howl



struct SnackbarToastDemo: View {
    var body: some View {
        ToastDemoHarness(style: .snackbar)
    }
}



#Preview {
    SnackbarToastDemo()
}
