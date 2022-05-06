//
//  SessionCaptureWrapper.swift
//  GCoreVideoCalls
//
//  Created by Evgenij Polubin on 29.03.2022.
//

import AVFoundation

struct SessionCaptureWrapper {
    let session = AVCaptureSession()
    
    let frontCameraInput: AVCaptureDeviceInput? = {
        let camera = SessionCaptureWrapper.cameraWithPosition(position: .front)
        if let camera = camera {
            return try? AVCaptureDeviceInput(device: camera)
        }
        return nil
    }()
    
    let backCameraInput: AVCaptureDeviceInput? = {
        let camera = SessionCaptureWrapper.cameraWithPosition(position: .back)
        if let camera = camera {
            return try? AVCaptureDeviceInput(device: camera)
        }
        return nil
    }()
    
    let microphoneInput: AVCaptureDeviceInput? = {
        if let micro = AVCaptureDevice.default(for: .audio) {
            return try? AVCaptureDeviceInput(device: micro)
        }
        return nil
    }()
    
    var attachedCamera: AVCaptureDeviceInput?
    
    var hasCamera: Bool {
        attachedCamera != nil
    }
    
    var hasMicrophone: Bool {
        microphoneInput != nil
    }
    
    var canSwitchCamera: Bool {
        frontCameraInput != nil && backCameraInput != nil
    }
    
    private mutating func configureSession() {
        if let frontCameraInput = frontCameraInput, session.canAddInput(frontCameraInput) {
            attachedCamera = frontCameraInput
        } else if let backCameraInput = backCameraInput, session.canAddInput(backCameraInput) {
            attachedCamera = backCameraInput
        }
        
        session.startRunning()
    }
    
    private init() { }
    
    mutating func switchCameraPosition(){
        
        guard let attachedCamera = attachedCamera,
              let frontCameraInput = frontCameraInput,
              let backCameraInput = backCameraInput
        else { return }
        
        session.beginConfiguration()
        
        if attachedCamera == frontCameraInput {
            session.removeInput(frontCameraInput)
            session.addInput(backCameraInput)
            self.attachedCamera = backCameraInput
            
        } else {
            session.removeInput(backCameraInput)
            session.addInput(frontCameraInput)
            self.attachedCamera = frontCameraInput
        }
        
        session.commitConfiguration()
    }
    
    mutating func toggleCamera() -> Bool {
        guard let attachedCamera = attachedCamera else { return false }
        
        if session.inputs.count == 1 {
            session.removeInput(attachedCamera)
            return true
        } else if session.canAddInput(attachedCamera) {
            session.addInput(attachedCamera)
            return true
        } else {
            return false
        }
    }
    
    mutating func toggleMicrophone() -> Bool {
        guard let microphoneInput = microphoneInput else { return false }
        
        if let input = session.inputs.first(where: { $0 == microphoneInput } ) {
            session.removeInput(input)
            return true
        } else if session.canAddInput(microphoneInput) {
            session.addInput(microphoneInput)
            return true
        } else {
            return false
        }
    }
    
    static var configuredWrapper: SessionCaptureWrapper {
        var wrapper = SessionCaptureWrapper()
        wrapper.configureSession()
        return wrapper
    }
    
    static func cameraWithPosition(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                                mediaType: AVMediaType.video,
                                                                position: .unspecified)
        
        for device in discoverySession.devices {
            if device.position == position {
                return device
            }
        }
        
        return nil
    }
}
