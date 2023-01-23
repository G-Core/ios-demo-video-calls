import UIKit

struct SizeHelper {
    static let screenHeight = UIScreen.main.bounds.height
    static let screenWidth = UIScreen.main.bounds.width

    static let viewCornerRadius: CGFloat = SizeHelper.screenHeight * 0.005

    static let buttonCornerRadius: CGFloat = SizeHelper.screenHeight * 0.009

    static let buttonHeight: CGFloat = SizeHelper.screenHeight * 0.067

    static let letterImageSideSize: CGFloat = SizeHelper.screenHeight * 0.096
    static let letterImageCornerRadius: CGFloat = SizeHelper.letterImageSideSize / 2

    static let letterImageRectangularCellSize: CGFloat = 40
    static let letterImageRectangularCellCornerRadius: CGFloat = 20

    static let circleButtonSize: CGFloat = 50
    static let circleButtonCornerRadius: CGFloat = 25

    static let stackViewHeighTile = SizeHelper.screenHeight * 0.022
    static let stackViewHeightFullScreen = SizeHelper.screenHeight * 0.019

    static let collectionSidePadding: CGFloat = 16
    static let collectionBottomPadding:CGFloat = 8
}
