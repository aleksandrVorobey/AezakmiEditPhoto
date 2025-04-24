//
//  CGSize.swift
//  AezakmiEditPhoto
//
//  Created by Александр Воробей on 24.04.2025.
//

import CoreGraphics

extension CGSize {
    func aspectFitRect(for imageSize: CGSize) -> CGRect {
        let scale = min(width / imageSize.width, height / imageSize.height)
        let fitWidth = imageSize.width * scale
        let fitHeight = imageSize.height * scale
        let originX = (width - fitWidth) / 2
        let originY = (height - fitHeight) / 2
        return CGRect(x: originX, y: originY, width: fitWidth, height: fitHeight)
    }
}
