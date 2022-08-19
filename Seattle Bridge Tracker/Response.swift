//
//  Response.swift
//  brain-marks
//
//  Created by Mikaela Caron on 4/20/21.
//

import Foundation

struct Response: Codable {
    let id: String
    let name: String
    let status: String
    let mapsUrl: String
    let address: String
    let latitude: Double
    let longitude: Double
}
