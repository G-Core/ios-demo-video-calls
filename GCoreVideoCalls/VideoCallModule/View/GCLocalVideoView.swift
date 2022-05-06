//
//  GCLocalVideoView.swift
//  GCoreVideoCalls
//
//  Created by Evgenij Polubin on 18.04.2022.
//

import UIKit
import GCoreVideoCallsSDK

final class GCLocalVideoView: UIView {
    private var rtcView: RTCEAGLVideoView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 4
        
        backgroundColor = .black
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addRTC(_ rtcView: RTCEAGLVideoView) {
        self.rtcView = rtcView
        addSubview(rtcView)
        rtcView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            rtcView.leftAnchor.constraint(equalTo: leftAnchor),
            rtcView.rightAnchor.constraint(equalTo: rightAnchor),
            rtcView.topAnchor.constraint(equalTo: topAnchor),
            rtcView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
