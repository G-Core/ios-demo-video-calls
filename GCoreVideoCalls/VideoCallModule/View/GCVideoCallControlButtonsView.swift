//
//  GCControlButtonsView.swift
//  GCoreVideoCalls
//
//  Created by Evgenij Polubin on 26.04.2022.
//

import UIKit

final class GCVideoCallControlButtonsView: UIScrollView {
    private let buttonsStackView: GCVideoCallButtonsStackView
    
    var buttonsDelegate: GCVideoCallButtonsStackViewDelegate? {
        get { buttonsStackView.delegate }
        set { buttonsStackView.delegate = newValue }
    }
    
    init(withMicrophone: Bool, withVideo: Bool) {
        buttonsStackView = GCVideoCallButtonsStackView(withMicrophone: withMicrophone, withVideo: withVideo)
        
        super.init(frame: .zero)
        
        backgroundColor = .clear
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        
        initConstrains()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func setModeratorButtonVisability(isHidden: Bool) {
        buttonsStackView.moderatorButtonIsHidden = isHidden
    }
    
    func changeButtonState(button type: GCVideoCallButton.ButtonType, to state: GCVideoCallButton.ButtonState) {
        buttonsStackView.changeButtonState(button: type, to: state)
    }
    
}

//MARK: - Layout

extension GCVideoCallControlButtonsView {
    private func initConstrains() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(buttonsStackView)
        
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalTo: buttonsStackView.widthAnchor, constant: 20),
            buttonsStackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
            buttonsStackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -10),
            buttonsStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            buttonsStackView.topAnchor.constraint(equalTo: topAnchor),
        ])
    }
}
