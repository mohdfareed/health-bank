//
//  Item.swift
//  CalorieTracker
//
//  Created by Mohammed Fareed on 2/26/25.
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
