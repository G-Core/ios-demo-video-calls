//
//  GCoreTextField.swift
//  GCoreVideoCalls
//
//  Created by Evgenij Polubin on 25.03.2022.
//

import UIKit

final class GCoreTextField: UITextField {
    
    init(placeholder: String = "") {
        super.init(frame: .zero)
        let color = UIColor.init(white: 1, alpha: 0.2)
        attributedPlaceholder = .init(string: placeholder, attributes: [.foregroundColor: color])
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .blueMagentaDark
        textColor = .white
        layer.cornerRadius = 10
        layer.borderWidth = 1.5
        layer.borderColor = UIColor.cyanBlueMediumLight?.cgColor
        initRightView()
        delegate = self
        keyboardAppearance = .dark
        keyboardType = .asciiCapable
        autocorrectionType = .no
    }
    
    private func initRightView() {
        let button = UIButton(type: .custom)
        button.setImage(.copyIcon, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.frame.size = CGSize(width: 30, height: 30)
        button.addTarget(self, action: #selector(tapCopyIcon), for: .touchUpInside)
        
        rightView = button
        rightViewMode = .always
    }
    
    @objc private func tapCopyIcon() {
        UIPasteboard.general.string = text
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        var correctBounds = bounds.insetBy(dx: 15, dy: 15)
        correctBounds.size.width -= 35
        return correctBounds
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        var correctBounds = bounds.insetBy(dx: 15, dy: 15)
        correctBounds.size.width -= 35
        return correctBounds
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var correctBounds = super.rightViewRect(forBounds: bounds)
        correctBounds.origin.x -= 10
        return correctBounds
    }
}

extension GCoreTextField: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        layer.borderColor = UIColor.darkWashedOrange?.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        layer.borderColor = UIColor.cyanBlueMediumLight?.cgColor
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= 200
    }
}
