//
//  GCModeratorControlView.swift
//  GCoreVideoCalls
//
//  Created by Evgenij Polubin on 23.04.2022.
//

import UIKit

protocol GCModeratorControlViewDelegate: AnyObject {
    func didSelectCommand(_ method: ModeratorMethods, for peerId: String)
}

final class GCModeratorControlView: UIView {
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    private let user: User
    private let cellId = "Cell"
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(GCTableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.separatorColor = .clear
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    private lazy var data: [String] = {
        var strings: [String] = [user.name]
        
        for method in ModeratorMethods.allCases {
            strings += [method.rawValue]
        }
        
        return strings
    }()
    
    weak var delegate: GCModeratorControlViewDelegate?
    
    init(frame: CGRect, user: User) {
        self.user = user
        super.init(frame: frame)
        
        nameLabel.text = user.name
        
        layer.cornerRadius = 16
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
        
        backgroundColor = .blueMagenta
        
        initConstraints()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension GCModeratorControlView {
    private func initConstraints() {
        addSubview(nameLabel)
        addSubview(tableView)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            nameLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 5),
            nameLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -5),
            nameLabel.heightAnchor.constraint(equalToConstant: nameLabel.intrinsicContentSize.height + 6),
            
            tableView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            tableView.leftAnchor.constraint(equalTo: leftAnchor),
            tableView.rightAnchor.constraint(equalTo: rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}


extension GCModeratorControlView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count - 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! GCTableViewCell
        cell.setText(data[indexPath.row + 1])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectCommand(ModeratorMethods.allCases[indexPath.row], for: user.id)
    }
}
