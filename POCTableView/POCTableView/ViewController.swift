//
//  ViewController.swift
//  POCTableView
//
//  Created by Andre Firmo on 27/03/23.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func goToComponent(_ sender: Any) {
        self.navigationController?.pushViewController(PocVC(), animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func goToCollection(_ sender: Any) {
        self.navigationController?.pushViewController(CardViewController(), animated: true)
    }
    
    @IBAction func goToCustomizeCollection(_ sender: Any) {
        self.navigationController?.pushViewController(CustomizeViewController(), animated: true)
    }
}

class testVC: UIViewController, ReorderableTableViewDelegate {
    func reorderableTableView(_ tableView: ReorderableTableView, didDeleteItem item: String) {
        print(item)
    }

    private lazy var tableView: ReorderableTableView = {
        let tab = ReorderableTableView(frame: .zero)
        tab.translatesAutoresizingMaskIntoConstraints = false
        tab.reorderDelegate = self
        tab.items = ["1", "2"]
        return tab
    }()

    override func viewDidLoad() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}

class CardViewController: UIViewController, ContainerViewDelegate {
    func containerView(_ containerView: ContainerView, didDeleteItem: CardInformation) {
        mainCardCollection.didInsert(item: didDeleteItem)
    }
    
    
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

    private lazy var mainCardCollection: CardCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        let card = CardCollectionView(collectionViewLayout: flowLayout, isDragDropAvailable: true)
        card.items = self.cardItems
        card.cardDataSource = self
        return card
    }()
    
    private lazy var containerView: ContainerView = {
       let view = ContainerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        view.addSubview(mainCardCollection)
        view.addSubview(containerView)
        NSLayoutConstraint.activate([
            mainCardCollection.topAnchor.constraint(equalTo: view.topAnchor),
            mainCardCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainCardCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainCardCollection.heightAnchor.constraint(equalToConstant: 300),
            containerView.bottomAnchor.constraint(equalTo: mainCardCollection.bottomAnchor, constant: 15),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            containerView.heightAnchor.constraint(equalToConstant: 250)
            
        ])
    }
}

extension CardViewController: CardCollectionViewDataSource {
    func cardCollectionView(_ cardCollectionView: CardCollectionView, didDeleteItem: CardInformation) {
        var newItem = didDeleteItem
        newItem.isInsertAvailable = true
        newItem.isDeleteAvailable = false
        containerView.cardCollection.didInsert(item: newItem)
    }
}

final class ContainerView: UIView, CardCollectionViewDataSource {
    var delegate: ContainerViewDelegate?
    
    lazy var cardCollection: CardCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        let card = CardCollectionView(collectionViewLayout: flowLayout, isDragDropAvailable: false)
        card.cardDataSource = self
        return card
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(cardCollection)
        NSLayoutConstraint.activate([
            cardCollection.topAnchor.constraint(equalTo: topAnchor),
            cardCollection.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardCollection.trailingAnchor.constraint(equalTo: trailingAnchor),
            cardCollection.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 15),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func cardCollectionView(_ cardCollectionView: CardCollectionView, didDeleteItem: CardInformation) {
        let newItem = didDeleteItem
        newItem.isInsertAvailable = false
        newItem.isDeleteAvailable = true
        delegate?.containerView(self, didDeleteItem: newItem)
    }
}

protocol ContainerViewDelegate: AnyObject {
    func containerView(_ containerView: ContainerView, didDeleteItem: CardInformation)
}
