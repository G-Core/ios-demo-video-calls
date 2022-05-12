//
//  GCVideoCallCollectionCell.swift
//  GCoreVideoCalls
//
//  Created by Evgenij Polubin on 24.03.2022.
//

import UIKit
import GCoreVideoCallsSDK

final class GCVideoCallCollectionCell: UICollectionViewCell {
    
    var isSpeak: Bool = false {
        didSet {
            let color: UIColor = .activePeerColor ?? .white
            isSpeak == true ? (layer.borderColor = color.cgColor) : (layer.borderColor = UIColor.clear.cgColor)
        }
    }
    
    var hasMicrophone: Bool = false {
        didSet {
            hasMicrophone == true ? (microphoneImageView.image = .microphone) : (microphoneImageView.image = .microphoneMute)
        }
    }
    
    var hasCamera: Bool = false {
        didSet {
            if hasCamera {
                disabledCameraUIImage.isHidden = true
                cameraImageView.image = .camera
            } else {
                disabledCameraUIImage.isHidden = false
                cameraImageView.image = .cameraMute
            }
        }
    }
    
    var peerID: String?
    var rtcView: RTCEAGLVideoView?
    
    private let peerNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        
        return label
    }()
    
    private let disabledCameraUIImage = UIImageView(image: .peerImage)
    private let microphoneImageView = UIImageView(image: .microphone)
    private let cameraImageView = UIImageView(image: .camera)
    
    func setupCellWith(remoteItem: RemoteVideoItem) {
        peerID = remoteItem.userData.id
        rtcView = remoteItem.videoView
        peerNameLabel.text = remoteItem.userData.name
        hasCamera =  remoteItem.hasCamera
        hasMicrophone = remoteItem.hasMicrophone
        isSpeak = remoteItem.isSpeak
        
        if let rtcView = rtcView {
            rtcView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(rtcView)
            rtcView.delegate = self
            rtcView.contentMode = .scaleAspectFit
        }
        
        layer.cornerRadius = 15
        layer.borderWidth = 1
        backgroundColor = .blueMagenta
        clipsToBounds = true
        
        disabledCameraUIImage.contentMode = .scaleAspectFit
        disabledCameraUIImage.backgroundColor = .blueMagenta
        
        initConstraints()
    }
    
}

extension GCVideoCallCollectionCell: RTCVideoViewDelegate {
    func videoView(_ videoView: RTCVideoRenderer, didChangeVideoSize size: CGSize) {
        setNeedsLayout()
        UIView.animate(withDuration: 0.25) {
            self.layoutIfNeeded()
        }
    }
}

// MARK: - Layout

extension GCVideoCallCollectionCell {
    private func initConstraints() {
        microphoneImageView.translatesAutoresizingMaskIntoConstraints = false
        cameraImageView.translatesAutoresizingMaskIntoConstraints = false
        peerNameLabel.translatesAutoresizingMaskIntoConstraints = false
        disabledCameraUIImage.translatesAutoresizingMaskIntoConstraints = false
        
        
        addSubview(disabledCameraUIImage)
        addSubview(microphoneImageView)
        addSubview(cameraImageView)
        addSubview(peerNameLabel)
        
        NSLayoutConstraint.activate([
            microphoneImageView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            microphoneImageView.rightAnchor.constraint(equalTo: rightAnchor, constant: -5),
            microphoneImageView.heightAnchor.constraint(equalToConstant: 25),
            microphoneImageView.widthAnchor.constraint(equalToConstant: 25),
            
            cameraImageView.centerYAnchor.constraint(equalTo: microphoneImageView.centerYAnchor),
            cameraImageView.rightAnchor.constraint(equalTo: microphoneImageView.leftAnchor, constant: -5),
            cameraImageView.heightAnchor.constraint(equalToConstant: 25),
            cameraImageView.widthAnchor.constraint(equalToConstant: 25),
            
            peerNameLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 5),
            peerNameLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -5),
            peerNameLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            peerNameLabel.heightAnchor.constraint(equalToConstant: peerNameLabel.font.lineHeight + 4),
            
            disabledCameraUIImage.leftAnchor.constraint(equalTo: leftAnchor),
            disabledCameraUIImage.rightAnchor.constraint(equalTo: rightAnchor),
            disabledCameraUIImage.topAnchor.constraint(equalTo: topAnchor),
            disabledCameraUIImage.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        if let rtcView = rtcView {
            NSLayoutConstraint.activate([
                rtcView.leftAnchor.constraint(equalTo: leftAnchor),
                rtcView.rightAnchor.constraint(equalTo: rightAnchor),
                rtcView.topAnchor.constraint(equalTo: topAnchor),
                rtcView.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
        }
    }
}
