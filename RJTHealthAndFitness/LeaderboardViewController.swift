
//
//  LeaderboardViewController.swift
//  RJTHealthAndFitness
//
//  Created by Wenjun Weng on 5/29/17.
//  Copyright © 2017 rjt.compquest. All rights reserved.
//

import UIKit
import Firebase
class LeaderboardViewController: UIViewController, UITableViewDataSource {
    var ref: DatabaseReference!
    var userList = [Leaderboard]()
    @IBOutlet weak var tblView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        findAllFriends()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func findAllFriends() {
        let currentID = Auth.auth().currentUser?.uid
        let hander1 = self.ref.child("posts")
        let hander2 = self.ref.child("publicUser").child(currentID!).child("friend")
        //store currentuser info and get friendlist
        hander2.observe(DataEventType.value, with: { (snapshot) in
            for child in snapshot.value as! NSDictionary{
              //print(child.key)
                var dict : [String: Any] = [:]
                dict["id"] = child.key as! String
                hander1.observe(DataEventType.value, with: { (snapshot) in
                    for child in snapshot.value as! NSDictionary{
                        let key = child.key as! String
                        if key == dict["id"] as! String{
                            print(child.value)
                            let dateFormat = Date().MonthDayDateFormatter()
                            for todayDict in child.value as! NSDictionary{
                                if dateFormat == todayDict.key as! String{
                                   let currentValue = todayDict.value as! NSDictionary
                                   print(currentValue)
                                   let currentStep = currentValue["steps"] as! String
                                   print(currentStep)
                                   dict["step"] = currentStep
                                   let leaderboard = Leaderboard.init(id: (dict["id"] as! String), s: (currentStep as NSString).integerValue)
                                   self.userList.append(leaderboard)
                                   self.userList = self.userList.sorted(by: {
                                        $0.step! > $1.step!})
                                   self.tblView.reloadData()
                                }
                            }
                        }
                    }
                })
            }
            })
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //return nameArr.count
        return userList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LeaderboardTableViewCell")as! LeaderboardTableViewCell
        let user = userList[indexPath.row] as Leaderboard
        let step = "\(user.step!)"
        cell.stepLabel.text = step
        cell.numberLabel.text = "\(indexPath.row + 1)"
        let handler = self.ref.child("publicUser").child(user.id!)
        handler.observe(DataEventType.value, with: { (snapshot) in
            for child in snapshot.value as! NSDictionary{
                let key1 = child.key as! String
                let key2 = child.key as! String
                if key1 == "username"{
                  cell.nameLabel.text = (child.value as! String)
                }
                if key2 == "profileImage"{
                    DispatchQueue.main.async {
                        let url = URL(string: (child.value as! String))!
                        let imageData =  NSData(contentsOf: url)
                        cell.profileImage.image = UIImage(data: imageData! as Data)
                    }
                }
                
            }
        })
        return cell
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
