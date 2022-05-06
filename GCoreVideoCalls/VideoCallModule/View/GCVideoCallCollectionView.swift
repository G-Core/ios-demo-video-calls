//
//  GCVideoCallCollectionView.swift
//  GCoreVideoCalls
//
//  Created by Evgenij Polubin on 26.04.2022.
//

import UIKit

final class GCVideoCallCollectionView: UICollectionView {
    init(cellId: String) {
        super.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        
        (collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = .init(width: ScreenSize.width - 80,
                                                                                height: (ScreenSize.width - 80) * 3/4)
        
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        register(GCVideoCallCollectionCell.self, forCellWithReuseIdentifier: cellId)
        contentInset.bottom = 80
        showsVerticalScrollIndicator = false
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
