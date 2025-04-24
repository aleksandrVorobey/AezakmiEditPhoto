//
//  Canvas.swift
//  AezakmiEditPhoto
//
//  Created by Александр Воробей on 23.04.2025.
//


import SwiftUI
import PencilKit

struct CanvasView: UIViewRepresentable {
    var canvasView: PKCanvasView

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = .clear
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}
