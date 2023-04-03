//
//  CustomTableViewCell.swift
//  POCTableView
//
//  Created by Andre Firmo on 27/03/23.
//



import UIKit

protocol CustomTableViewCellDelegate: AnyObject {
    func dragButtonTapped(in tableView: UITableView, at indexPath: IndexPath)
    func dragItemForCell(in tableView: UITableView, at indexPath: IndexPath) -> UIDragItem?

}
class CustomTableViewCell: UITableViewCell, UIDragInteractionDelegate {
    
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "HelveticaNeue-Light", size: 25.0)
        label.textColor = .black
        return label
    }()
    
    let dragButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Drag", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
  
    weak var delegate: CustomTableViewCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
        contentView.addSubview(dragButton)
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            dragButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            dragButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
        ])
        
        let dragInteraction = UIDragInteraction(delegate: self)
        dragButton.addInteraction(dragInteraction)
        dragButton.addTarget(self, action: #selector(dragButtonTapped), for: .touchUpInside)
    }
    
    
    @objc private func dragButtonTapped() {
        if let tableView = superview as? UITableView, let indexPath = tableView.indexPath(for: self) {
            delegate?.dragButtonTapped(in: tableView, at: indexPath)
        }
    }

    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        guard let tableView = superview as? UITableView, let indexPath = tableView.indexPath(for: self), let dragItem = delegate?.dragItemForCell(in: tableView, at: indexPath) else { return [] }
        return [dragItem]
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, previewForLifting item: UIDragItem, session: UIDragSession) -> UITargetedDragPreview? {
        guard let tableView = superview as? UITableView, let indexPath = tableView.indexPath(for: self), let cell = tableView.cellForRow(at: indexPath) else { return nil }
        
        let previewParameters = UIDragPreviewParameters()
        previewParameters.visiblePath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: 10)
        
        let target = UIDragPreviewTarget(container: tableView, center: cell.center)
        return UITargetedDragPreview(view: cell.contentView.snapshotView(afterScreenUpdates: true)!, parameters: previewParameters, target: target)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    func setup(title: String) {
        self.titleLabel.text = title
    }
}
