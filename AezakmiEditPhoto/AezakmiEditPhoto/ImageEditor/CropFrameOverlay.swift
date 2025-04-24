//
//  CropFrameOverlay.swift
//  AezakmiEditPhoto
//
//  Created by Александр Воробей on 23.04.2025.
//

import SwiftUI

struct CropFrameOverlay: View {
    var frame: CGRect

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.opacity(0.5)
                    .mask {
                        Rectangle()
                            .overlay(
                                Rectangle()
                                    .frame(width: frame.width, height: frame.height)
                                    .blendMode(.destinationOut)
                                    .position(x: frame.midX, y: frame.midY)
                            )
                    }

                Rectangle()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: frame.width, height: frame.height)
                    .position(x: frame.midX, y: frame.midY)
            }
            .compositingGroup()
        }
        .allowsHitTesting(false)
    }
}


