//
//  FilterEnum.swift
//  Easy Bridge Tracker
//
//  Created by Morris Richman on 4/3/23.
//

import Foundation

enum BridgesFilter: Hashable {
    case allBridges
    case favorites
    case city(String)
}
