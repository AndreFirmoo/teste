//
//  CustomCollectionViewCell.swift
//  POCTableView
//
//  Created by Andre Firmo on 28/03/23.
//

import Foundation
import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    
    let itemLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var badgeCard: UIImageView = {
        let badge = UIImageView(image: UIImage(systemName: "creditcard.fill"))
        badge.translatesAutoresizingMaskIntoConstraints = false
        return badge
    }()
    
    let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let dragButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "line.3.horizontal.decrease.circle"), for: .normal)
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
}
