//
//  HeartRateViewController.swift
//  RJTHealthAndFitness
//
//  Created by Wenjun Weng on 5/22/17.
//  Copyright © 2017 rjt.compquest. All rights reserved.
//

import UIKit
import CoreBluetooth

class HeartRateViewController: UIViewController,CentralDelegate{
    
    @IBOutlet weak var heartImage: UIImageView!
    @IBOutlet weak var hearRate: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        Singleton.shareInstance.bluetoothDelegate = self
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = true
        Singleton.shareInstance.bluetoothDelegate = self
        animationImage()
    }
    func animationImage() {
        UIView.animate(withDuration: 1.0, animations: {
            self.heartImage?.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }, completion: {(_ finished: Bool) -> Void in
            UIView.animate(withDuration: 1.0, animations: {
                self.heartImage?.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: { (finish) in
                if finish{
                    self.animationImage()
                }
                
            })
        })
    }
    func showHearBeat(heartBeatString : String){
        self.hearRate.text = heartBeatString
    }
    func showStepsCount(stepsCountString : String){
        //self.stepCount.text = stepsCountString
    }
    func showBodyTemperature(bodyTemperatureString : String){
        //self.bodyTempature.text = bodyTemperatureString
    }

  //  @IBAction func Refresh(_ sender: Any) {
       // Singleton.shareInstance.getSteps()
        //Singleton.shareInstance.getTemperature()
    //}
  
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
