//
//  GCTableViewCell.swift
//  GCoreVideoCalls
//
//  Created by Evgenij Polubin on 22.04.2022.
//

import UIKit

final class GCTableViewCell: UITableViewCell {
    override var frame: CGRect {
        get { super.frame }
        
        set (newFrame) {
            var frame = newFrame
            let newWidth = frame.width * 0.80
            let space = (frame.width - newWidth) / 2
            
            frame.size.width = newWidth
            frame.origin.x += space
            
            super.frame = frame
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .blueMagentaDark
        isSelected = false
        clipsToBounds = true
        layer.cornerRadius = 15
        layer.borderWidth = 2
        textLabel?.textColor = .white
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func setText(_ text: String?) {
        textLabel?.text = text
    }
}
