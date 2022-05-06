//
//  GCVideoCallButton.swift
//  GCoreVideoCalls
//
//  Created by Evgenij Polubin on 07.04.2022.
//

import UIKit

final class GCVideoCallButton: UIButton {
    enum ButtonType {
        case microphone, camera, endCall, cameraPosition, shared, moderator
    }
    
    enum ButtonState {
        case unavailable, active, deactive
    }
    
    let type: ButtonType
    var gcState: ButtonState = .deactive
    
    init(type: ButtonType) {
        self.type = type
        super.init(frame: .zero)
        
        switch type {
        case .endCall:
            backgroundColor = .redOrange
            setImage(.phoneIcon, for: .normal)
            
        case .cameraPosition:
            backgroundColor = .gcGreen
            setImage(.switchPositionCamera, for: .normal)
            
        case .shared:
            setImage(.shareIconImage, for: .normal)
            imageView?.contentMode = .scaleAspectFit
            backgroundColor = .blueMagenta
            
        case .moderator:
            setImage(.icModerator, for: .normal)
            imageView?.contentMode = .scaleAspectFit
            backgroundColor = .blueMagentaDark
            
        default:
            break
        }
        
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.black.cgColor
        layer.cornerRadius = 16
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
