import UIKit

final class GcoreButton: UIButton {
    init(
        font: UIFont?,
        image: UIImage?,
        text: String?,
        bgColor: UIColor = .purple
    ) {
        super.init(frame: .zero)

        backgroundColor = bgColor
        contentMode = .scaleAspectFit
        imageEdgeInsets.right = 15

        layer.borderWidth = 1
        layer.borderColor = UIColor.purple.cgColor
        layer.cornerRadius = SizeHelper.buttonCornerRadius

        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: SizeHelper.buttonHeight).isActive = true

        setImage(image, for: .normal)
        setTitle(text, for: .normal)

        titleLabel?.font = font
        titleLabel?.textColor = .white
        titleLabel?.textAlignment = .center
        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.lineBreakMode = .byTruncatingTail
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        alpha = 0.5
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        alpha = 1
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        alpha = 1
    }
}
