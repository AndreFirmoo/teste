    //
    //  cell.swift
    //  POCTableView
    //
    //  Created by Andre Firmo on 01/04/23.
    //

import Foundation
import UIKit

protocol MyCollectionViewCellDelegate: AnyObject {
    var indexPath: IndexPath? { get }
    func indexPath(for cell: MyCollectionViewCell) -> IndexPath?
    func numberOfItems(inSection section: Int) -> Int
    func nextItemAction(for cell: MyCollectionViewCell) -> Bool
    func previousItemAction(for cell: MyCollectionViewCell) -> Bool
    func deleteItemAction(for cell: MyCollectionViewCell) -> Bool
    func itemPosition(for cell: MyCollectionViewCell) -> (isFirst: Bool, isLast: Bool)
}


class MyCollectionViewCell: UICollectionViewCell {
    
    let button = UIButton(type: .system)
    var longPressGesture: UILongPressGestureRecognizer?
    weak var delegate: MyCollectionViewCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: centerXAnchor),
            button.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
        button.addGestureRecognizer(longPressGesture!)
    }
    
    @objc func nextItemAction() -> Bool {
        return delegate?.nextItemAction(for: self) ?? false
    }
    
    @objc func previousItemAction() -> Bool {
        return delegate?.previousItemAction(for: self) ?? false
    }
    
    @objc func deleteItemAction() -> Bool {
        return delegate?.deleteItemAction(for: self) ?? false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
                if UIAccessibility.isVoiceOverRunning {
                    let sourceIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView))
                    let destinationIndexPath = delegate?.indexPath
                    
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
                        
                            // Anuncie a mudança para o VoiceOver
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
            
            
        default:
            if let collectionView = superview as? UICollectionView {
                collectionView.cancelInteractiveMovement()
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        updateAccessibilityActions()
    }
    
    func updateAccessibilityActions() {
        guard let indexPath = delegate?.indexPath(for: self) else { return }
        
        let isFirstItem = indexPath.item == 0
        let isLastItem = indexPath.item == (delegate?.numberOfItems(inSection: indexPath.section))! - 1
        
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
        button.isAccessibilityElement = true
        button.accessibilityCustomActions = customActions
        button.accessibilityTraits = [.button, .allowsDirectInteraction]
        button.accessibilityHint = "Toque duas vezes e segure,aguarde o aviso sonoro e depois arraste para reorganizar."
        
        UIAccessibility.post(notification: .layoutChanged, argument: button)
        
    }
}
