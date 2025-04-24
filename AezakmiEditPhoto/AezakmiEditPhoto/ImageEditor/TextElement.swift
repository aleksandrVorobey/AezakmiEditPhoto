//
//  TextElement.swift
//  AezakmiEditPhoto
//
//  Created by Александр Воробей on 24.04.2025.
//

import SwiftUI

struct TextElement: Identifiable {
    let id = UUID()
    var text: String
    var position: CGPoint
    var fontSize: CGFloat
    var color: Color
    var fontStyle: FontStyle
    
    enum FontStyle {
        case system
        case rounded
        case serif
        
        func font(size: CGFloat) -> Font {
            switch self {
            case .system:
                return .system(size: size)
            case .rounded:
                return .system(size: size, design: .rounded)
            case .serif:
                return .system(size: size, design: .serif)
            }
        }
    }
    
    var font: Font {
        fontStyle.font(size: fontSize)
    }
    
    static func defaultElement(at position: CGPoint) -> TextElement {
        TextElement(
            text: "",
            position: position,
            fontSize: 24,
            color: .black,
            fontStyle: .system
        )
    }
}
