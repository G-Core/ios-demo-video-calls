import UIKit

extension RoomMainView {
    func setupConstraintsFor(
        topButtonsStack: UIView,
        callButtonsStack: UIView,
        pinnedUserView: UIView,
        backButton: UIView,
        collection: UIView
    ) {
        let screenInsets = SizeHelper.screenHeight * 0.019
        let stackViewRightInset = -(SizeHelper.screenWidth * 0.024)
        let stackViewBottomInset = -(SizeHelper.screenHeight * 0.022)
        let backButtonLeftInset = SizeHelper.screenWidth * 0.037

        pinnedUserViewHeightConstraint = NSLayoutConstraint(
            item: pinnedUserView,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: 0
        )

        pinnedUserViewBottomConstraint = NSLayoutConstraint(
            item: pinnedUserView,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: collectionView,
            attribute: .top,
            multiplier: 1,
            constant: -8
        )

        collectionBottomConstraint = NSLayoutConstraint(
            item: collectionView,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: self,
            attribute: .bottom,
            multiplier: 1,
            constant: 0
        )

        pinnedUserView.addConstraint(pinnedUserViewHeightConstraint!)
        addConstraint(pinnedUserViewBottomConstraint!)
        addConstraint(collectionBottomConstraint!)

        NSLayoutConstraint.activate([
            topButtonsStack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: screenInsets),
            topButtonsStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: stackViewRightInset),
            topButtonsStack.bottomAnchor.constraint(equalTo: pinnedUserView.topAnchor, constant: stackViewBottomInset),

            pinnedUserView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: screenInsets),
            pinnedUserView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -(screenInsets)),

            backButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: screenInsets),
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: backButtonLeftInset),

            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),

            callButtonsStack.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            callButtonsStack.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
