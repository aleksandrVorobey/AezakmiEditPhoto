//
//  ImageEditorViewModel.swift
//  AezakmiEditPhoto
//
//  Created by Александр Воробей on 22.04.2025.
//

import SwiftUI
import PencilKit

@MainActor
class ImageEditorViewModel: ObservableObject {
    @Published var image: UIImage
    private var originalImage: UIImage
    @Published var displayedRect: CGRect = .zero
    @Published var currentImageSize: CGSize

    @Published var isDrawing = false
    @Published var isRotating = false
    @Published var rotationAngle: CGFloat = 0
    @Published var isAddingText = false
    @Published var textElements: [TextElement] = []
    @Published var selectedTextIndex: Int?

    @Published var isApplyingFilter = false
    @Published var selectedFilter: ImageFilter?

    let canvasView = PKCanvasView()
    var toolPicker: PKToolPicker?

    init(image: UIImage) {
        self.image = image
        self.originalImage = image
        self.currentImageSize = image.size
    }

    func startDrawing() {
        let picker = PKToolPicker()
        picker.setVisible(true, forFirstResponder: canvasView)
        picker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
        toolPicker = picker
    }

    func finishDrawing(in frame: CGRect) {
        let drawingImage = canvasView.drawing.image(from: canvasView.bounds, scale: 1.0)
        let imgSize = image.size

        let renderer = UIGraphicsImageRenderer(size: imgSize)
        let combined = renderer.image { context in
            image.draw(at: .zero)
            let scaleX = imgSize.width / frame.width
            let scaleY = imgSize.height / frame.height
            context.cgContext.scaleBy(x: scaleX, y: scaleY)
            drawingImage.draw(at: .zero)
        }

        image = combined
        originalImage = combined
        canvasView.drawing = PKDrawing()
        toolPicker?.setVisible(false, forFirstResponder: canvasView)
        toolPicker?.removeObserver(canvasView)
        canvasView.resignFirstResponder()
        isDrawing = false
    }

    func incrementRotation(containerSize: CGSize) {
        withAnimation(.easeInOut(duration: 0.3)) {
            rotationAngle += 90
            let isSwapped = Int(rotationAngle) % 180 != 0
            currentImageSize = isSwapped
                ? CGSize(width: image.size.height, height: image.size.width)
                : image.size
            recalculateDisplayedRect(containerSize: containerSize)
        }
    }

    func applyRotation(for containerSize: CGSize) {
        let radians = rotationAngle * .pi / 180
        let originalSize = image.size

        let isSwapped = Int(rotationAngle) % 180 != 0
        let rotatedSize = isSwapped
            ? CGSize(width: originalSize.height, height: originalSize.width)
            : originalSize

        let renderer = UIGraphicsImageRenderer(size: rotatedSize)
        let rotatedImage = renderer.image { ctx in
            ctx.cgContext.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
            ctx.cgContext.rotate(by: radians)
            ctx.cgContext.translateBy(x: -originalSize.width / 2, y: -originalSize.height / 2)
            image.draw(in: CGRect(origin: .zero, size: originalSize))
        }

        let result = rotatedImage
        image = result
        originalImage = result
        rotationAngle = 0
        isRotating = false
        currentImageSize = rotatedImage.size
        recalculateDisplayedRect(containerSize: containerSize)
    }

    func recalculateDisplayedRect(containerSize: CGSize) {
        let scale = min(containerSize.width / currentImageSize.width,
                        containerSize.height / currentImageSize.height)
        let fittedSize = CGSize(width: currentImageSize.width * scale,
                                height: currentImageSize.height * scale)
        let origin = CGPoint(x: (containerSize.width - fittedSize.width) / 2,
                             y: (containerSize.height - fittedSize.height) / 2)
        displayedRect = CGRect(origin: origin, size: fittedSize)
    }

    func addNewTextAtCenter(panelHeight: CGFloat, containerSize: CGSize) {
        let textPosition = CGPoint(
            x: containerSize.width / 2,
            y: panelHeight + 50
        )
        
        let newElement = TextElement(
            text: "",
            position: textPosition,
            fontSize: 24,
            color: .black,
            fontStyle: .system
        )
        textElements.append(newElement)
        selectedTextIndex = textElements.count - 1
    }
    
    func addNewText(at position: CGPoint) {
        let newElement = TextElement(
            text: "Новый текст",
            position: position,
            fontSize: 24,
            color: .white,
            fontStyle: .system
        )
        textElements.append(newElement)
        selectedTextIndex = textElements.count - 1
        isAddingText = true
    }
    
    func updateSelectedText(_ text: String) {
        guard let index = selectedTextIndex else { return }
        textElements[index].text = text
    }
    
    func updateTextPosition(_ position: CGPoint, for index: Int) {
        textElements[index].position = position
    }
    
    func updateTextColor(_ color: Color) {
        guard let index = selectedTextIndex else { return }
        textElements[index].color = color
    }
    
    func updateTextFont(_ style: TextElement.FontStyle) {
        guard let index = selectedTextIndex else { return }
        textElements[index].fontStyle = style
    }
    
    func updateTextSize(_ size: CGFloat) {
        guard let index = selectedTextIndex else { return }
        textElements[index].fontSize = size
    }
    
    func finishTextEditing() {
        selectedTextIndex = nil
        isAddingText = false
    }
    
    func applyTextToImage() {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        let newImage = renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: image.size))
            
            for element in textElements {
                let viewToImageScaleX = image.size.width / displayedRect.width
                let viewToImageScaleY = image.size.height / displayedRect.height
                
                let imageX = (element.position.x - displayedRect.minX) * viewToImageScaleX
                let imageY = (element.position.y - displayedRect.minY) * viewToImageScaleY
                
                var font: UIFont
                switch element.fontStyle {
                case .system:
                    font = .systemFont(ofSize: element.fontSize * viewToImageScaleX)
                case .rounded:
                    font = UIFont.systemFont(ofSize: element.fontSize * viewToImageScaleX, weight: .regular)
                case .serif:
                    if let serif = UIFont(name: "TimesNewRomanPSMT", size: element.fontSize * viewToImageScaleX) {
                        font = serif
                    } else {
                        font = .systemFont(ofSize: element.fontSize * viewToImageScaleX)
                    }
                }
                
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor(element.color),
                    .font: font
                ]
                
                let textSize = (element.text as NSString).size(withAttributes: attributes)
                let drawPoint = CGPoint(
                    x: imageX - textSize.width / 2,
                    y: imageY - textSize.height / 2
                )
                
                (element.text as NSString).draw(at: drawPoint, withAttributes: attributes)
            }
        }
        
        image = newImage
        originalImage = newImage
        textElements.removeAll()
        selectedTextIndex = nil
        isAddingText = false
    }
    
    func applyFilter(_ filter: ImageFilter) {
        if let filteredImage = filter.apply(to: originalImage) {
            image = filteredImage
            selectedFilter = filter
        }
    }
}
