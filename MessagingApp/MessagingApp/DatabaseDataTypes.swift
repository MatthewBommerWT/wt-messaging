//
//  ResultsDataTypes.swift
//  MessagingApp
//
//  Created by Matt Bommer on 3/12/21.
//

import Foundation

struct Message: Codable, Hashable {
    let author: String
    let message: String
    let timestamp: Int
}

struct User: Codable, Hashable {
    let conversations: [String: String]
}

struct Conversation: Hashable {
    let identifier: String
    let participant: String
}
