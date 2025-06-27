//
//  ScannerViewController.swift
//  itv-new
//
//  Created Admin NBU on 14/02/22.

import UIKit
import AVFoundation
import Haptica
import CryptoKit

protocol ScannerViewControllerDelegate: NSObject {
    func didFoundCode(code: String)
}

class ScannerViewController: UIViewController, ViewSpecificController, AlertViewController, AVCaptureMetadataOutputObjectsDelegate {
    // MARK: - Root View
    typealias RootView = ScannerView
    
    // MARK: - Services
    internal var coordinator: ProfileCoordinator?
    weak var delegate: ScannerViewControllerDelegate?
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    // MARK: - Actions
    @IBAction func flashLightAction(_ sender: UIButton) {
        toggleFlash()
    }
    
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSession()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addMaskLayerToVideoPreviewLayer(rect: view().imageView.frame)
        view().bringSubviewToFront(view().label)
        view().bringSubviewToFront(view().imageView)
        view().bringSubviewToFront(view().flashLightButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            DispatchQueue.global(qos: .background).async {
                self.captureSession.startRunning()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            DispatchQueue.global(qos: .background).async {
                self.captureSession.stopRunning()
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.previewLayer.frame = CGRect(origin: .zero, size: size)
            if let connection = self?.previewLayer.connection, connection.isVideoOrientationSupported {
                let deviceOrientation = UIDevice.current.orientation
                if let videoOrientation = AVCaptureVideoOrientation(rawValue: deviceOrientation.rawValue) {
                    connection.videoOrientation = videoOrientation
                }
            }
        }, completion: nil)
        setupSession()
    }
    
}

// MARK: - Other funcs
extension ScannerViewController {
    
    private func setupSession() {
        if let sublayers = self.view().layer.sublayers {
            for sublayer in sublayers {
                if sublayer.isKind(of: AVCaptureVideoPreviewLayer.self) {
                    sublayer.removeFromSuperlayer()
                }
            }
        }
        
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = UIScreen.main.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view().layer.addSublayer(previewLayer)
        
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }
    
    func addMaskLayerToVideoPreviewLayer(rect: CGRect) {
        let space = 1.5
        let rect = CGRect(x: rect.minX + space, y: rect.minY + space, width: rect.width - 2*space, height: rect.height - 2*space)
        view().backgroundColor = .appColor(.white).withAlphaComponent(0.5)
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = view.bounds
        maskLayer.fillColor = UIColor(white: 0.0, alpha: 0.2).cgColor
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 5.0)
        path.append(UIBezierPath(rect: view.bounds))
        maskLayer.path = path.cgPath
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        
        view.layer.insertSublayer(maskLayer, above: previewLayer)
    }
    
    func toggleFlash() {
        view().flashLightButton.showAnimation()
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        guard device.hasTorch else { return }

        do {
            try device.lockForConfiguration()

            if (device.torchMode == AVCaptureDevice.TorchMode.on) {
                view().flashLightButton.backgroundColor = .appColor(.white).withAlphaComponent(0.1)
                device.torchMode = AVCaptureDevice.TorchMode.off
            } else {
                do {
                    view().flashLightButton.backgroundColor = .appColor(.white)
                    try device.setTorchModeOn(level: 1.0)
                } catch {
                    print(error)
                }
            }

            device.unlockForConfiguration()
        } catch {
            print(error)
        }
    }
    
    private func failed() {
        showWarningAlert(message: "scanningNotSupported".localized)
        captureSession = nil
    }
    
    internal func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        DispatchQueue.global(qos: .background).async {
            self.captureSession.stopRunning()
        }
        
        guard let metadataObject = metadataObjects.first else { return }
        guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
        guard let stringValue = readableObject.stringValue else { return }
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        found(code: stringValue)
    }
    
    private func found(code: String) {
        Haptic.notification(.success).generate()
        delegate?.didFoundCode(code: code)
        navigationController?.popViewController(animated: true)
    }
}
