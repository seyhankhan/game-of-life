//
//  Configuration.swift
//  Lecture11
//
//  Created by Van Simmons on 7/29/19.
//  Copyright © 2019 ComputeCycles, LLC. All rights reserved.
//

import Foundation

struct Configuration : Codable {
    static let ConfigurationURL = URL(string: "https://www.dropbox.com/s/i4gp5ih4tfq3bve/S65g.json?dl=1")!
    typealias CompletionHandler = (Result<[Configuration],String>) -> Void
    
    let title : String?
    let contents: [[Int]]?
    
    private enum CodingKeys : String, CodingKey {
        case title = "title"
        case contents = "contents"
    }
}
