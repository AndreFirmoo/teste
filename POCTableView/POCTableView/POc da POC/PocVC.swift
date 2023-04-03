//
//  PocVC.swift
//  POCTableView
//
//  Created by Andre Firmo on 01/04/23.
//

import Foundation
import UIKit

class PocVC: UIViewController {
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    var items = ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5"]
    
    var indexPath: IndexPath? {
        guard let cell = collectionView.visibleCells.first(where: { ($0 as? MyCollectionViewCell)?.delegate === self }) else {
            return nil
        }
        return collectionView.indexPathForItem(at: collectionView.convert(cell.center, from: cell.superview))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(MyCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension PocVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: view.frame.width, height: 50)
    }
}

extension PocVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! MyCollectionViewCell
        cell.backgroundColor = .lightGray
        cell.button.setTitle("Drag Button \(indexPath.item)", for: .normal)
        cell.delegate = self
        DispatchQueue.main.async {
            cell.updateAccessibilityActions()
        }
        
        cell.button.accessibilityLabel = "Botão de arrastar \(indexPath.item)"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let itemProvider = NSItemProvider(object: items[indexPath.item] as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = items.remove(at: sourceIndexPath.item)
        items.insert(item, at: destinationIndexPath.item)
    }
}

extension PocVC: MyCollectionViewCellDelegate {
    func nextItemAction(for cell: MyCollectionViewCell) -> Bool {
        guard let indexPath = collectionView.indexPath(for: cell) else { return false }
        if indexPath.item < collectionView.numberOfItems(inSection: indexPath.section) - 1 {
            let nextIndexPath = IndexPath(item: indexPath.item + 1, section: indexPath.section)
            
                // Adicione o código de reordenamento aqui:
            let item = items.remove(at: indexPath.item)
            items.insert(item, at: nextIndexPath.item)
            collectionView.performBatchUpdates({
                collectionView.moveItem(at: indexPath, to: nextIndexPath)
            }, completion: { _ in
                    // Anuncie a mudança para o VoiceOver
                let announcement = "Item \(indexPath.item) foi reordenado com o próximo item \(nextIndexPath.item)."
                UIAccessibility.post(notification: .announcement, argument: announcement)
            })
            
                // Atualize as ações de acessibilidade das células afetadas
            if let currentCell = collectionView.cellForItem(at: indexPath) as? MyCollectionViewCell {
                currentCell.updateAccessibilityActions()
            }
            if let nextCell = collectionView.cellForItem(at: nextIndexPath) as? MyCollectionViewCell {
                nextCell.updateAccessibilityActions()
            }
            
            return true
        }
        return false
    }
    
    func previousItemAction(for cell: MyCollectionViewCell) -> Bool {
        guard let indexPath = collectionView.indexPath(for: cell) else { return false }
        if indexPath.item > 0 {
            let previousIndexPath = IndexPath(item: indexPath.item - 1, section: indexPath.section)
            
            let item = items.remove(at: indexPath.item)
            items.insert(item, at: previousIndexPath.item)
            collectionView.performBatchUpdates({
                collectionView.moveItem(at: indexPath, to: previousIndexPath)
            }, completion: { _ in
                    // Anuncie a mudança para o VoiceOver
                let announcement = "Item \(indexPath.item) foi reordenado com o item anterior \(previousIndexPath.item)."
                UIAccessibility.post(notification: .announcement, argument: announcement)
            })
            
            if let currentCell = collectionView.cellForItem(at: indexPath) as? MyCollectionViewCell {
                currentCell.updateAccessibilityActions()
            }
            if let previousCell = collectionView.cellForItem(at: previousIndexPath) as? MyCollectionViewCell {
                previousCell.updateAccessibilityActions()
            }
            
            return true
        }
        return false
    }
    
    func deleteItemAction(for cell: MyCollectionViewCell) -> Bool {
        guard let indexPath = collectionView.indexPath(for: cell) else { return false }
        items.remove(at: indexPath.item)
        collectionView.deleteItems(at: [indexPath])
        return true
    }
    
    func itemPosition(for cell: MyCollectionViewCell) -> (isFirst: Bool, isLast: Bool) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return (isFirst: false, isLast: false)
        }
        
        let isFirstItem = indexPath.item == 0
        let isLastItem = indexPath.item == collectionView.numberOfItems(inSection: indexPath.section) - 1
        
        return (isFirst: isFirstItem, isLast: isLastItem)
    }
    
    func numberOfItems(inSection section: Int) -> Int {
        return collectionView.numberOfItems(inSection: section)
    }
    
    func indexPath(for cell: MyCollectionViewCell) -> IndexPath? {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return nil
        }
        return indexPath
    }
}
