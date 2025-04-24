//
//  MainView.swift
//  AezakmiEditPhoto
//
//  Created by Александр Воробей on 22.04.2025.
//

import SwiftUI
import Photos

struct MainView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel: MainViewModel
    
    init(viewModel: MainViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Главный экран")
                    .font(.largeTitle.bold())
                
                if let image = viewModel.selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.9)
                        .cornerRadius(12)
                        .padding(.vertical)
                }
                
                HStack {
                    Button("Выбрать фото") {
                        viewModel.checkPhotoLibraryPermission()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Сделать фото") {
                        viewModel.checkCameraPermission()
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                if let image = viewModel.selectedImage {
                    HStack() {
                        Button {
                            viewModel.showImageEditor = true
                        } label: {
                            Image(systemName: "pencil")
                                .font(.system(size: 24))
                        }
                        
                        Button {
                            viewModel.saveToPhotoLibrary(image)
                        } label: {
                            Image(systemName: "square.and.arrow.down")
                                .font(.system(size: 24))
                        }
                        
                        Button {
                            viewModel.isShowingShareSheet = true
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 24))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.bordered)
                    .padding(.top, 16)
                }
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        appState.signOut()
                    } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showImagePicker) {
                ImagePicker(sourceType: viewModel.imagePickerSource) { image in
                    viewModel.selectedImage = image
                }
            }
            .navigationDestination(isPresented: $viewModel.showImageEditor) {
                if let image = viewModel.selectedImage {
                    ImageEditorView(image: image) { editedImage in
                        viewModel.selectedImage = editedImage
                    }
                }
            }
            .alert("Ошибка", isPresented: $viewModel.showPermissionAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.alertMessage)
            }
            .alert("Сохранено", isPresented: $viewModel.showingSaveSuccess) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Изображение сохранено в фотогалерею")
            }
            .sheet(isPresented: $viewModel.isShowingShareSheet) {
                if let image = viewModel.selectedImage {
                    ShareSheet(activityItems: [image])
                }
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    MainView(viewModel: MainViewModel())
        .environmentObject(AppState())
}
