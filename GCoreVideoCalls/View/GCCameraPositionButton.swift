//
//  GCCameraPositionButton.swift
//  GCoreVideoCalls
//
//  Created by Evgenij Polubin on 26.04.2022.
//

import UIKit

final class GCCameraPositionButton: GCoreButton {
    
    init() {
        super.init(font: nil, image: .switchPositionCamera)
        isUserInteractionEnabled = false
        backgroundColor = .redOrange
        alpha = 0.6
        
        guard let imageView = imageView else { return }
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            imageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8),
            imageView.rightAnchor.constraint(equalTo: rightAnchor, constant: -8),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
