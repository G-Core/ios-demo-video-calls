//
//  GCSharedLinksStackView.swift
//  GCoreVideoCalls
//
//  Created by Evgenij Polubin on 06.04.2022.
//

import UIKit

final class GCSharedLinksStackView: UIStackView {
    
    private let facebookButton = GCoreButton(font: nil, image: .facebookImage)
    private let twitterButton = GCoreButton(font: nil, image: .twitterImage)
    private let linkedInButton = GCoreButton(font: nil, image: .linkedInImage)
    
    init() {
        super.init(frame: .zero)
        
        addArrangedSubview(facebookButton)
        addArrangedSubview(twitterButton)
        addArrangedSubview(linkedInButton)
        
        for view in arrangedSubviews {
            view.backgroundColor = .clear
            (view as? UIButton)?.addTarget(self, action: #selector(tapButton(_:)), for: .touchUpInside)
        }
        
        axis = .horizontal
        translatesAutoresizingMaskIntoConstraints = false
        distribution = .equalSpacing
        spacing = 10
        backgroundColor = .clear
        
        initConstaintsForButtons([
            facebookButton,
            twitterButton,
            linkedInButton
        ])
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func tapButton(_ button: UIButton) {
        switch button {
            
        case button where button == facebookButton:
            guard let url = URL(string: "https://www.facebook.com/gcorelabscom") else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            
        case button where button == twitterButton:
            guard let url = URL(string: "https://twitter.com/gcorelabs") else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            
        case button where button == linkedInButton:
            guard let url = URL(string: "https://www.linkedin.com/company/g-core/") else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            
        default: return
        }
    }
    
    
    private func initConstaintsForButtons(_ buttons: [GCoreButton]) {
        for button in buttons {
            var constrainst = [
                button.widthAnchor.constraint(equalToConstant: 60),
                button.heightAnchor.constraint(equalToConstant: 60)
            ]
            
            if let imageView = button.imageView {
                imageView.contentMode = .scaleAspectFit
                imageView.translatesAutoresizingMaskIntoConstraints = false
                constrainst += [
                    imageView.widthAnchor.constraint(equalToConstant: 50),
                    imageView.heightAnchor.constraint(equalToConstant: 50),
                    imageView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
                    imageView.centerYAnchor.constraint(equalTo: button.centerYAnchor)
                ]
            }
            
            NSLayoutConstraint.activate(constrainst)
        }
    }
}



