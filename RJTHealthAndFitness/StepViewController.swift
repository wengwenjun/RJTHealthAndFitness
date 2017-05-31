//
//  StepViewController.swift
//  RJTHealthAndFitness
//
//  Created by Wenjun Weng on 5/23/17.
//  Copyright © 2017 rjt.compquest. All rights reserved.
//

import UIKit
import UICircularProgressRing
import CoreData
import FBSDKLoginKit
import FBSDKShareKit
import Firebase
import FBSDKShareKit

class StepViewController: UIViewController,CentralDelegate {

    @IBOutlet weak var currentStep: UILabel!
    @IBOutlet weak var currentCalories: UILabel!
    @IBOutlet weak var currentMile: UILabel!
    @IBOutlet weak var stepProgress: UICircularProgressRingView!
    @IBOutlet weak var calProgress: UICircularProgressRingView!
    @IBOutlet weak var distanceProgress: UICircularProgressRingView!
    var stepCount: String?
    var entities = [Entity]()
    var currentFitness = Entity()
    var totalStep: String?
    var ref: DatabaseReference!
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        //loadData()
        stepProgress.maxValue = 100.00
        calProgress.maxValue = 100.00
        distanceProgress.maxValue = 100.00
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = true
        loadData()
        Singleton.shareInstance.bluetoothDelegate = self
    }
    
    //load core data
    func loadData(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        print(NSHomeDirectory())
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
                //let e = entities.last
                print(entities.count)
                //print(e.step!)
                //print(e.date!)
                //print(e.distance!)
                //print(e.calories!)
                //print(e.bodyTempature!)
                currentFitness = entities.last!
                currentStep.text = currentFitness.step
                currentCalories.text = currentFitness.calories
                currentMile.text = currentFitness.distance
                let progressValue = CGFloat(Double(currentStep.text!)! / 100)
                if progressValue < 100.00{
                stepProgress.setProgress(value: progressValue, animationDuration: 2.0)
                }else {
                stepProgress.setProgress(value: 100.00, animationDuration: 2.0)
                }
                let calProgressVal = CGFloat(Double(currentCalories.text!)! / 20)
                calProgress.setProgress(value: calProgressVal, animationDuration: 2.0)
                
                let distanceProgressVal = CGFloat(Double(currentMile.text!)! * 20)
                distanceProgress.setProgress(value: distanceProgressVal, animationDuration: 2.0)
                
            }
        } catch {
            print("Could not fetch the data")
            
        }
    
    }
    //init core data
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
    //insertData
    func insertData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity =
            NSEntityDescription.entity(forEntityName: "Entity",
                                       in: managedContext)!
        
        let fitnessObj = NSManagedObject(entity: entity,
                                         insertInto: managedContext)
        fitnessObj.setValue(self.currentStep.text, forKeyPath: "step")
        let date = Date()
        fitnessObj.setValue(date, forKey: "date")
        do {
            try managedContext.save()
            //entities.append(fitnessObj as! Entity)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func refreshBtnClicked(_ sender: Any) {
       // stepProgress.setProgress(value: CGFloat(Double(str)!), animationDuration: 2.0)
        Singleton.shareInstance.getSteps()
    }
    func showHearBeat(heartBeatString : String){
       
    }
    func showStepsCount(stepsCountString : String){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        currentStep.text = stepsCountString
        totalStep = currentFitness.step!
        let totalInt = Double(totalStep!)!
        let currentInt = Double(currentStep.text!)!
        let total = totalInt + currentInt
        let totalCalories = total * 0.04
        let totalDistance = total * 0.0004
        currentFitness.step = String(total)
        currentFitness.calories = String(format: "%.2f",totalCalories)
        currentFitness.distance = String(format: "%.2f",totalDistance)
        currentStep.text = String(total)
        currentCalories.text = currentFitness.calories
        currentMile.text = currentFitness.distance
        //save it to firebase
        let data = currentFitness.date as Date?
        let dataString =  data?.MonthDayDateFormatter()
        let userid = Auth.auth().currentUser?.uid
        if let step = currentFitness.step, let calories = currentFitness.calories, let distance = currentFitness.distance, let tempature = currentFitness.bodyTempature{
            self.ref.child("posts").child(userid!).child(dataString!).updateChildValues(["steps": step, "calories": calories, "distance": distance, "tempature": tempature])
        }else {
            
            print("error")
        }
        if total < 10000{
            let progressValue = CGFloat(Double(currentStep.text!)! / 100)
            stepProgress.setProgress(value: progressValue, animationDuration: 2.0)
        }else{
            stepProgress.setProgress(value: 100.00, animationDuration: 2.0)
            let alert = UIAlertController(title: "Congrats!", message: "You have reached your daily goal! Post on facebook and share with your friends!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title:"Cancel",style:UIAlertActionStyle.cancel,handler:{
                (action) in print ("action")
            }))
            alert.addAction(UIAlertAction(title:"Post",style:UIAlertActionStyle.default,handler:{
                (action) in self.shareToFacebook()
            }))
            self.present(alert, animated: true, completion: nil)
            
        }
        let calProgressVal = CGFloat(Double(currentCalories.text!)! / 20)
        calProgress.setProgress(value: calProgressVal, animationDuration: 2.0)
        
        let distanceProgressVal = CGFloat(Double(currentMile.text!)! * 20)
        distanceProgress.setProgress(value: distanceProgressVal, animationDuration: 2.0)
        do {
            try managedContext.save()
            //entities.append(fitnessObj as! Entity)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func showBodyTemperature(bodyTemperatureString : String){
        //self.bodyTempature.text = bodyTemperatureString
    }
   
    func shareToFacebook(){
        if((FBSDKAccessToken.current()) != nil){
           //postToFacebok()
            FacebookPost()
        }else{
        FBSDKLoginManager().logIn(withPublishPermissions: ["publish_actions"], from: self) { (result, err) in
                if err != nil{
                print("Facebook login Failed- ", err!.localizedDescription)
                }else{
                print("Facebook login Successful")
                //self.postToFacebok()
                self.FacebookPost()
                }
            }
        }
    }
    func FacebookPost(){
        guard let screenShot = renderImageFromMap(view: self.view, frame: self.view.frame) else{
            return
        }
        //shareNotified = true
        let fbsdkPhoto = FBSDKSharePhoto(image: screenShot, userGenerated: true)
        let fbsdkPhotoContent = FBSDKSharePhotoContent()
        fbsdkPhotoContent.photos = [fbsdkPhoto!]
        FBSDKShareDialog.show(from: self, with: fbsdkPhotoContent, delegate: nil)
    }
    func renderImageFromMap(view:UIView, frame:CGRect) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(frame.size,true,0)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        view.layer.render(in: context)
        view.draw(frame)
        let renderedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return renderedImage
    }

    func postToFacebok(){
        var params =  Dictionary<AnyHashable, Any>()
        params["message"] = "I have reached my 10000 steps daily goal!"
        FBSDKGraphRequest(graphPath: "/me/feed", parameters: params, httpMethod: "POST").start {(connection, result, error) in
            if error == nil{
                print("success")
            }else {
                print(error?.localizedDescription ?? "")
            }
        }
    }
    //clear core data
    func clearCoreData(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Entity")
        do
        {
            let results = try managedContext.fetch(fetchRequest)
            for managedObject in results
            {
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                managedContext.delete(managedObjectData)
            }
        } catch _ as NSError {
            print("error")
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
