import UIKit

extension PreviewMainView {
    func setupConstraintsFor(
        preview: UIView,
        buttonsStack: UIView,
        nameTextField: UIView,
        warningLabel: UIView,
        connectButton: UIView,
        letterImage: UIView
    ) {
        let previewTopInset = SizeHelper.screenHeight * 0.051
        let previewSideInsets = SizeHelper.screenWidth * 0.042
        let previewHeight = SizeHelper.screenHeight * 0.283
        let previewWidth = SizeHelper.screenWidth * 0.914
        let bottomInset = -(SizeHelper.screenHeight * 0.024)
        
        let warningBottomInset = -(SizeHelper.screenHeight * 0.009)

        NSLayoutConstraint.activate([
            preview.heightAnchor.constraint(equalToConstant: previewHeight),
            preview.widthAnchor.constraint(equalToConstant: previewWidth),
            preview.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: previewTopInset),
            preview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: previewSideInsets),
            preview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -previewSideInsets),
            preview.bottomAnchor.constraint(equalTo: buttonsStack.topAnchor, constant: bottomInset),

            buttonsStack.centerXAnchor.constraint(equalTo: preview.centerXAnchor),
            buttonsStack.bottomAnchor.constraint(equalTo: nameTextField.topAnchor, constant: bottomInset),

            nameTextField.leadingAnchor.constraint(equalTo: preview.leadingAnchor),
            nameTextField.trailingAnchor.constraint(equalTo: preview.trailingAnchor),
            nameTextField.bottomAnchor.constraint(equalTo: warningLabel.topAnchor, constant: warningBottomInset),

            warningLabel.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            warningLabel.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            warningLabel.bottomAnchor.constraint(equalTo: connectButton.topAnchor, constant: bottomInset),

            connectButton.leadingAnchor.constraint(equalTo: preview.leadingAnchor),
            connectButton.trailingAnchor.constraint(equalTo: preview.trailingAnchor),

            letterImage.centerYAnchor.constraint(equalTo: preview.centerYAnchor),
            letterImage.centerXAnchor.constraint(equalTo: preview.centerXAnchor),
        ])
    }
}
