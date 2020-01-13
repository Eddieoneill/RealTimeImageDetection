//
//  ViewController.swift
//  RealTimeImageDetection
//
//  Created by Edward O'Neill on 1/13/20.
//  Copyright © 2020 Edward O'Neill. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    let information = UILabel.init()
    
    override  func viewDidLoad() {
        super.viewDidLoad()
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        
        captureSession.addInput(input)
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutupt = AVCaptureVideoDataOutput()
        dataOutupt.setSampleBufferDelegate(self, queue: DispatchQueue (label: "videoQueue"))
        captureSession.addOutput(dataOutupt)
        
        information.frame = CGRect(x: 0, y: 500, width: view.frame.width, height: 100)
        information.layer.cornerRadius = 8
        information.backgroundColor = .white
        information.alpha = 0.5
        information.textColor = .black
        information.numberOfLines = 0
        view.addSubview(information)
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        //print("camera was able to capture a frame:", Date())
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else { return }
        let request = VNCoreMLRequest(model: model) { (finishedRequest, error) in
            
            guard let results = finishedRequest.results as? [VNClassificationObservation] else { return }
            guard let firstObservation = results.first else { return }
            
            DispatchQueue.main.async {
                self.information.text = "\(firstObservation.identifier) \(firstObservation.confidence * 100)"
            }
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }

}

