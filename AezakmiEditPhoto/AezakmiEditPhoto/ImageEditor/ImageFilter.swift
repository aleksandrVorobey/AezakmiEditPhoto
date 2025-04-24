//
//  ImageFilter.swift
//  AezakmiEditPhoto
//
//  Created by Александр Воробей on 24.04.2025.
//

import CoreImage
import UIKit

enum ImageFilter: String, CaseIterable {
    case original = "Original"
    case noir = "Noir"
    case chrome = "Chrome"
    case instant = "Instant"
    
    func apply(to image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        let context = CIContext()
        let ciImage = CIImage(cgImage: cgImage)
        
        switch self {
        case .original:
            return image
        case .noir:
            return CIFilter(name: "CIPhotoEffectNoir")?.apply(to: ciImage, context: context)
        case .chrome:
            return CIFilter(name: "CIPhotoEffectChrome")?.apply(to: ciImage, context: context)
        case .instant:
            return CIFilter(name: "CIPhotoEffectInstant")?.apply(to: ciImage, context: context)
        }
    }
}

private extension CIFilter {
    func apply(to input: CIImage, context: CIContext) -> UIImage? {
        setValue(input, forKey: kCIInputImageKey)
        guard let outputImage = outputImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent)
        else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
