//
//  Includes.swift
//  brain-marks
//
//  Created by Mikaela Caron on 4/20/21.
//

import Foundation

struct Metadata: Codable {
    let previousToken: String?
    let nextToken: String?
    let resultCount: Int
    let newestId: String
    let oldestId: String
}
