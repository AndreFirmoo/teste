//
//  CustomizeViewController.swift
//  POCTableView
//
//  Created by Andre Firmo on 02/04/23.
//

import UIKit

final class CustomizeViewController: UIViewController {
    
    private var cardItems: [CardInformation] = [
        CardInformation(
            nameCard: "Conta Corrente",
            nameIconBadge: "airtag.radiowaves.forward",
            
            nameIconDelete: "delete.backward.fill",
            
            isDeleteAvailable: true,
            isInsertAvailable: false
        ),
        CardInformation(
            nameCard: "Cartão de credito Visa",
            nameIconBadge: "creditcard.fill",
            nameIconDelete: "delete.backward.fill",
            isDeleteAvailable: true,
            isInsertAvailable: false
        ),
        CardInformation(
            nameCard: "Emprestimos",
            nameIconBadge: "bolt.ring.closed",
            
            nameIconDelete: "delete.backward.fill",
            
            isDeleteAvailable: true,
            isInsertAvailable: false
        ),
        CardInformation(
            nameCard: "Investimentos",
            nameIconBadge: "lungs.fill",
            nameIconDelete: "delete.backward.fill",
            isDeleteAvailable: true,
            isInsertAvailable: false
        ),
    ]
    
    private lazy var mainCardCollection: CustomizeCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        let customizeCollection = CustomizeCollectionView(
            collectionViewLayout: flowLayout,
            collectionViewCell: CustomizeCollectionViewCell.self,
            isReoderAvailable: true
        )
        
        customizeCollection.items = self.cardItems
        return customizeCollection
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(mainCardCollection)
        NSLayoutConstraint.activate([
            mainCardCollection.topAnchor.constraint(equalTo: view.topAnchor),
            mainCardCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainCardCollection.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mainCardCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}
