//
//  CameraView.swift
//  Sinaliza
//
//  Created by Ana Flávia Torres do Carmo on 27/06/25.
//


import SwiftUI
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    
    class Coordinator: NSObject, AVCapturePhotoCaptureDelegate {
        var parent: CameraView
        var session: AVCaptureSession?
        var output: AVCapturePhotoOutput?

        init(parent: CameraView) {
            self.parent = parent
        }

        func photoOutput(_ output: AVCapturePhotoOutput,
                         didFinishProcessingPhoto photo: AVCapturePhoto,
                         error: Error?) {
            if let data = photo.fileDataRepresentation(),
               let image = UIImage(data: data) {
                parent.onPhotoTaken(image)
            }
        }
    }

    var onPhotoTaken: (UIImage) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let session = AVCaptureSession()
        session.sessionPreset = .photo

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: .front),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input)
        else {
            return UIViewController()
        }

        session.addInput(input)

        let output = AVCapturePhotoOutput()
        guard session.canAddOutput(output) else { return UIViewController() }
        session.addOutput(output)

        context.coordinator.session = session
        context.coordinator.output = output

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill

        let cameraVC = UIViewController()
        previewLayer.frame = UIScreen.main.bounds
        cameraVC.view.layer.addSublayer(previewLayer)

        NotificationCenter.default.addObserver(forName: .takePhotoNotification, object: nil, queue: .main) { _ in
            let settings = AVCapturePhotoSettings()
            output.capturePhoto(with: settings, delegate: context.coordinator)
        }

        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }

        return cameraVC
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
