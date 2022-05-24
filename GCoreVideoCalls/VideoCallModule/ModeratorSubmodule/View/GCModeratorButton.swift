//
//  GCModeratorButton.swift
//  GCoreVideoCalls
//
//  Created by Evgenij Polubin on 24.05.2022.
//

import UIKit

final class GCModeratorButton: GCoreButton {
    enum ButtonType: Int {
        case toggleWaitingRoom
        case toggleCamsPermission
        case toggleMicsPermission
        case toggleSharingPermission
        case turnOffAllMics
        case turnOffAllCams
    }
    
    let type: ButtonType
    
    init(type: ButtonType) {
        self.type = type
        let font = UIFont.montserratMedium(size: 14)
        super.init(font: font, image: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
