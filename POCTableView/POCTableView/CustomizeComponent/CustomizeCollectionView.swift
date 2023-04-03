//
//  CustomizeCollectionView.swift
//  POCTableView
//
//  Created by Andre Firmo on 02/04/23.
//

import UIKit

final class CustomizeCollectionView: UICollectionView {
    var items: [CardInformation] = []
    var isReoderAvailable: Bool = false
    var collectionViewCell: UICollectionViewCell.Type = UICollectionViewCell.self
    var indexPath: IndexPath? {
        guard let cell = visibleCells.first(where: { ($0 as? CustomizeCollectionViewCell)?.accessibilityDelegate === self }) else {
            return nil
        }
        return indexPathForItem(at: convert(cell.center, from: cell.superview))
    }
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setupCollectionView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(
        collectionViewLayout: UICollectionViewLayout,
        collectionViewCell: UICollectionViewCell.Type,
        isReoderAvailable: Bool = false
    ) {
        self.init(frame: .zero, collectionViewLayout: collectionViewLayout)
        self.isReoderAvailable = isReoderAvailable
        self.collectionViewCell = collectionViewCell
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        delegate = self
        dataSource = self
        translatesAutoresizingMaskIntoConstraints = false
        register(collectionViewCell, forCellWithReuseIdentifier: "custom")
    }
}

extension CustomizeCollectionView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
}

extension CustomizeCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "custom", for: indexPath) as? CustomizeCollectionViewCell else {
            return UICollectionViewCell()
        }
        let items = items[indexPath.item]
        cell.accessibilityDelegate = self
        cell.setup(cell: items)
        DispatchQueue.main.async {
            cell.updateAccessibilityActionsForReoderButton()
        }
        return cell 
        
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        if items.count <= 1 || isReoderAvailable {
            return []
        }
        
        let item = items[indexPath.item]
        let itemProvider = NSItemProvider(object: item)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = items.remove(at: sourceIndexPath.item)
        items.insert(item, at: destinationIndexPath.item)
    }
}

extension CustomizeCollectionView: CustomizeCellAccessibility {
    func indexPaths(for cell: CustomizeCollectionViewCell) -> IndexPath? {
        guard let indexPath = self.indexPath(for: cell) else {
            return nil
        }
        return indexPath
    }
    
    func nextItemAction(for cell: CustomizeCollectionViewCell) -> Bool {
        guard let indexPath = indexPath(for: cell) else { return false }
        if indexPath.item < numberOfItems(inSection: indexPath.section) - 1 {
            let nextIndexPath = IndexPath(item: indexPath.item + 1, section: indexPath.section)
            let item = items.remove(at: indexPath.item)
            items.insert(item, at: nextIndexPath.item)
            performBatchUpdates({
                moveItem(at: indexPath, to: nextIndexPath)
            }, completion: { _ in
                let announcement = "Item \(self.items[indexPath.item].nameCard) foi reordenado com o próximo item \(self.items[nextIndexPath.item].nameCard)."
                UIAccessibility.post(notification: .announcement, argument: announcement)
            })
    
            if let currentCell = cellForItem(at: indexPath) as? CustomizeCollectionViewCell {
                currentCell.updateAccessibilityActionsForReoderButton()
            }
            if let nextCell = cellForItem(at: nextIndexPath) as? CustomizeCollectionViewCell {
                nextCell.updateAccessibilityActionsForReoderButton()
            }
            
            return true
        }
        return false
    }
    
    func previousItemAction(for cell: CustomizeCollectionViewCell) -> Bool {
        guard let indexPath = indexPath(for: cell) else { return false }
        if indexPath.item > 0 {
            let previousIndexPath = IndexPath(item: indexPath.item - 1, section: indexPath.section)
            
            let item = items.remove(at: indexPath.item)
            items.insert(item, at: previousIndexPath.item)
            performBatchUpdates({
                moveItem(at: indexPath, to: previousIndexPath)
            }, completion: { _ in
                let announcement = "Item \(self.items[indexPath.item].nameCard) foi reordenado com o item anterior \(self.items[previousIndexPath.item].nameCard)."
                UIAccessibility.post(notification: .announcement, argument: announcement)
            })
            
            if let currentCell = cellForItem(at: indexPath) as? CustomizeCollectionViewCell {
                currentCell.updateAccessibilityActionsForReoderButton()
            }
            if let previousCell = cellForItem(at: previousIndexPath) as? CustomizeCollectionViewCell {
                previousCell.updateAccessibilityActionsForReoderButton()
            }
            
            return true
        }
        return false
    }
    
    func deleteItemAction(for cell: CustomizeCollectionViewCell) -> Bool {
        guard let indexPath = indexPath(for: cell) else { return false }
        let announcement = "Item \(self.items[indexPath.item].nameCard) foi removido da lista."
        cell.updateAccessibilityActionsForReoderButton()
        items.remove(at: indexPath.item)
        deleteItems(at: [indexPath])
        return true
        
    }
    
    func itemPosition(for cell: CustomizeCollectionViewCell) -> (isFirst: Bool, isLast: Bool) {
        guard let indexPath = indexPath(for: cell) else {
            return (isFirst: false, isLast: false)
        }
        
        let isFirstItem = indexPath.item == 0
        let isLastItem = indexPath.item == numberOfItems(inSection: indexPath.section) - 1
        
        return (isFirst: isFirstItem, isLast: isLastItem)
    }
}
