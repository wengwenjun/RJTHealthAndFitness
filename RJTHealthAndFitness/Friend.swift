//
//  Friend.swift
//  RJTHealthAndFitness
//
//  Created by Wenjun Weng on 5/29/17.
//  Copyright © 2017 rjt.compquest. All rights reserved.
//

import UIKit

class Friend: NSObject {
    var id : String?
    var name : String?
    var photo: String?
    
    
    init(id : String?, n: String?, p: String?){
       self.id = id
       self.name = n
       self.photo = p
       
    }
}
