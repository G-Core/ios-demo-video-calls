import UIKit

fileprivate typealias HomeCell = HomeScreenCollectionViewCell

final class HomeCollectionDataSource: NSObject, UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: HomeCell.cellId,
            for: indexPath
        ) as? HomeCell else {
            return UICollectionViewCell()
        }

        let image = UIImage.homeScreenImages[indexPath.row]
        let description: String = .homeScreenDescription[indexPath.row]
        cell.configure(with: image, and: description)

        return cell
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        UIImage.homeScreenImages.count
    }
}
