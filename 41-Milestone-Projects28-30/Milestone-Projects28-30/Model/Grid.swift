//
//  Grid.swift
//  Milestone-Projects28-30
//
//  Created by clarknt on 2019-08-04.
//  Copyright © 2019 clarknt. All rights reserved.
//

import Foundation

class Grid {
    var numberOfElements: Int
    
    var combinations: [(Int, Int)]
 
    init(numberOfElements: Int, combinations: [(Int, Int)]) {
        self.numberOfElements = numberOfElements
        self.combinations = combinations
    }
}
