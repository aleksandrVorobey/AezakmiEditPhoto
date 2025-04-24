//
//  ImageEditorView.swift
//  AezakmiEditPhoto
//
//  Created by Александр Воробей on 22.04.2025.
//

import SwiftUI
import PencilKit

struct ImageEditorView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: ImageEditorViewModel
    @State private var containerSize: CGSize = .zero
    var onSave: (UIImage) -> Void
    
    init(image: UIImage, onSave: @escaping (UIImage) -> Void) {
        _viewModel = StateObject(wrappedValue: ImageEditorViewModel(image: image))
        self.onSave = onSave
    }
    
    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geo in
                ZStack {
                    
                    Image(uiImage: viewModel.image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .rotationEffect(.degrees(viewModel.rotationAngle))
                        .animation(.spring, value: 0.5)
                        .frame(maxWidth: geo.size.width, maxHeight: geo.size.height)
                    
                    if viewModel.isDrawing {
                        CanvasView(canvasView: viewModel.canvasView)
                            .frame(width: viewModel.displayedRect.width,
                                   height: viewModel.displayedRect.height)
                            .position(x: viewModel.displayedRect.midX,
                                      y: viewModel.displayedRect.midY)
                    }
                    
                    ForEach(viewModel.textElements) { element in
                        Text(element.text)
                            .font(element.font)
                            .foregroundColor(element.color)
                            .position(element.position)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        if let index = viewModel.textElements.firstIndex(where: { $0.id == element.id }) {
                                            viewModel.updateTextPosition(value.location, for: index)
                                        }
                                    }
                            )
                            .onTapGesture {
                                if let index = viewModel.textElements.firstIndex(where: { $0.id == element.id }) {
                                    viewModel.selectedTextIndex = index
                                    viewModel.isAddingText = true
                                }
                            }
                    }
                    
                    if viewModel.isAddingText {
                        TextEditingView(viewModel: viewModel)
                            .frame(maxWidth: 300)
                            .position(x: geo.size.width / 2, y: geo.size.height - 200)
                    }
                }
                .contentShape(Rectangle())
                .onChange(of: geo.size) { oldValue, newValue in
                    if newValue.width != oldValue.width || newValue.height != oldValue.height {
                        containerSize = newValue
                        viewModel.recalculateDisplayedRect(containerSize: newValue)
                    }
                }
            }
            
            if viewModel.isApplyingFilter {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(ImageFilter.allCases, id: \.self) { filter in
                            VStack {
                                Image(uiImage: filter.apply(to: viewModel.image) ?? viewModel.image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(filter == viewModel.selectedFilter ? Color.blue : Color.clear, lineWidth: 2)
                                    )
                                Text(filter.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                            .onTapGesture {
                                viewModel.selectedFilter = filter
                                viewModel.applyFilter(filter)
                            }
                        }
                    }
                    .padding()
                }
                .background(Color.black)
                .frame(height: 120)
            }
            
            HStack(spacing: 30) {
                if !viewModel.isDrawing && !viewModel.isRotating && !viewModel.isAddingText && !viewModel.isApplyingFilter {
                    Button {
                        viewModel.isDrawing = true
                        viewModel.startDrawing()
                    } label: {
                        Image(systemName: "pencil.tip")
                            .font(.system(size: 24))
                    }
                    
                    Button {
                        viewModel.isRotating = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 24))
                    }
                    
                    Button {
                        viewModel.isAddingText = true
                    } label: {
                        Image(systemName: "textformat")
                            .font(.system(size: 24))
                    }
                    
                    Button {
                        viewModel.isApplyingFilter = true
                    } label: {
                        Image(systemName: "camera.filters")
                            .font(.system(size: 24))
                    }
                }
                
                if viewModel.isRotating {
                    Button {
                        viewModel.incrementRotation(containerSize: containerSize)
                    } label: {
                        Image(systemName: "rotate.right")
                            .font(.system(size: 24))
                    }
                }
                
                Spacer()
            }
            .frame(height: 80)
            .padding(.horizontal)
        }
        .navigationTitle("Редактирование")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if viewModel.isDrawing {
                    Button("Готово") {
                        viewModel.finishDrawing(in: viewModel.displayedRect)
                    }
                } else if viewModel.isRotating {
                    Button("Готово") {
                        viewModel.applyRotation(for: containerSize)
                    }
                } else if viewModel.isAddingText {
                    Button("Готово") {
                        viewModel.applyTextToImage()
                    }
                } else if viewModel.isApplyingFilter {
                    Button("Готово") {
                        viewModel.isApplyingFilter = false
                        viewModel.selectedFilter = nil
                    }
                } else {
                    Button("Сохранить") {
                        onSave(viewModel.image)
                        dismiss()
                    }
                }
            }
        }
    }
}


