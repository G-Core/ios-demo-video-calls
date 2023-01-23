import UIKit

extension HomeMainView {
    func initConstraintsFor(
        logo: UIView,
        collection: UIView,
        description: UIView,
        pageControl: UIView,
        createButton: UIView,
        connectButton: UIView
    ) {
        let logoTopInset = SizeHelper.screenHeight * 0.031
        let logoHeight =  SizeHelper.screenHeight * 0.038
        let logoBottomInset = -(SizeHelper.screenHeight * 0.104)
        let collectionHeight = SizeHelper.screenHeight * 0.29
        let collectionBottomInset = -(SizeHelper.screenHeight * 0.014)
        let descriptionWidth = SizeHelper.screenWidth * 0.6
        let pageControlTopInset = SizeHelper.screenHeight * 0.024
        let pageControlWidth = SizeHelper.screenWidth * 0.15
        let createButtonSideInsets = SizeHelper.screenWidth * 0.042
        let createButtonBottomInset = -(SizeHelper.screenHeight * 0.019)
        let connectButtonBottomInset = -(SizeHelper.screenHeight * 0.071)

        NSLayoutConstraint.activate([
            logo.centerXAnchor.constraint(equalTo: centerXAnchor),
            logo.heightAnchor.constraint(equalToConstant: logoHeight),
            logo.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: logoTopInset),
            logo.bottomAnchor.constraint(equalTo: collection.topAnchor, constant: logoBottomInset),

            collection.leadingAnchor.constraint(equalTo: leadingAnchor),
            collection.trailingAnchor.constraint(equalTo: trailingAnchor),
            collection.heightAnchor.constraint(equalToConstant: collectionHeight),
            collection.bottomAnchor.constraint(equalTo: description.topAnchor, constant: collectionBottomInset),

            description.centerXAnchor.constraint(equalTo: collection.centerXAnchor),
            description.widthAnchor.constraint(equalToConstant: descriptionWidth),

            pageControl.topAnchor.constraint(equalTo: description.bottomAnchor , constant: pageControlTopInset),
            pageControl.centerXAnchor.constraint(equalTo: description.centerXAnchor),
            pageControl.widthAnchor.constraint(equalToConstant: pageControlWidth),

            createButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: createButtonSideInsets),
            createButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -(createButtonSideInsets)),
            createButton.bottomAnchor.constraint(equalTo: connectButton.topAnchor, constant: createButtonBottomInset),

            connectButton.leadingAnchor.constraint(equalTo: createButton.leadingAnchor),
            connectButton.trailingAnchor.constraint(equalTo:createButton.trailingAnchor),
            connectButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: connectButtonBottomInset),
        ])
    }
}
