//
//  GCSwitch.swift
//  GCoreVideoCalls
//
//  Created by Evgenij Polubin on 28.03.2022.
//

import UIKit

final class GCSwitch: UISwitch {
    
    init(onImage: UIImage?, offImage: UIImage?) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 16
        backgroundColor = .redOrange
        addTarget(self, action: #selector(toggle), for: .valueChanged)
        addImages(onImage: onImage, offImage: offImage)
        transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
    }
    
    @objc func toggle() {
        isOn ? (backgroundColor = .greenCyan) : (backgroundColor = .redOrange)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addImages(onImage: UIImage?, offImage: UIImage?) {
        guard let onImage = onImage,
              let offImage = offImage
        else { return }
        
        let onImageView = UIImageView(image: onImage)
        onImageView.translatesAutoresizingMaskIntoConstraints = false
        onImageView.contentMode = .scaleAspectFit
        
        let offImageView = UIImageView(image: offImage)
        offImageView.translatesAutoresizingMaskIntoConstraints = false
        offImageView.contentMode = .scaleAspectFit
        
        addSubview(onImageView)
        addSubview(offImageView)
        
        NSLayoutConstraint.activate([
            onImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 3),
            onImageView.rightAnchor.constraint(equalTo: offImageView.leftAnchor, constant: -12),
            onImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            onImageView.widthAnchor.constraint(equalTo: offImageView.widthAnchor),
            
            offImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            offImageView.rightAnchor.constraint(equalTo: rightAnchor, constant: -3),
        ])
        
    }
}
