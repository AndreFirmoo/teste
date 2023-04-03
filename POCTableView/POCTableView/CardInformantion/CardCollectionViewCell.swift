//
//  CardCollectionViewCell.swift
//  POCTableView
//
//  Created by Andre Firmo on 29/03/23.
//

import UIKit

final class CardCollectionViewCell: UICollectionViewCell {
    
    private lazy var itemLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var badgeCard: UIImageView = {
        let badge = UIImageView()
        badge.translatesAutoresizingMaskIntoConstraints = false
        return badge
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var dragButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(itemLabel)
        contentView.addSubview(dragButton)
        contentView.addSubview(deleteButton)
        contentView.addSubview(badgeCard)
        NSLayoutConstraint.activate([
            dragButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -23),
            dragButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            dragButton.heightAnchor.constraint(equalToConstant: 13),
            dragButton.widthAnchor.constraint(equalToConstant: 18),
            itemLabel.leadingAnchor.constraint(equalTo: badgeCard.trailingAnchor, constant: 10),
            itemLabel.trailingAnchor.constraint(equalTo: dragButton.leadingAnchor, constant: 10),
            itemLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            badgeCard.leadingAnchor.constraint(equalTo: deleteButton.trailingAnchor, constant: 18),
            badgeCard.heightAnchor.constraint(equalToConstant: 15),
            badgeCard.widthAnchor.constraint(equalToConstant: 20),
            badgeCard.centerYAnchor.constraint(equalTo: centerYAnchor),
            deleteButton.heightAnchor.constraint(equalToConstant: 15),
            deleteButton.widthAnchor.constraint(equalToConstant: 20),
            deleteButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            deleteButton.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(cell: CardInformation) {
        itemLabel.text = cell.nameCard
        badgeCard.image = UIImage(systemName: cell.nameIconBadge)
        
        if cell.isInsertAvailable && !cell.isDeleteAvailable {
            deleteButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
            dragButton.isHidden = true
        } else if !cell.isInsertAvailable &&  cell.isDeleteAvailable {
            deleteButton.setImage(UIImage(systemName: cell.nameIconDelete), for: .normal)
            
        } else if !cell.isDeleteAvailable{
            deleteButton.setImage(UIImage(systemName: cell.nameIconDelete), for: .normal)
          
            deleteButton.isEnabled = false
            dragButton.isEnabled = false
        }
    }
    
    func setTargetForDelete(cardCollectionView: CardCollectionView, _ selector: Selector) {
        deleteButton.addTarget(cardCollectionView, action: selector, for: .touchUpInside)
    }
    
    func setDeleteAndDragIsAvailable(available: Bool) {
        deleteButton.isEnabled = available
        dragButton.isEnabled = available
        if !available {
            deleteButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        }
    }
}
