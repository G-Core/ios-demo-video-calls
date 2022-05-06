//
//  GCVideoCallTabBar.swift
//  GCoreVideoCalls
//
//  Created by Evgenij Polubin on 31.03.2022.
//

import UIKit

protocol GCVideoCallButtonsStackViewDelegate: AnyObject {
    func toggleMicrophone()
    func toggleCamera()
    func toggleCameraPosition()
    func tapUnavailableButton(_ button: GCVideoCallButton.ButtonType)
    func endCall()
    func copyRoomURL()
    func toggleModeratorModeView()
}

final class GCVideoCallButtonsStackView: UIStackView {
    private let toggleMicrophoneButton = GCVideoCallButton(type: .microphone)
    private let toggleCameraButton = GCVideoCallButton(type: .camera)
    private let toggleCameraPositionButton = GCVideoCallButton(type: .cameraPosition)
    private let sharedButton = GCVideoCallButton(type: .shared)
    private let endCallButton = GCVideoCallButton(type: .endCall)
    private let moderatorButton = GCVideoCallButton(type: .moderator)
    
    var moderatorButtonIsHidden: Bool {
        get { moderatorButton.isHidden }
        set { moderatorButton.isHidden = newValue }
    }
    
    weak var delegate: GCVideoCallButtonsStackViewDelegate?
    
    init(withMicrophone: Bool, withVideo: Bool) {
        super.init(frame: .zero)
        
        let buttons = [moderatorButton, toggleMicrophoneButton, toggleCameraButton, toggleCameraPositionButton, sharedButton, endCallButton]
        
        for button in buttons {
            button.addTarget(self, action: #selector(tapButton(_:)), for: .touchUpInside)
            addArrangedSubview(button)
        }
        
        changeButtonState(button: .microphone, to: withMicrophone ? (.active) : (.deactive))
        changeButtonState(button: .camera, to: withVideo ? (.active) : (.deactive))
        
        axis = .horizontal
        translatesAutoresizingMaskIntoConstraints = false
        distribution = .fillEqually
        spacing = 10
        backgroundColor = .clear
        moderatorButton.isHidden = true
        
        initConstaintsForButtons(buttons)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func tapButton(_ button: GCVideoCallButton) {
        let newState: GCVideoCallButton.ButtonState
        newState = button.gcState == .active ? (.deactive) : (.active)
        
        switch button.type {
        case _ where button.gcState == .unavailable:
            delegate?.tapUnavailableButton(button.type)
            
        case .microphone:
            changeButtonState(button: .microphone, to: newState)
            delegate?.toggleMicrophone()
            
        case .camera:
            changeButtonState(button: .camera, to: newState)
            delegate?.toggleCamera()
            
        case .cameraPosition:
            delegate?.toggleCameraPosition()
            
        case .endCall:
            delegate?.endCall()
            
        case .shared:
            delegate?.copyRoomURL()
            
        case .moderator:
            delegate?.toggleModeratorModeView()
        }
    }
    
    func changeButtonState(button type: GCVideoCallButton.ButtonType, to state: GCVideoCallButton.ButtonState) {
        
        switch state {
        case .unavailable where type == .camera:
            toggleCameraButton.gcState = state
            toggleCameraButton.backgroundColor = .verySoftRed
            toggleCameraButton.setImage(.cameraMute, for: .normal)
            toggleCameraPositionButton.backgroundColor = .verySoftRed
            toggleCameraPositionButton.isUserInteractionEnabled = false
            
        case .unavailable where type == .microphone:
            toggleMicrophoneButton.gcState = state
            toggleMicrophoneButton.backgroundColor = .verySoftRed
            toggleMicrophoneButton.setImage(.microphoneMute, for: .normal)
            
        case .active where type == .camera:
            toggleCameraButton.gcState = state
            toggleCameraButton.backgroundColor = .gcGreen
            toggleCameraButton.setImage(.camera, for: .normal)
            toggleCameraPositionButton.backgroundColor = .gcGreen
            toggleCameraPositionButton.isUserInteractionEnabled = true
            
        case .active where type == .microphone:
            toggleMicrophoneButton.gcState = state
            toggleMicrophoneButton.backgroundColor = .gcGreen
            toggleMicrophoneButton.setImage(.microphone, for: .normal)
            
        case .deactive where type == .camera:
            toggleCameraButton.gcState = state
            toggleCameraButton.backgroundColor = .blueMagentaDark
            toggleCameraButton.setImage(.cameraMute, for: .normal)
            toggleCameraPositionButton.backgroundColor = .blueMagentaDark
            toggleCameraPositionButton.isUserInteractionEnabled = false
            
        case .deactive where type == .microphone:
            toggleMicrophoneButton.gcState = state
            toggleMicrophoneButton.backgroundColor = .blueMagentaDark
            toggleMicrophoneButton.setImage(.microphoneMute, for: .normal)
            
        default:
            break
        }
    }
}

//MARK: - Layout
extension GCVideoCallButtonsStackView {
    private func initConstaintsForButtons(_ buttons: [UIButton]) {
        for button in buttons {
            var constrainst = [
                button.widthAnchor.constraint(lessThanOrEqualToConstant: 60),
                button.heightAnchor.constraint(lessThanOrEqualToConstant: 60)
            ]
            
            if let imageView = button.imageView {
                imageView.contentMode = .scaleAspectFit
                imageView.translatesAutoresizingMaskIntoConstraints = false
                constrainst += [
                    imageView.widthAnchor.constraint(equalToConstant: 20),
                    imageView.heightAnchor.constraint(equalToConstant: 20),
                    imageView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
                    imageView.centerYAnchor.constraint(equalTo: button.centerYAnchor)
                ]
            }
            
            NSLayoutConstraint.activate(constrainst)
        }
    }
}
