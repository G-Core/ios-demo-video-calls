//
//  GCVideoCallBlurView.swift
//  GCoreVideoCalls
//
//  Created by Evgenij Polubin on 26.04.2022.
//

import UIKit

final class GCVideoCallBlurView: UIVisualEffectView {
    
    init(frame: CGRect) {
        let blurEffect = UIBlurEffect(style: .dark)
        super.init(effect: blurEffect)
        self.frame = frame
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
