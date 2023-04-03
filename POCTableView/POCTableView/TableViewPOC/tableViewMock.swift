import UIKit

protocol ReorderableTableViewDelegate: AnyObject {
    func reorderableTableView(_ tableView: ReorderableTableView, didDeleteItem item: String)
}

class ReorderableTableView: UITableView, UITableViewDelegate, UITableViewDataSource, UITableViewDragDelegate, UITableViewDropDelegate, CustomTableViewCellDelegate {

    weak var reorderDelegate: ReorderableTableViewDelegate?

    var items: [String] = []

    var deletedItem: String?

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setupTableView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTableView()
    }

    private func setupTableView() {
        delegate = self
        dataSource = self
        dragDelegate = self
        dropDelegate = self
        dragInteractionEnabled = true
        register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? CustomTableViewCell else {
            return UITableViewCell(style: .default, reuseIdentifier: "err")
        }
        cell.setup(title: items[indexPath.row])
        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        104
    }

    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        if tableView.numberOfRows(inSection: 0) > 1 {
            let item = items[indexPath.row]
            let itemProvider = NSItemProvider(object: item as NSString)
            let dragItem = UIDragItem(itemProvider: itemProvider)
            dragItem.localObject = item
            return [dragItem]
        } else {
            return []
        }
        
    }
    
    // MARK: - UITableViewDropDelegate
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        if let destinationIndexPath = coordinator.destinationIndexPath {
            reorderItems(tableView: tableView, coordinator: coordinator, destinationIndexPath: destinationIndexPath)
        } else {
            let indexPath = IndexPath(row: items.count, section: 0)
            reorderItems(tableView: tableView, coordinator: coordinator, destinationIndexPath: indexPath)
        }
    }
    
    private func reorderItems(tableView: UITableView ,coordinator: UITableViewDropCoordinator, destinationIndexPath: IndexPath) {
        if let item = coordinator.items.first, let sourceIndexPath = item.sourceIndexPath {
            tableView.performBatchUpdates({
                items.remove(at: sourceIndexPath.row)
                items.insert(item.dragItem.localObject as! String, at: destinationIndexPath.row)
                tableView.deleteRows(at: [sourceIndexPath], with: UITableView.RowAnimation.automatic)
                tableView.insertRows(at: [destinationIndexPath], with: UITableView.RowAnimation.automatic)
            }, completion: { _ in })
            
            coordinator.drop(item.dragItem, toRowAt: destinationIndexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        if tableView.hasActiveDrag {
            return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UITableViewDropProposal(operation: .forbidden)
    }
    
    func dragButtonTapped(in tableView: UITableView, at indexPath: IndexPath) {
//        guard let cell = tableView.cellForRow(at: indexPath) as? CustomTableViewCell else { return }
//        let locationInCell = tableView.convert(tableView.rectForRow(at: indexPath).origin, to: cell)
//        let dragPoint = CGPoint(x: cell.dragButton.frame.midX, y: cell.dragButton.frame.midY)
//        let locationInView = CGPoint(x: locationInCell.x + dragPoint.x, y: locationInCell.y + dragPoint.y)
        
    }
    
    func dragItemForCell(in tableView: UITableView, at indexPath: IndexPath) -> UIDragItem? {
        if tableView.numberOfRows(inSection: 0) > 1 {
            let item = items[indexPath.row]
            let itemProvider = NSItemProvider(object: item as NSString)
            let dragItem = UIDragItem(itemProvider: itemProvider)
            dragItem.localObject = item
            return dragItem
        } else {
            // Não inicie o arrastar e soltar se houver apenas um item
            return nil
        }
    }
}
