//
//  BodyTempatureViewController.swift
//  RJTHealthAndFitness
//
//  Created by Wenjun Weng on 5/25/17.
//  Copyright © 2017 rjt.compquest. All rights reserved.
//

import UIKit
import CoreData


class BodyTempatureViewController: BaseViewController,CentralDelegate {

    @IBOutlet weak var bodyTempLabel: UILabel!
    var entities = [Entity]()
    var currentFitness = Entity()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = true
        Singleton.shareInstance.bluetoothDelegate = self
        loadData()
    }
    func loadData(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        //print(NSHomeDirectory())
        // Get the current calendar with local time zone
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Entity")
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        // Get today's beginning & end
        let dateFrom = calendar.startOfDay(for: Date()) // eg. 2016-10-10 00:00:00
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute],from: dateFrom)
        components.day! += 1
        let dateTo = calendar.date(from: components)! // eg. 2016-10-11 00:00:00
        // Note: Times are printed in UTC. Depending on where you live it won't print 00:00:00 but it will work with UTC times which can be converted to local time
        // Set predicate as date being today's date
        print(dateTo)
        let datePredicate = NSPredicate(format: "(%@ <= date) AND (date < %@)", argumentArray: [dateFrom, dateTo])
        fetchRequest.predicate = datePredicate
        //clearCoreData()
        do {
            print("Fetch the data")
            entities = try managedContext.fetch(fetchRequest) as! [Entity]
            
            if(entities.isEmpty){
                print("entity is empty")
                initData()
            }
            else{
                let e = entities.last
                //print(entities.count)
                //print(e.step!)
                //print(e.date!)
                //print(e.distance!)
                //print(e.calories!)
                currentFitness = entities.last!
                self.bodyTempLabel.text = currentFitness.bodyTempature
            }
        } catch {
            print("Could not fetch the data")
            
        }
        
    }
    func initData(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity =
            NSEntityDescription.entity(forEntityName: "Entity",
                                       in: managedContext)!
        
        let fitnessObj = NSManagedObject(entity: entity,
                                         insertInto: managedContext)
        let date = Date()
        fitnessObj.setValue(date, forKey: "date")
        fitnessObj.setValue("0", forKey: "step")
        fitnessObj.setValue("0", forKey: "calories")
        fitnessObj.setValue("0", forKey: "distance")
        fitnessObj.setValue("0", forKey: "bodyTempature")
        do {
            try managedContext.save()
            //entities.append(fitnessObj as! Entity)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

    @IBAction func refresh(_ sender: Any) {
        Singleton.shareInstance.getTemperature()
    }
    func showHearBeat(heartBeatString : String){

    }
    func showStepsCount(stepsCountString : String){
        
    }
    func showBodyTemperature(bodyTemperatureString : String){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        self.bodyTempLabel.text = bodyTemperatureString
        currentFitness.bodyTempature = self.bodyTempLabel.text!
        do {
            try managedContext.save()
            //entities.append(fitnessObj as! Entity)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
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
