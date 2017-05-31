//
//  FriendViewController.swift
//  RJTHealthAndFitness
//
//  Created by Wenjun Weng on 5/26/17.
//  Copyright © 2017 rjt.compquest. All rights reserved.
//

import UIKit
import Firebase

class FriendViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tblView: UITableView!
    var ref: DatabaseReference!
    var FriendList = [Friend]()
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        self.tblView.tableFooterView = UIView.init(frame: CGRect.zero)
        findAllFriend()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = true
        
    }
    
    func findAllFriend(){
      //let userid = Auth.auth().currentUser?.uid
      let handler = self.ref.child("publicUser")
      handler.observe(DataEventType.value, with: { (snapshot) in
        for child in snapshot.value as! NSDictionary{
           print(child)
            var dict: [String: Any] = [:]
            dict["id"] = child.key
            let value = child.value as! NSDictionary
            for (k, v) in value {
              dict["\(k)"] = "\(v)"
            }
            let F =  Friend.init( id: (dict["id"] as! String),  n: (dict["username"] as! String), p: (dict["profileImage"] as! String) )
            self.FriendList.append(F)
            print(self.FriendList)
            self.tblView.reloadData()
        }
      })
    }
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //return nameArr.count
        return FriendList.count
    }
    
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell")as! FriendTableViewCell
        let dict = FriendList[indexPath.row] as Friend
        cell.username.text = dict.name
        DispatchQueue.main.async {
        let url = URL(string: dict.photo!)!
        let imageData =  NSData(contentsOf: url)
        cell.profileImage.image = UIImage(data: imageData! as Data)
        }
        cell.addFriendBtn.tag = indexPath.row
        cell.addFriendBtn.addTarget(self, action: #selector(addFriend), for:.touchUpInside)
        //Now use image to create into NSData format
        return cell
       
    }
    func addFriend ( _ sender: UIButton){
        let friend =  FriendList[sender.tag]
        let friendID = friend.id
        sender.isHidden = true
        let currentID = Auth.auth().currentUser?.uid
        self.ref.child("publicUser").child(currentID!).child("friend").updateChildValues([friendID!: true])
        self.ref.child("publicUser").child(currentID!).child("friend").updateChildValues([currentID!: true])
        self.ref.child("publicUser").child(friendID!).child("friend").updateChildValues([currentID!: true])
        self.ref.child("publicUser").child(friendID!).child("friend").updateChildValues([friendID!: true])
        //add alert
        let alert = UIAlertController(title: "Success!", message: "Add Friend Successfully", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title:"OK",style:UIAlertActionStyle.cancel,handler:{
            (action) in print ("action")
        }))
        self.present(alert, animated: true, completion: nil)
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
