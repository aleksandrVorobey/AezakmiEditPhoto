//
//  MainViewModel.swift
//  AezakmiEditPhoto
//
//  Created by Александр Воробей on 24.04.2025.
//


import SwiftUI
import Photos

class MainViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var showImagePicker = false
    @Published var imagePickerSource: ImagePicker.SourceType = .photoLibrary
    @Published var showPermissionAlert = false
    @Published var alertMessage = ""
    @Published var showImageEditor = false
    @Published var showingSaveSuccess = false
    @Published var isShowingShareSheet = false
    
    func saveToPhotoLibrary(_ image: UIImage) {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            switch status {
            case .authorized, .limited:
                PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                } completionHandler: { success, error in
                    DispatchQueue.main.async {
                        if success {
                            self?.showingSaveSuccess = true
                        } else {
                            self?.alertMessage = error?.localizedDescription ?? "Ошибка при сохранении"
                            self?.showPermissionAlert = true
                        }
                    }
                }
            default:
                DispatchQueue.main.async {
                    self?.alertMessage = "Доступ к фото запрещён. Вы можете изменить это в настройках."
                    self?.showPermissionAlert = true
                }
            }
        }
    }
    
    func checkCameraPermission() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.imagePickerSource = .camera
                        self?.showImagePicker = true
                    } else {
                        self?.alertMessage = "Доступ к камере запрещён. Вы можете изменить это в настройках."
                        self?.showPermissionAlert = true
                    }
                }
            }
        } else {
            alertMessage = "Камера недоступна на этом устройстве"
            showPermissionAlert = true
        }
    }
    
    func checkPhotoLibraryPermission() {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .limited:
                    self?.imagePickerSource = .photoLibrary
                    self?.showImagePicker = true
                default:
                    self?.alertMessage = "Доступ к фото запрещён. Вы можете изменить это в настройках."
                    self?.showPermissionAlert = true
                }
            }
        }
    }
}