//
//  TodosModel.swift
//  test-SwiftUI-3
//
//  Created by Viktor Kushnerov on 7/10/19.
//  Copyright © 2019 Viktor Kushnerov. All rights reserved.
//

import SwiftUI

public struct TodoModel: Codable, Identifiable {
    public let userID: Int
    public let id: Int
    public let title: String
    public var completed: Bool
    
    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case id = "id"
        case title = "title"
        case completed = "completed"
    }
}

public typealias TodosModel = [TodoModel]
