//
//  Camera.swift
//  Onormes
//
//  Created by gonzalo on 17/11/2022.
//

import Foundation
import AVFoundation
import SwiftUI

class CameraService {
    
    var session: AVCaptureSession?
    var delegate: AVCapturePhotoCaptureDelegate?
    
    let output = AVCapturePhotoOutput()
    let previewLayer = AVCaptureVideoPreviewLayer()
    
    func start(delegate: AVCapturePhotoCaptureDelegate, completion: @escaping (Error?) -> ()) {
        print("called start")
        self.delegate = delegate
        checkPermission(completion: completion)
    }
    
    private func checkPermission(completion: @escaping (Error?) -> ()) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self]
                granted in
                guard granted else { return }
                DispatchQueue.main.async {
                    self?.setupCamera(completion: completion)
                }
            }
        
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            setupCamera(completion: completion)
        @unknown default:
            break
        }
    }
    
    private func setupCamera(completion: @escaping (Error?) -> ()) {
        let session = AVCaptureSession()
        if let device = AVCaptureDevice.default(for: .video) {
            
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) {
                    session.addInput(input)
                }
                if session.canAddOutput(output) {
                    session.addOutput(output)
                }
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session
                
                session.startRunning()
                self.session = session
                
            } catch {
                completion(error)
            }

        }
    }
    
    func capturePhoto(with settings: AVCapturePhotoSettings = AVCapturePhotoSettings()) {
        output.capturePhoto(with: settings, delegate: delegate!)
    }
    
    deinit {
        print("object destroyed")
    }

}

struct CameraView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController
    
    let cameraService: CameraService
    let didFinishProcessingPhoto: (Result<AVCapturePhoto, Error>) -> ()
    
    func makeUIViewController(context: Context) -> UIViewController {
        //print(context)
        print("call camera view")
        if context.coordinator == nil {
            print("True")
        } else {
            print("not nil")
        }
        cameraService.start(delegate: context.coordinator, completion: {
            error in
            if let error = error {
                didFinishProcessingPhoto(.failure(error))
                return
            }
        })
        
        let viewController = UIViewController()
        viewController.view.backgroundColor = .black
        viewController.view.layer.addSublayer(cameraService.previewLayer)
        cameraService.previewLayer.frame = viewController.view.bounds
        
        return viewController
    }
    
    func makeCoordinator() -> Coordinator {
        print("make coordinator")
        return Coordinator(self, didFinishProcessingPhoto: didFinishProcessingPhoto)
    }

    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        //print("update view")
        
    }
    
    class Coordinator: NSObject, AVCapturePhotoCaptureDelegate {
        let parent: CameraView
        private var didFinishProcessingPhoto: (Result<AVCapturePhoto, Error>) -> ()
        
        init(_ parent: CameraView, didFinishProcessingPhoto: @escaping (Result<AVCapturePhoto, Error>) -> ()) {
            self.parent = parent
            self.didFinishProcessingPhoto = didFinishProcessingPhoto
        }
        
        func photoOutput(_ : AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            if let error = error {
                didFinishProcessingPhoto(.failure(error))
                return
            }
            didFinishProcessingPhoto(.success(photo))
        }

    }
    
    

}

struct CustomCameraView: View {
    
    @State var cameraService = CameraService()
    @Binding var capturedImage: UIImage?
    
    @Environment (\.presentationMode) private var presentationMode
    
    var body: some View {
        ZStack {
            
            
            CameraView(cameraService: cameraService) { result in
                switch result {
                case .success(let photo):
                    if let data = photo.fileDataRepresentation() {
                        capturedImage = UIImage(data: data)
                        print("leaves")
                        //presentationMode.wrappedValue.dismiss()
                    } else {
                        print("Error no image data found")
                    }
                case .failure(let err):
                    print(err.localizedDescription)
                }
            }
            
            VStack {
                Spacer().frame(height: 20)
                HStack {
                    Spacer().frame(width: 10)
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image("LeftArrow")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40)
                    }
                    Spacer()
                }
                Spacer()
            }
            
            VStack {
                Spacer()
                Button(action: {
                    print("capture photo")
                    cameraService.capturePhoto()
                }, label: {
                    Image(systemName: "circle").font(.system(size: 72)).foregroundColor(.white)
                })
                .padding(.bottom)
            }

        }
    }

}

struct CameraPage: View {
    var coordinator: UJCoordinator
    
    @State private var capturedImage: UIImage? = nil
    
    
    @Environment (\.presentationMode) private var presentationMode

    var body: some View {
        ZStack {
            if capturedImage == nil {
                CustomCameraView(capturedImage: $capturedImage)
            } else {
                ZStack {
                    
                    // TODO: issue with resizing here, trying to get like on snapchat
                    Image(uiImage: capturedImage!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                    
                    VStack {
                        Spacer().frame(height: 20)
                        HStack {
                            Spacer().frame(width: 10)
                            Button {
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                Image("LeftArrow")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40)
                            }
                            Spacer()
                        }
                        Spacer()
                    }

                    VStack {
                        Spacer()
                        HStack {
                            Button("Valider") {
                                let imagePath = saveImage(image: capturedImage!)
                                self.coordinator.stageDelegate!.addPicture(path: imagePath)
                                presentationMode.wrappedValue.dismiss()
                            }.modifier(PrimaryButtonStyle1(size: 100))

                            Spacer().frame(width: 80)

                            Button("Reprendre") {
                                capturedImage = nil
                            }.modifier(SecondaryButtonStyle1(size: 100))
                        }
                        Spacer().frame(height: 50)
                    }
                }
            }
        }
    }
}
