//
//  ImageWell.swift
//  Howl Demo App
//
//  Created by Ky on 2026-04-08.
//

import OSLog
import SwiftUI
import UniformTypeIdentifiers
import CrossKitTypes
import RectangleTools



private let wellStrokeWidth: CGFloat = 2
private let colorAtRest = Color(white: 0.5, opacity: 0.5)
private let colorWhenTargeted = Color.accentColor



struct ImageWell: View {
    
    @Binding
    private var selectedImage: Image?
    
    @State
    private var isPickerPresented = false
    
    @State
    private var isTargeted = false
    
    
    init(_ selectedImage: Binding<Image?>) {
        _selectedImage = selectedImage
    }
    
    
    var body: some View {
        // hold the full size of the view
        Rectangle()
            .fill(.clear)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay {
                currentImageView
            }
        
        
            .contextMenu {
                Button("Clear", systemImage: "clear") {
                    selectedImage = nil
                }
            }
        
        
            .onTapGesture {
                isPickerPresented = true
            }
            .pointerStyle(.link)
            .fileImporter(isPresented: $isPickerPresented, allowedContentTypes: [.image]) { result in
                Task {
                    do {
                        let url = try result.get()
                        
                        // Security-scoped resources from fileImporter require
                        // explicit access bracketing before any read can succeed.
                        guard url.startAccessingSecurityScopedResource() else {
                            Logger().error("Failed to acquire security-scoped access for \(url.lastPathComponent)")
                            return
                        }
                        defer { url.stopAccessingSecurityScopedResource() }
                        
                        let imported = try await Image(importing: url, contentType: nil)
                        
                        await MainActor.run {
                            selectedImage = imported
                        }
                    } catch {
                        Logger().error("\(error.localizedDescription)")
                    }
                }
            }
        
        
            .dropDestination(for: Image.self) { items, _ in
                if let firstImage = items.first {
                    selectedImage = firstImage
                    return true
                }
                else {
                    return false
                }
            } isTargeted: { isTargeted in
                self.isTargeted = isTargeted
            }
        
            .frame(minWidth: 72, minHeight: 24)
    }
}



extension ImageWell {
    @ViewBuilder
    var currentImageView: some View {
        RoundedRectangle(cornerRadius: 8)
//            .stroke(isTargeted ? colorWhenTargeted : colorAtRest, lineWidth: wellStrokeWidth)
            .stroke(isTargeted ? colorWhenTargeted : colorAtRest,
                    style: StrokeStyle(
                        lineWidth: wellStrokeWidth,
                        lineCap: .round,
                        lineJoin: .round,
                        dash: isTargeted ? [] : [wellStrokeWidth*3]
                    )
            )
            .fill(Color(white: 0.5, opacity: 0.2))
            .overlay {
                if let selectedImage {
                    let nativeSize = selectedImage.nativeImage()?.size
                    
                    selectedImage
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: nativeSize?.width, maxHeight: nativeSize?.height)
                        .padding(wellStrokeWidth / 2)
                }
                else {
                    Text("Pick an image...")
                        .padding()
                }
            }
    }
}



#Preview {
    @Previewable
    @State
    var selectedImage: Image? = Image(.notificationTest)
    
    
    ImageWell($selectedImage)
}
