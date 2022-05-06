//
//  GCoreButton.swift
//  GCoreVideoCalls
//
//  Created by Evgenij Polubin on 24.03.2022.
//

import UIKit

class GCoreButton: UIButton {
    init(font: UIFont?, image: UIImage?) {
        super.init(frame: .zero)
        
        backgroundColor = .darkWashedOrange
        contentMode = .scaleAspectFit
        layer.cornerRadius = 16
        translatesAutoresizingMaskIntoConstraints = false
        
        setImage(image, for: .normal)
        
        titleLabel?.font = font
        titleLabel?.textColor = .white
        titleLabel?.textAlignment = .center
        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.lineBreakMode = .byTruncatingTail
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        alpha = 0.5
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        alpha = 1
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        alpha = 1
    }
}
