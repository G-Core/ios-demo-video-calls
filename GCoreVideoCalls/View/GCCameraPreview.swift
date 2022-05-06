//
//  GCCameraPreview.swift
//  GCoreVideoCalls
//
//  Created by Evgenij Polubin on 28.03.2022.
//

import UIKit
import AVFoundation

final class GCCameraPreview: UIView {
    private let videoBlockerImage: UIImageView = {
        let view = UIImageView(image: .gcBody)
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private let previewLayer = AVCaptureVideoPreviewLayer()
    
    private let gradient: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.type = .axial
        gradient.locations = [0.8, 1]
        gradient.colors = [
            UIColor(white: 0, alpha: 0).cgColor,
            UIColor.black.cgColor
        ]
        
        return gradient
    }()
    
    
    init(session: AVCaptureSession) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .blueMagenta
        addSubview(videoBlockerImage)
        layer.insertSublayer(gradient, at: 0)
        setupCameraPreviewLayer(session: session)
        layer.cornerRadius = 16
        clipsToBounds = true
        initConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        gradient.frame = bounds
        previewLayer.frame = bounds
    }
    
    private func setupCameraPreviewLayer(session: AVCaptureSession) {
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.session = session
        layer.insertSublayer(previewLayer, at: 0)
    }
    
    private func initConstraints() {
        NSLayoutConstraint.activate([
            videoBlockerImage.leftAnchor.constraint(equalTo: leftAnchor),
            videoBlockerImage.rightAnchor.constraint(equalTo: rightAnchor),
            videoBlockerImage.topAnchor.constraint(equalTo: topAnchor, constant: 30),
            videoBlockerImage.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 10),
        ])
    }
    
    func toggleBlocker() {
        videoBlockerImage.isHidden = !videoBlockerImage.isHidden
        gradient.isHidden = !gradient.isHidden
    }
}

