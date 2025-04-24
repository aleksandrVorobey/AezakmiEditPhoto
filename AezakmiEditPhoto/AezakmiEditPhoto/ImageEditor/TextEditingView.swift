//
//  TextEditingView.swift
//  AezakmiEditPhoto
//
//  Created by Александр Воробей on 24.04.2025.
//

import SwiftUI

struct TextEditingView: View {
    @ObservedObject var viewModel: ImageEditorViewModel
    @State private var textInput: String = ""
    @State private var textColor: Color = .black
    @State private var fontSize: CGFloat = 24
    @State private var panelHeight: CGFloat = 0
    @State private var selectedFontStyle: TextElement.FontStyle = .system
    @State private var panelOffset: CGSize = .zero
    @State private var lastPanelOffset: CGSize = .zero
    @State private var keyboardHeight: CGFloat = 0
    @State private var screenHeight: CGFloat = UIScreen.main.bounds.height
    @State private var isKeyboardVisible: Bool = false
    
    private let fonts: [(String, TextElement.FontStyle)] = [
        ("System", .system),
        ("Rounded", .rounded),
        ("Serif", .serif)
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.gray.opacity(0.5))
                .frame(width: 40, height: 5)
                .padding(.top, 8)
            
            TextField("Введите текст", text: $textInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.system(size: 16))
                .onChange(of: textInput) { _, newValue in
                    if viewModel.selectedTextIndex == nil {
                        viewModel.addNewTextAtCenter(panelHeight: panelHeight, containerSize: UIScreen.main.bounds.size)
                    }
                    viewModel.updateSelectedText(newValue)
                }
            
            Picker("Шрифт", selection: $selectedFontStyle) {
                ForEach(fonts, id: \.1) { font in
                    Text(font.0)
                        .tag(font.1)
                        .font(.system(size: 16))
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedFontStyle) { _, style in
                viewModel.updateTextFont(style)
            }
            
            HStack {
                ColorPicker("Цвет", selection: $textColor)
                    .onChange(of: textColor) { _, newValue in
                        viewModel.updateTextColor(newValue)
                    }
                
                Slider(value: $fontSize, in: 12...72, step: 1) {
                    Text("Размер: \(Int(fontSize))")
                        .font(.system(size: 14))
                }
                .onChange(of: fontSize) { _, newValue in
                    viewModel.updateTextSize(newValue)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground).opacity(0.9))
        .cornerRadius(15)
        .shadow(radius: 10)
        .offset(panelOffset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    guard !isKeyboardVisible else { return }
                    panelOffset = CGSize(
                        width: lastPanelOffset.width + value.translation.width,
                        height: lastPanelOffset.height + value.translation.height
                    )
                }
                .onEnded { value in
                    guard !isKeyboardVisible else { return }
                    lastPanelOffset = panelOffset
                }
        )
        .background(
            GeometryReader { geometry in
                Color.clear.onAppear {
                    panelHeight = geometry.size.height
                }
            }
        )
        .onAppear {
            if let index = viewModel.selectedTextIndex {
                let element = viewModel.textElements[index]
                textInput = element.text
                textColor = element.color
                fontSize = element.fontSize
                selectedFontStyle = element.fontStyle
            } else {
                textInput = ""
                textColor = .black
                fontSize = 24
                selectedFontStyle = .system
            }
            
            setupKeyboardNotifications()
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { notification in
            guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
                  let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
            else { return }
            
            isKeyboardVisible = true
            keyboardHeight = keyboardFrame.height
            
            withAnimation(.easeOut(duration: duration)) {
                panelOffset.height = screenHeight - keyboardHeight - panelHeight - 100
                lastPanelOffset = panelOffset
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { _ in
            isKeyboardVisible = false
            withAnimation(.easeOut(duration: 0.25)) {
                keyboardHeight = 0
                panelOffset = lastPanelOffset
            }
        }
    }
}
