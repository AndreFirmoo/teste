//
//  CustomizeCollectionViewCell.swift
//  POCTableView
//
//  Created by Andre Firmo on 02/04/23.
//

import UIKit

protocol CustomizeCellAccessibility: AnyObject {
    var indexPath: IndexPath? { get }
    func indexPaths(for cell: CustomizeCollectionViewCell) -> IndexPath?
    func numberOfItems(inSection section: Int) -> Int
    func nextItemAction(for cell: CustomizeCollectionViewCell) -> Bool
    func previousItemAction(for cell: CustomizeCollectionViewCell) -> Bool
    func deleteItemAction(for cell: CustomizeCollectionViewCell) -> Bool
    func itemPosition(for cell: CustomizeCollectionViewCell) -> (isFirst: Bool, isLast: Bool)
}

final class CustomizeCollectionViewCell: UICollectionViewCell {
    weak var accessibilityDelegate: CustomizeCellAccessibility?
    
    private lazy var containerCell: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var itemLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var badgeCard: UIImageView = {
        let badge = UIImageView()
        badge.translatesAutoresizingMaskIntoConstraints = false
        return badge
    }()
    
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var reorderButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "line.3.horizontal")
        image?.withTintColor(.black, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture))
        button.addGestureRecognizer(longPressGesture)
        return button
    }()
    
    private lazy var containerDelete: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .red
        return view
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Remover", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func prepareForReuse() {
        super.prepareForReuse()
        updateAccessibilityActionsForReoderButton()
    }
}

//MARK: - Setup View anchor and subViews
extension CustomizeCollectionViewCell {
    func setup() {
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        contentView.addSubview(containerCell)
        containerCell.addSubview(itemLabel)
        containerCell.addSubview(reorderButton)
        containerCell.addSubview(actionButton)
        containerCell.addSubview(badgeCard)
    }
    private func setupConstraints() {
        setupConstraintsContainerCell()
        setupConstraintsItemLabel()
        setupConstraintsReorderButton()
        setupConstraintsActionButton()
        setupConstraintsBadgeCard()
    }
    
    private func setupConstraintsContainerCell() {
        NSLayoutConstraint.activate([
            containerCell.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerCell.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerCell.heightAnchor.constraint(equalTo: contentView.heightAnchor),
            containerCell.widthAnchor.constraint(equalTo: contentView.widthAnchor)
        ])
    }
    
    private func setupConstraintsItemLabel() {
        NSLayoutConstraint.activate([
            itemLabel.leadingAnchor.constraint(equalTo: badgeCard.trailingAnchor, constant: 10),
            itemLabel.trailingAnchor.constraint(equalTo: reorderButton.leadingAnchor, constant: 10),
            itemLabel.centerYAnchor.constraint(equalTo: containerCell.centerYAnchor)
        ])
    }
    
    private func setupConstraintsReorderButton() {
        NSLayoutConstraint.activate([
            reorderButton.trailingAnchor.constraint(equalTo: containerCell.trailingAnchor, constant: -23),
            reorderButton.centerYAnchor.constraint(equalTo: containerCell.centerYAnchor),
            reorderButton.heightAnchor.constraint(equalToConstant: 30),
            reorderButton.widthAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func setupConstraintsActionButton() {
        NSLayoutConstraint.activate([
            actionButton.heightAnchor.constraint(equalToConstant: 15),
            actionButton.widthAnchor.constraint(equalToConstant: 20),
            actionButton.leadingAnchor.constraint(equalTo: containerCell.leadingAnchor, constant: 24),
            actionButton.centerYAnchor.constraint(equalTo: containerCell.centerYAnchor)
        ])
    }
    
    private func setupConstraintsBadgeCard() {
        NSLayoutConstraint.activate([
            badgeCard.leadingAnchor.constraint(equalTo: actionButton.trailingAnchor, constant: 18),
            badgeCard.heightAnchor.constraint(equalToConstant: 15),
            badgeCard.widthAnchor.constraint(equalToConstant: 20),
            badgeCard.centerYAnchor.constraint(equalTo: containerCell.centerYAnchor),
        ])
    }
}

//MARK: - Setup Cell Informations
extension CustomizeCollectionViewCell {
    func setup(cell: CardInformation) {
        itemLabel.text = cell.nameCard
        badgeCard.image = UIImage(systemName: cell.nameIconBadge)
        if cell.isInsertAvailable && !cell.isDeleteAvailable {
            actionButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
            reorderButton.isHidden = true
        } else if !cell.isInsertAvailable && cell.isDeleteAvailable {
            actionButton.isAccessibilityElement = false
            actionButton.setImage(UIImage(systemName: cell.nameIconDelete), for: .normal)
        }
    }
}

//MARK: - LongPress section
extension CustomizeCollectionViewCell {
    @objc func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            if let collectionView = superview as? UICollectionView,
               let indexPath = collectionView.indexPath(for: self) {
                collectionView.beginInteractiveMovementForItem(at: indexPath)
            }
        case .changed:
            if let collectionView = superview as? UICollectionView {
                collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: collectionView))
            }
        case .ended:
            if let collectionView = superview as? UICollectionView {
                collectionView.endInteractiveMovement()
            }
            
        default:
            if let collectionView = superview as? UICollectionView {
                collectionView.cancelInteractiveMovement()
                if UIAccessibility.isVoiceOverRunning {
                    let sourceIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView))
                    let destinationIndexPath = accessibilityDelegate?.indexPath
                    
                    if let sourceIndexPath = sourceIndexPath,
                       let destinationIndexPath = destinationIndexPath,
                       sourceIndexPath != destinationIndexPath {
                        if let sourceCell = collectionView.cellForItem(at: sourceIndexPath) as? MyCollectionViewCell {
                            sourceCell.updateAccessibilityActions()
                        }
                        if let destinationCell = collectionView.cellForItem(at: destinationIndexPath) as? MyCollectionViewCell {
                            destinationCell.updateAccessibilityActions()
                        }
                        
                            // Identifique se o gesto foi para cima ou para baixo
                        let movedUp = destinationIndexPath.item < sourceIndexPath.item
                        
                        let announcement: String
                        if movedUp {
                            announcement = "Item \(sourceIndexPath.item) foi movido para cima e trocado com o item \(destinationIndexPath.item)."
                        } else {
                            announcement = "Item \(sourceIndexPath.item) foi movido para baixo e trocado com o item \(destinationIndexPath.item)."
                        }
                        UIAccessibility.post(notification: .announcement, argument: announcement)
                    }
                }
            }
        }
    }
}

// MARK: - Setup Accessibility
extension CustomizeCollectionViewCell {
    @objc func nextItemAction() -> Bool {
        return accessibilityDelegate?.nextItemAction(for: self) ?? false
    }
    
    @objc func previousItemAction() -> Bool {
        return accessibilityDelegate?.previousItemAction(for: self) ?? false
    }
    
    @objc func deleteItemAction() -> Bool {
        return accessibilityDelegate?.deleteItemAction(for: self) ?? false
    }

    func updateAccessibilityActionsForReoderButton() {
        guard let indexPath = accessibilityDelegate?.indexPaths(for: self) else { return }
        
        let isFirstItem = indexPath.item == 0
        let isLastItem = indexPath.item == (accessibilityDelegate?.numberOfItems(inSection: indexPath.section))! - 1
        
        var customActions: [UIAccessibilityCustomAction] = []
        
        if !isFirstItem {
            let previousItemAction = UIAccessibilityCustomAction(
                name: "Item Anterior",
                target: self,
                selector: #selector(previousItemAction)
            )
            customActions.append(previousItemAction)
        }
        
        if !isLastItem {
            let nextItemAction = UIAccessibilityCustomAction(
                name: "Próximo Item",
                target: self,
                selector: #selector(nextItemAction)
            )
            customActions.append(nextItemAction)
        }
        
        let deleteItemAction = UIAccessibilityCustomAction(
            name: "Deletar Item",
            target: self,
            selector: #selector(deleteItemAction)
        )
        
        customActions.append(deleteItemAction)
        reorderButton.isAccessibilityElement = true
        reorderButton.accessibilityCustomActions = customActions
        reorderButton.accessibilityTraits = [.button, .allowsDirectInteraction]
        reorderButton.accessibilityHint = "Toque duas vezes e segure,aguarde o aviso sonoro e depois arraste para reorganizar."
        print(reorderButton.accessibilityCustomActions?.count)
        UIAccessibility.post(notification: .layoutChanged, argument: reorderButton)
        
    }
    
}
