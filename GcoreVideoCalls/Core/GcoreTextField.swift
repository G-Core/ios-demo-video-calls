import UIKit

final class GcoreTextField: UITextField {
    private let textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        label.backgroundColor = .blue
        return label
    }()

    init(placeholder: String = "") {
        super.init(frame: .zero)

        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.lightGrey,
            NSAttributedString.Key.font: UIFont.edgeCenterRegularFont(withSize: 17)
        ]

        attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes as [NSAttributedString.Key : Any])

        translatesAutoresizingMaskIntoConstraints = false

        backgroundColor = .veryDarkBlue
        layer.cornerRadius = SizeHelper.viewCornerRadius
        layer.borderWidth = 1.5

        textColor = .white

        delegate = self

        keyboardAppearance = .dark
        keyboardType = .asciiCapable
        autocorrectionType = .no
        returnKeyType = .go

        setupLabel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupLabel() {
        addSubview(textLabel)

        textLabel.textColor = textColor
        textLabel.backgroundColor = backgroundColor
        textLabel.font = font

        let inset: CGFloat = 15

        textLabel.leadingAnchor.constraint(equalTo: leadingAnchor,  constant: inset).isActive = true
        textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset).isActive = true
        textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset).isActive = true
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

extension GcoreTextField: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        layer.borderColor = UIColor.purple.cgColor
        textLabel.isHidden = true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        layer.borderColor = UIColor.clear.cgColor
        textLabel.text = text
        textLabel.isHidden = false
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
