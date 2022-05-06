//
//  ViewController.swift
//  GCoreVideoCalls
//
//  Created by Evgenij Polubin on 22.03.2022.
//

import UIKit

final class GCStartViewController: GCTitleViewController {
    private let model = GCModel.shared
    private let roomTextField = GCoreTextField(placeholder: "Type room link")
    
    private let launchButton: GCoreButton = {
        let button = GCoreButton(font: .montserratMedium(size: 14), image: nil)
        button.setTitle("Connect", for: .normal)
        button.addTarget(self, action: #selector(tapLaunchButton), for: .touchUpInside)
        return button
    }()
    
    private let moderatorButton: GCoreButton = {
        let button = GCoreButton(font: nil, image: nil)
        button.addTarget(self, action: #selector(tapModeratorButton), for: .touchUpInside)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 8
        button.layer.borderColor = UIColor.darkWashedOrange?.cgColor
        button.layer.borderWidth = 3
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    private let moderatorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Moderator mode"
        label.font = .montserratMedium(size: 14)
        label.textColor = .white
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initConstraints()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIApplication.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIApplication.keyboardWillHideNotification,
                                               object: nil)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapOnTheScreen))
        view.addGestureRecognizer(gesture)
    }
    
    @objc func tapOnTheScreen() {
        roomTextField.resignFirstResponder()
    }
    
    @objc func tapLaunchButton() {
        if checkRoomLink() {
            model.userSettings.isModerator = moderatorButton.tag == 1
            let vc = GCPreviewViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func tapModeratorButton() {
        if moderatorButton.tag == 1 {
            moderatorButton.tag = 0
            moderatorButton.backgroundColor = .clear
            moderatorButton.setImage(nil, for: .normal)
        } else {
            moderatorButton.tag = 1
            moderatorButton.backgroundColor = .darkWashedOrange
            moderatorButton.setImage(.icCheck, for: .normal)
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue,
              view.frame.origin.y == 0
        else { return }
        
        view.frame.origin.y -= keyboardSize.height
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue,
              view.frame.origin.y != 0
        else { return }
        
        view.frame.origin.y += keyboardSize.height
    }
    
    private func checkRoomLink() -> Bool {
        let roomId = "roomId="
        
        guard let text = roomTextField.text,
              text.contains(roomId),
              let url = URL(string: text),
              let host = url.host,
              var query = url.query
        else {
            let alert = AlertFabric.newAlert(type: .invalidRoomLink, handler: nil)
            present(alert, animated: true, completion: nil)
            return false
        }
        
        let range = Range(uncheckedBounds: (lower: query.startIndex, upper: roomId.endIndex))
        query.removeSubrange(range)
        
        model.roomData.id = query
        model.roomData.host = host
        model.roomData.url = URL(string: text)
        
        return true
    }
    
    //MARK: - Layout
    
    override func initConstraints() {
        super.initConstraints()
        
        view.addSubview(launchButton)
        view.addSubview(roomTextField)
        view.addSubview(moderatorButton)
        view.addSubview(moderatorLabel)
        
        NSLayoutConstraint.activate([
            roomTextField.bottomAnchor.constraint(equalTo: launchButton.topAnchor, constant: -10),
            roomTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            roomTextField.leftAnchor.constraint(equalTo: gcoreImageView.leftAnchor),
            roomTextField.rightAnchor.constraint(equalTo: gcoreImageView.rightAnchor),
            
            launchButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -10),
            launchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            launchButton.heightAnchor.constraint(equalToConstant: launchButton.intrinsicContentSize.height + 10),
            launchButton.widthAnchor.constraint(equalTo: subtitleLabel.widthAnchor),
            
            moderatorButton.heightAnchor.constraint(equalToConstant: 40),
            moderatorButton.widthAnchor.constraint(equalToConstant: 40),
            moderatorButton.bottomAnchor.constraint(equalTo: roomTextField.topAnchor, constant: -10),
            moderatorButton.leftAnchor.constraint(equalTo: roomTextField.leftAnchor),
            
            moderatorLabel.centerYAnchor.constraint(equalTo: moderatorButton.centerYAnchor),
            moderatorLabel.leftAnchor.constraint(equalTo: moderatorButton.rightAnchor, constant: 10)
        ])
    }
}

