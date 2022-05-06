//
//  GCSwitchsLabel.swift
//  GCoreVideoCalls
//
//  Created by Evgenij Polubin on 28.03.2022.
//

import UIKit

final class GCSwitchsLabel: UILabel {
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .blueMagentaDark
        textColor = .white
        textAlignment = .left
        layer.cornerRadius = 12
        clipsToBounds = true
        font = font.withSize(14)
        text = "Off"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
        super.drawText(in: rect.inset(by: insets))
    }
}
