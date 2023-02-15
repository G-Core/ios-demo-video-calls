import UIKit

fileprivate typealias VideoCell = VideoUserCollectionViewCell
fileprivate typealias UserCell = UserCollectionViewCell
fileprivate typealias Footer = CollectionFooter

final class RoomCollectionDataSource: NSObject {
    var state: RoomState = .tile
    var currentUserdId = ""
    
    var videoUsersData: () -> [RemoteUser] = { [] } 
    var noVideoUsersData: () -> [RemoteUser] = { [] }
    var remoteUsersData: () -> [RemoteUser] = { [] }
    var screenSharingUsers: () -> [String] = { [] }
    var activityVCHandler: () -> Void = { }
}

extension RoomCollectionDataSource: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        state == .fullScreen ? 1 : 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch state {
        case .tile:
            var total = section == 0 ? videoUsersData().count : noVideoUsersData().count
            if section == 0 && !screenSharingUsers().isEmpty {
                total += 1
            }
            return total
        case .fullScreen:
            return remoteUsersData().count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let videoUserCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: VideoCell.cellId,
            for: indexPath
        ) as? VideoCell else {
            return UICollectionViewCell()
        }

        guard let userWithoutVideoCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: UserCell.cellId,
            for: indexPath) as? UserCell
        else {
            return UICollectionViewCell()
        }

        let remoteUsers = remoteUsersData()
        let videoUsers = videoUsersData()
        let noVideoUsers = noVideoUsersData()

        let user: RemoteUser

        switch state {
        case .fullScreen:
            user = remoteUsers[indexPath.row]
            let isSelected = (user.id == currentUserdId)
            videoUserCell.configure(with: user, and: state, isPinned: isSelected)
            return videoUserCell

        case .tile:
            if indexPath.section == 0 && indexPath.row == 0,
               let id = screenSharingUsers().first,
               let user = remoteUsers.first(where: { $0.id == id }) {
                videoUserCell.configureScreenSharing(with: user)
                return videoUserCell
            }
    
            if indexPath.section == 0 {
                var index = indexPath.row
                if !screenSharingUsers().isEmpty {
                    index -= 1
                }
                user = videoUsers[index]
                videoUserCell.configure(with: user, and: state)
                return videoUserCell
            }

            user = noVideoUsers[indexPath.row]
            userWithoutVideoCell.configure(with: user)
            return userWithoutVideoCell
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let footer = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: Footer.identifier,
            for: indexPath
        ) as? Footer else {
            return UICollectionReusableView()
        }

        footer.delegate = self
        return footer
    }
}

extension RoomCollectionDataSource: ActivityPresenterProtocol {
    func presentActivityVC() {
        activityVCHandler()
    }
}
        
