import UIKit

final class RoomCollectionDelegate: NSObject {
    var state: RoomState = .tile
    
    var didSelectItem: (_ user: RemoteUser) -> Void = { _ in }
    var videoUsersData: () -> [RemoteUser] = { [] } 
    var noVideoUsersData: () -> [RemoteUser] = { [] }
    var remoteUsersData: () -> [RemoteUser] = { [] }
}

// MARK: - UICollectionViewDelegate
extension RoomCollectionDelegate: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let videoUsers = videoUsersData()
        let noVideoUsers = noVideoUsersData()
        let remoteUsers = remoteUsersData()
        
        let user: RemoteUser
        switch state {
        case .tile: user = indexPath.section == 0 ? videoUsers[indexPath.row] : noVideoUsers[indexPath.row]
        case .fullScreen: user = remoteUsers[indexPath.row]
        }
        
        didSelectItem(user)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension RoomCollectionDelegate: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        indexPath.section == 1
        ? secondSectionCellSize()
        : firstSectionCellSize(for: indexPath.row, collectionView: collectionView)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let sidePadding: CGFloat = SizeHelper.collectionSidePadding
        let bottomPadding: CGFloat = SizeHelper.collectionBottomPadding
        return UIEdgeInsets(top: 0, left: sidePadding, bottom: bottomPadding, right: sidePadding)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        section == 0 ? 0 : 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        16
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        configFooter(section: section)
    }
}

// MARK: - Private implementation
private extension RoomCollectionDelegate {
    func firstSectionCellSize(for indexPath: Int, collectionView: UICollectionView) -> CGSize {
        let noVideoUsers = noVideoUsersData()

        let bigCellWidth = SizeHelper.screenWidth * 0.914
        let bigCellSize =  CGSize(width: bigCellWidth, height: bigCellWidth / 1.4)

        let mediumCellWidth = SizeHelper.screenWidth * 0.44
        let mediumCellSize = CGSize(width: mediumCellWidth, height: mediumCellWidth * 1.26)

        let squareCellWidth = SizeHelper.screenWidth * 0.2
        let squareCellSize = CGSize(width: squareCellWidth, height: squareCellWidth)

        let isEvenArray = collectionView.numberOfItems(inSection: 0) % 2 == 0

        switch (state, isEvenArray) {
        case (.tile, true):
            return bigCellSize

        case (.tile, false):
            guard !noVideoUsers.isEmpty, indexPath != 0 else { return bigCellSize }
            return mediumCellSize

        case (.fullScreen, _):
            return squareCellSize
        }
    }

    func secondSectionCellSize() -> CGSize {
        CGSize(width: SizeHelper.screenWidth * 0.914, height: SizeHelper.screenHeight * 0.07)
    }

    func configFooter(section: Int) -> CGSize {
        let videoUsers = videoUsersData()
        let noVideoUsers = noVideoUsersData()

        let collectionIsEmpty = videoUsers.isEmpty && noVideoUsers.isEmpty

        guard state == .tile, !collectionIsEmpty else { return CGSize(width: 0, height: 0) }

        switch section {
        case 0 where videoUsers.count <= 1 && noVideoUsers.isEmpty:
            return CGSize(width: SizeHelper.screenWidth, height: SizeHelper.buttonHeight)
        case 1 where noVideoUsers.count <= 1 && videoUsers.isEmpty:
            return CGSize(width: SizeHelper.screenWidth, height: SizeHelper.buttonHeight)
        default:
            return CGSize(width: 0, height: 0)
        }
    }
}
