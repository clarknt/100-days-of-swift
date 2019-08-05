//
//  Grids.swift
//  Milestone-Projects28-30
//
//  Created by clarknt on 2019-08-04.
//  Copyright © 2019 clarknt. All rights reserved.
//

import Foundation

class Grids {
    var grids: [Grid]
    
    init() {
        grids = [Grid]()
        grids.append(Grid(numberOfElements: 4, combinations: [(1, 4),  (2, 2)]))
        grids.append(Grid(numberOfElements: 6, combinations: [(1, 6),  (2, 3)]))
        grids.append(Grid(numberOfElements: 8, combinations: [(1, 8),  (2, 4)]))
        grids.append(Grid(numberOfElements: 10, combinations: [(1, 10), (2, 5)]))
        grids.append(Grid(numberOfElements: 12, combinations: [(2, 6),  (3, 4)]))
        grids.append(Grid(numberOfElements: 14, combinations: [(2, 7)]))
        grids.append(Grid(numberOfElements: 16, combinations: [(2, 8),  (4, 4)]))
        grids.append(Grid(numberOfElements: 18, combinations: [(2, 9),  (3, 6)]))
        grids.append(Grid(numberOfElements: 20, combinations: [(2, 10), (4, 5)]))
        grids.append(Grid(numberOfElements: 24, combinations: [(3, 8),  (4, 6)]))
        grids.append(Grid(numberOfElements: 28, combinations: [(4, 7)]))
        grids.append(Grid(numberOfElements: 30, combinations: [(3, 10), (6, 5)]))
        grids.append(Grid(numberOfElements: 32, combinations: [(4, 8)]))
        grids.append(Grid(numberOfElements: 36, combinations: [(4, 9),  (6, 6)]))
        grids.append(Grid(numberOfElements: 40, combinations: [(4, 10), (5, 8)]))
        grids.append(Grid(numberOfElements: 42, combinations: [(6, 7)]))
        grids.append(Grid(numberOfElements: 48, combinations: [(6, 8)]))
        grids.append(Grid(numberOfElements: 50, combinations: [(5, 10)]))
        grids.append(Grid(numberOfElements: 54, combinations: [(6, 9),  (7, 8)]))
        grids.append(Grid(numberOfElements: 60, combinations: [(6, 10)]))
        grids.append(Grid(numberOfElements: 64, combinations: [(8, 8)]))
        grids.append(Grid(numberOfElements: 70, combinations: [(7, 10)]))
        grids.append(Grid(numberOfElements: 72, combinations: [(8, 9)]))
        grids.append(Grid(numberOfElements: 80, combinations: [(8, 10)]))
        grids.append(Grid(numberOfElements: 90, combinations: [(9, 10)]))
        grids.append(Grid(numberOfElements: 100, combinations: [(10, 10)]))
    }
}
