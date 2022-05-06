//
//  GCPreviewViewController.swift
//  GCoreVideoCalls
//
//  Created by Evgenij Polubin on 28.03.2022.
//

import UIKit
import AVFoundation

final class GCPreviewViewController: GCBaseViewController {
    private var sessionWrapper = SessionCaptureWrapper.configuredWrapper
    
    private let model = GCModel.shared
    
    private let nameTextField: GCoreTextField = {
        let field = GCoreTextField(placeholder: "Type your name")
        field.layer.borderWidth = 0
        field.rightViewMode = .never
        return field
    }()
    
    private let cameraLabel = GCSwitchsLabel()
    private let microphoneLabel = GCSwitchsLabel()
    
    private lazy var previewView = GCCameraPreview(session: sessionWrapper.session)
    
    private lazy var cameraSwitch: GCSwitch = {
        let cameraSwitch = GCSwitch(onImage: .camera, offImage: .cameraMute)
        cameraSwitch.isOn = model.userSettings.videoIsOn
        cameraSwitch.addTarget(self, action: #selector(toggleCameraSwitch), for: .valueChanged)
        return cameraSwitch
    }()
    
    private lazy var microphoneSwitch: GCSwitch = {
        let microphoneSwitch = GCSwitch(onImage: .microphone, offImage: .microphoneMute)
        microphoneSwitch.isOn = model.userSettings.audioIsOn
        microphoneSwitch.addTarget(self, action: #selector(toggleMicrophoneSwitch), for: .valueChanged)
        return microphoneSwitch
    }()
    
    private let cameraPositionButton: GCCameraPositionButton = {
        let button = GCCameraPositionButton()
        button.addTarget(self, action: #selector(toggleCameraPosition), for: .touchUpInside)
        return button
    }()
    
    private let launchButton: GCoreButton = {
        let button = GCoreButton(font: .montserratMedium(size: 14), image: nil)
        button.setTitle("Connect", for: .normal)
        button.addTarget(self, action: #selector(tapLaunchButton), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSwitches()
        initConstraints()
    }
    
    
    private func setupSwitches() {
        if !sessionWrapper.hasCamera {
            cameraLabel.text = "Camera is unabled"
            cameraSwitch.isUserInteractionEnabled = false
            cameraSwitch.alpha = 0.6
        }
        
        if !sessionWrapper.hasMicrophone {
            microphoneLabel.text = "Microphone is unabled"
            microphoneSwitch.isUserInteractionEnabled = false
            microphoneSwitch.alpha = 0.6
        }
    }
    
    @objc private func toggleCameraSwitch() {
        if sessionWrapper.toggleCamera() {
            model.userSettings.videoIsOn = cameraSwitch.isOn
            previewView.toggleBlocker()
            
            if cameraSwitch.isOn {
                cameraLabel.text = "On"
                cameraPositionButton.isUserInteractionEnabled = true
                cameraPositionButton.alpha = 1
                
            } else {
                cameraLabel.text = "Off"
                cameraPositionButton.isUserInteractionEnabled = false
                cameraPositionButton.alpha = 0.6
            }
        }
    }
    
    @objc private func toggleMicrophoneSwitch() {
        if sessionWrapper.toggleMicrophone() {
            model.userSettings.audioIsOn = microphoneSwitch.isOn
            microphoneSwitch.isOn ? (microphoneLabel.text = "On") : (microphoneLabel.text = "Off")
        }
    }
    
    @objc private func toggleCameraPosition() {
        if sessionWrapper.canSwitchCamera {
            sessionWrapper.switchCameraPosition()
            model.userSettings.cameraPosition = sessionWrapper.attachedCamera?.device.position
        }
    }
    
    @objc private func tapLaunchButton() {
        let closure = { [weak self] in
            self?.navigationController?.pushViewController( GCVideoCallViewController(), animated: true)
        }
        
        model.userName = nameTextField.text ?? ""
        
        guard !model.userName.isEmpty else {
            let alert = AlertFabric.newAlert(type: .emptyUserName) { alert in closure() }
            present(alert, animated: true, completion: nil)
            return
        }
        
        closure()
    }
}

//MARK: - Layout
extension GCPreviewViewController {
    private func initConstraints() {
        view.addSubview(previewView)
        view.addSubview(nameTextField)
        view.addSubview(cameraLabel)
        view.addSubview(microphoneLabel)
        view.addSubview(cameraSwitch)
        view.addSubview(microphoneSwitch)
        view.addSubview(cameraPositionButton)
        view.addSubview(launchButton)
        
        NSLayoutConstraint.activate([
            previewView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 10),
            previewView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor, constant: 20),
            previewView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor, constant: -20),
            
            nameTextField.topAnchor.constraint(equalTo: previewView.bottomAnchor, constant: 20),
            nameTextField.leftAnchor.constraint(equalTo: previewView.leftAnchor),
            nameTextField.rightAnchor.constraint(equalTo: previewView.rightAnchor),
            
            cameraSwitch.leftAnchor.constraint(equalTo: nameTextField.leftAnchor),
            cameraSwitch.widthAnchor.constraint(equalToConstant: cameraSwitch.intrinsicContentSize.width),
            cameraSwitch.centerYAnchor.constraint(equalTo: cameraLabel.centerYAnchor),
            
            cameraLabel.leftAnchor.constraint(equalTo: cameraSwitch.rightAnchor, constant: 20),
            cameraLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 10),
            cameraLabel.heightAnchor.constraint(equalTo: cameraSwitch.heightAnchor, multiplier: 1.25),
            cameraLabel.rightAnchor.constraint(equalTo: previewView.rightAnchor),
            
            microphoneSwitch.widthAnchor.constraint(equalToConstant: microphoneSwitch.intrinsicContentSize.width),
            microphoneSwitch.leftAnchor.constraint(equalTo: nameTextField.leftAnchor),
            microphoneSwitch.centerYAnchor.constraint(equalTo: microphoneLabel.centerYAnchor),
            
            microphoneLabel.leftAnchor.constraint(equalTo: microphoneSwitch.rightAnchor, constant: 20),
            microphoneLabel.topAnchor.constraint(equalTo: cameraLabel.bottomAnchor, constant: 10),
            microphoneLabel.heightAnchor.constraint(equalTo: microphoneSwitch.heightAnchor, multiplier: 1.25),
            microphoneLabel.rightAnchor.constraint(equalTo: previewView.rightAnchor),
            
            cameraPositionButton.topAnchor.constraint(equalTo: microphoneLabel.bottomAnchor, constant: 10),
            cameraPositionButton.leftAnchor.constraint(equalTo: microphoneSwitch.leftAnchor),
            cameraPositionButton.widthAnchor.constraint(equalToConstant: microphoneSwitch.intrinsicContentSize.width + 1.25),
            cameraPositionButton.heightAnchor.constraint(equalToConstant: microphoneSwitch.intrinsicContentSize.height * 1.25),
            
            launchButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -10),
            launchButton.leftAnchor.constraint(equalTo: previewView.leftAnchor),
            launchButton.rightAnchor.constraint(equalTo: previewView.rightAnchor),
            launchButton.heightAnchor.constraint(equalToConstant: launchButton.intrinsicContentSize.height + 10),
        ])
    }
    
    override func viewDidLayoutSubviews() {
        previewView.heightAnchor.constraint(equalToConstant: previewView.bounds.width).isActive = true
    }
}
