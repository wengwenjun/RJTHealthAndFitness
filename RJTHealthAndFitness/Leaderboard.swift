//
//  Leaderboard.swift
//  RJTHealthAndFitness
//
//  Created by Wenjun Weng on 5/29/17.
//  Copyright © 2017 rjt.compquest. All rights reserved.
//

import UIKit

class Leaderboard: NSObject {
    var id : String?
    var step : Int?
    
    init(id : String?, s: Int?){
        self.id = id
        self.step = s
    }
}
