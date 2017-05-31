//
//  MaterialView.swift
//  MyJunk
//
//  Created by Ron Ramirez on 8/19/16.
//  Copyright © 2016 Mochi. All rights reserved.
//

import UIKit
class MaterialView: UIView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 3.0
        self.layer.shadowOpacity = 0.8
        self.layer.shadowRadius = 3.0
        
        self.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.layer.shadowColor = UIColor(red: 157.0/255.0, green: 157.0/255.0, blue: 157.0/255.0, alpha: 1.0).cgColor
    }
    
}
