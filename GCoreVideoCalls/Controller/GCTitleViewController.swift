//
//  GCTitleViewController.swift
//  GCoreVideoCalls
//
//  Created by Evgenij Polubin on 26.04.2022.
//

import UIKit

class GCTitleViewController: GCBaseViewController {
    let gcoreImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = .gcoreTitle
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    let meetImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = .meetTitle
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .montserratMedium(size: 28)
        label.textColor = .white
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.text = "Video calls for business"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .montserratRegular(size: 18)
        label.textColor = .white
        label.textAlignment = .center
        label.text = "Create your own personal room, share with visitors and start your online event without any registrations or downloads."
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        initConstarintsAfterLayoutSubviews()
    }
    
    func initConstraints() {
        view.addSubview(gcoreImageView)
        view.addSubview(meetImageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            gcoreImageView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 5),
            gcoreImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            gcoreImageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 60),
            gcoreImageView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -60),
            
            meetImageView.topAnchor.constraint(equalTo: gcoreImageView.bottomAnchor, constant: 10),
            meetImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            meetImageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 60),
            meetImageView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -60),
            
            titleLabel.topAnchor.constraint(equalTo: meetImageView.bottomAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 60),
            titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -60),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 60),
            subtitleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -60),
        ])
    }
    
    private func initConstarintsAfterLayoutSubviews() {
        NSLayoutConstraint.activate([
            meetImageView.heightAnchor.constraint(equalToConstant: meetImageView.contentClippingRect.height),
            gcoreImageView.heightAnchor.constraint(equalToConstant: gcoreImageView.contentClippingRect.height)
        ])
    }
}
