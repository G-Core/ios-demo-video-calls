//
//  GCEndScreenViewController.swift
//  GCoreVideoCalls
//
//  Created by Evgenij Polubin on 04.04.2022.
//

import UIKit

final class GCEndScreenViewController: GCTitleViewController {
    private let reconnectButton: GCoreButton = {
        let button = GCoreButton(font: .montserratMedium(size: 14), image: nil)
        button.setTitle("Reconnect", for: .normal)
        button.addTarget(self, action: #selector(tapReconnectButton), for: .touchUpInside)
        return button
    }()
    
    private let refreshButton: GCoreButton = {
        let button = GCoreButton(font: .montserratMedium(size: 14), image: nil)
        button.setTitle("Create a room", for: .normal)
        button.addTarget(self, action: #selector(tapRefreshButton), for: .touchUpInside)
        return button
    }()
    
    private let sharedStackButtons = GCSharedLinksStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initConstraints()
    }
    
    override func initConstraints() {
        super.initConstraints()
        
        view.addSubview(reconnectButton)
        view.addSubview(refreshButton)
        view.addSubview(sharedStackButtons)
        
        NSLayoutConstraint.activate([
            reconnectButton.bottomAnchor.constraint(equalTo: sharedStackButtons.topAnchor, constant: -10),
            reconnectButton.heightAnchor.constraint(equalToConstant: reconnectButton.intrinsicContentSize.height + 10),
            reconnectButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            reconnectButton.rightAnchor.constraint(equalTo: refreshButton.leftAnchor, constant: -10),
            
            refreshButton.bottomAnchor.constraint(equalTo: sharedStackButtons.topAnchor, constant: -10),
            refreshButton.widthAnchor.constraint(equalTo: reconnectButton.widthAnchor),
            refreshButton.heightAnchor.constraint(equalToConstant: (refreshButton.intrinsicContentSize.height + 10)),
            refreshButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            
            sharedStackButtons.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -10),
            sharedStackButtons.leftAnchor.constraint(equalTo: meetImageView.leftAnchor),
            sharedStackButtons.rightAnchor.constraint(equalTo: meetImageView.rightAnchor),
            sharedStackButtons.heightAnchor.constraint(equalTo: sharedStackButtons.heightAnchor, constant: 20),
        ])
    }
    
    @objc private func tapReconnectButton() {
        guard let preview = navigationController?.viewControllers.first(where: { $0 == $0 as? GCPreviewViewController }) else { return }
        navigationController?.popToViewController(preview, animated: true)
    }
    
    @objc private func tapRefreshButton() {
        navigationController?.popToRootViewController(animated: true)
    }
}
