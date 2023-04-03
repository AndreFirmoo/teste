//
//  CardCollectionView.swift
//  POCTableView
//
//  Created by Andre Firmo on 29/03/23.
//

import UIKit

protocol CardCollectionViewDataSource: AnyObject {
    func cardCollectionView(_ cardCollectionView: CardCollectionView, didDeleteItem: CardInformation)
}

final class CardCollectionView: UICollectionView {
    var items: [CardInformation] = []
    var cardDataSource: CardCollectionViewDataSource?
    var isDragDropAvailable: Bool = false
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setupCollectionView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(collectionViewLayout: UICollectionViewLayout, isDragDropAvailable: Bool) {
        self.init(frame: .zero, collectionViewLayout: collectionViewLayout)
        self.isDragDropAvailable = isDragDropAvailable
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        if isDragDropAvailable {
            dragDelegate = self
            dropDelegate = self
            dragInteractionEnabled = true
        }
        delegate = self
        dataSource = self
        translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    @objc private func deleteItem(_ sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint.zero, to: self)
        if let indexPath = indexPathForItem(at: buttonPosition) {
    
            var itemToRemove = items.remove(at: indexPath.item)
            itemToRemove.isInsertAvailable = true
            cardDataSource?.cardCollectionView(self, didDeleteItem: itemToRemove)
            deleteItems(at: [indexPath])
            updateStateButton()
        }
    }
    
    private func updateStateButton() {
        for cell in visibleCells {
            if let cardCell = cell as? CardCollectionViewCell {
                if isDragDropAvailable && items.count > 1 {
                    cardCell.setDeleteAndDragIsAvailable(available: true)
                } else if !isDragDropAvailable && items.count >= 1 {
                    cardCell.setDeleteAndDragIsAvailable(available: true)
                } else {
                    cardCell.setDeleteAndDragIsAvailable(available: false)
                }
            }
        }
    }
    
    func didInsert(item: CardInformation) {
        items.append(item)
        let newIndexPath = IndexPath(item: items.count - 1, section: 0)
        insertItems(at: [newIndexPath])
        updateStateButton()
    }
}

extension CardCollectionView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: frame.width, height: 50)
    }
}

extension CardCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CardCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let item = items[indexPath.item]
        cell.setup(cell: item)
        cell.setTargetForDelete(cardCollectionView: self, #selector(deleteItem))
        return cell
    }
}
extension CardCollectionView: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        if items.count <= 1 {
            return []
        }
        let item = items[indexPath.item]
        let itemProvider = NSItemProvider(object: item)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
    
    
}

extension CardCollectionView: UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if collectionView.hasActiveDrag {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UICollectionViewDropProposal(operation: .forbidden)
    }

    
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            let row = collectionView.numberOfItems(inSection: 0)
            destinationIndexPath = IndexPath(item: row, section: 0)
        }
        
        reorderItems(coordinator: coordinator, destinationIndexPath: destinationIndexPath)
    }
    
    private func reorderItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath) {
        if let item = coordinator.items.first,
           let sourceIndexPath = item.sourceIndexPath {
            if coordinator.proposal.operation == .move {
                performBatchUpdates({
                    items.remove(at: sourceIndexPath.item)
                    if destinationIndexPath.item >= items.count {
                        items.append(item.dragItem.localObject as! CardInformation)
                        insertItems(at: [IndexPath(item: items.count - 1, section: 0)])
                    } else {
                        items.insert(item.dragItem.localObject as! CardInformation, at: destinationIndexPath.item)
                        insertItems(at: [destinationIndexPath])
                    }
                    deleteItems(at: [sourceIndexPath])
                }, completion: { _ in })
                
                coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
            }
        }
    }
}
