//
//  Item.swift
//  ToDoList
//
//  Created by Ярослав on 07.01.2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
