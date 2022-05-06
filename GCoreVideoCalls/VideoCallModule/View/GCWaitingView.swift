//
//  GCWaitingView.swift
//  GCoreVideoCalls
//
//  Created by Evgenij Polubin on 29.04.2022.
//

import UIKit

final class GCWaitingView: UIView {
    private let connectingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Connecting..."
        label.font = .montserratMedium(size: 18)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.textColor = .white
        return label
    }()
    
    private let loadingPoint1 = UIView()
    private let loadingPoint2 = UIView()
    private let loadingPoint3 = UIView()
    
    private var timer: Timer?
    
    var state: VideoCallConnectionState = .start {
        didSet { connectionStateChanged() }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .blueMagentaDark
        tag = 0
        
        let points = [loadingPoint1, loadingPoint2, loadingPoint3]
        
        points.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 15
            addSubview($0)
            
            NSLayoutConstraint.activate([
                $0.widthAnchor.constraint(equalToConstant: 30),
                $0.heightAnchor.constraint(equalToConstant: 30)
            ])
        }
        
        initConstraint()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func initConstraint() {
        addSubview(connectingLabel)
        
        NSLayoutConstraint.activate([
            connectingLabel.bottomAnchor.constraint(equalTo: loadingPoint2.topAnchor, constant: -30),
            connectingLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            connectingLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
            connectingLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -10),
            connectingLabel.heightAnchor.constraint(equalToConstant: connectingLabel.intrinsicContentSize.height),
            
            loadingPoint2.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingPoint2.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            loadingPoint1.rightAnchor.constraint(equalTo: loadingPoint2.leftAnchor, constant: -15),
            loadingPoint1.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            loadingPoint3.leftAnchor.constraint(equalTo: loadingPoint2.rightAnchor, constant: 15),
            loadingPoint3.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    func stopAnimation() {
        timer?.invalidate()
        timer = nil
        loadingPoint1.transform = .init(scaleX: 1, y: 1)
        loadingPoint2.transform = .init(scaleX: 1, y: 1)
        loadingPoint3.transform = .init(scaleX: 1, y: 1)
        tag = 0
    }
    
    func startAnimation() {
        guard timer == nil else { return }
        
        timer = Timer.scheduledTimer(
            timeInterval: 0.3,
            target: self,
            selector: #selector(timerLoop),
            userInfo: nil,
            repeats: true
        )
        
        timer?.fire()
    }
    
    @objc private func timerLoop() {
        switch tag {
        case 0:
            loadingPoint1.transform = .init(scaleX: 1.2, y: 1.2)
            tag = 1
            
        case 1:
            loadingPoint1.transform = .init(scaleX: 1, y: 1)
            loadingPoint2.transform = .init(scaleX: 1.2, y: 1.2)
            tag = 2
            
        case 2:
            loadingPoint2.transform = .init(scaleX: 1, y: 1)
            loadingPoint3.transform = .init(scaleX: 1.2, y: 1.2)
            tag = 3
            
        case 3:
            loadingPoint3.transform = .init(scaleX: 1, y: 1)
            loadingPoint1.transform = .init(scaleX: 1.2, y: 1.2)
            tag = 1
            
        default:
            break
        }
    }
    
    let texts: [VideoCallConnectionState: String] = [
        .start: "Connecting...",
        .reconnecting: "Reconecting...",
        .waitingForModeratorJoinAccept: "Waiting for the moderator to grant access..."
    ]
    
    func connectionStateChanged() {
        connectingLabel.text = texts[state]
        
        switch state {
        case state where state == .start || state == .reconnecting || state == .waitingForModeratorJoinAccept:
            isHidden = false
            startAnimation()
            
        case .moderatorRejectedJoinRequest: stopAnimation()
            
        case .disconnecting: stopAnimation()
        
        default:
            isHidden = true
            stopAnimation()
        }
    }
}
