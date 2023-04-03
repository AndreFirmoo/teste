//
//  CardInformation.swift
//  POCTableView
//
//  Created by Andre Firmo on 29/03/23.
//

import Foundation

final class CardInformation: NSObject {
    let nameCard: String
    let nameIconBadge: String
    let nameIconDelete: String
    var isDeleteAvailable: Bool
    var isInsertAvailable: Bool
    
    init(nameCard: String, nameIconBadge: String, nameIconDelete: String, isDeleteAvailable: Bool, isInsertAvailable: Bool) {
        self.nameCard = nameCard
        self.nameIconBadge = nameIconBadge
        self.nameIconDelete = nameIconDelete
        self.isDeleteAvailable = isDeleteAvailable
        self.isInsertAvailable = isInsertAvailable
    }
}

extension CardInformation: NSItemProviderWriting {
    static var writableTypeIdentifiersForItemProvider: [String] {
        ["CardInformation"]
    }
    
    func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        return nil
    }
}
