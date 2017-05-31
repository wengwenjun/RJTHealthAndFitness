//
//  TabbarViewController.swift
//  RJTHealthAndFitness
//
//  Created by Wenjun Weng on 5/22/17.
//  Copyright © 2017 rjt.compquest. All rights reserved.
//

import UIKit

class TabbarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabbar()
        // Do any additional setup after loading the view.
    }
    
    func configureTabbar() {
        tabBar.alpha = 1.0
        let tabBarCount = tabBar.items?.count
        for i in 0..<tabBarCount!{
            let item = tabBar.items?[i]
            if i == 0{
                
                item?.image = #imageLiteral(resourceName: "Health icon-1").withRenderingMode(UIImageRenderingMode.alwaysOriginal)
                item?.selectedImage = #imageLiteral(resourceName: "Health icon").withRenderingMode(UIImageRenderingMode.alwaysOriginal)
            }
            if i == 1{
                
                item?.image = #imageLiteral(resourceName: "Health icon-1").withRenderingMode(UIImageRenderingMode.alwaysOriginal)
                item?.selectedImage = #imageLiteral(resourceName: "Health icon").withRenderingMode(UIImageRenderingMode.alwaysOriginal)
            }
            if i == 2{
                
                item?.image = #imageLiteral(resourceName: "Health icon-1").withRenderingMode(UIImageRenderingMode.alwaysOriginal)
                item?.selectedImage = #imageLiteral(resourceName: "Health icon").withRenderingMode(UIImageRenderingMode.alwaysOriginal)
            }
            if i == 3{
                
                item?.image = #imageLiteral(resourceName: "Health icon-1").withRenderingMode(UIImageRenderingMode.alwaysOriginal)
                item?.selectedImage = #imageLiteral(resourceName: "Health icon").withRenderingMode(UIImageRenderingMode.alwaysOriginal)
            }
            if i == 4{
                item?.image = #imageLiteral(resourceName: "Health icon-1").withRenderingMode(UIImageRenderingMode.alwaysOriginal)
                item?.selectedImage = #imageLiteral(resourceName: "Health icon").withRenderingMode(UIImageRenderingMode.alwaysOriginal)
            }
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
