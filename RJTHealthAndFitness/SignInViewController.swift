//
//  SignInViewController.swift
//  RJTHealthAndFitness
//
//  Created by Wenjun Weng on 5/19/17.
//  Copyright © 2017 rjt.compquest. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import FBSDKCoreKit

class SignInViewController: BaseViewController {
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.title = "SIGN IN"
        ref = Database.database().reference()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func signinBtnClicked(_ sender: Any) {
        Auth.auth().signIn(withEmail: email.text!, password: password.text!) { (user, error) in
            if(error != nil){
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title:"OK",style:UIAlertActionStyle.cancel,handler:{
                    (action) in print ("action")
                }))
                self.present(alert, animated: true, completion: nil)
            }
            else{
                let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabbarViewController") as UIViewController
                self.present(viewController, animated: false, completion: nil)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func facebookLogin(_ sender: Any) {
        FBSDKLoginManager().logIn(withReadPermissions:  ["email","public_profile"], from: self) { (result, err) in
            if err != nil{
                print("Facebook login Failed- ", err!.localizedDescription)
            }else{
                print("Facebook login Successful")
                //facebook graph request
                FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start(completionHandler: { (connection, result, err) in
                    if (err != nil){
                        print("Graph request failed- ",err!.localizedDescription)
                        return
                    }
                    else{
                        guard let facebookDict = result as? Dictionary<String, Any>,
                            let id = facebookDict["id"] as? String,
                            let name = facebookDict["name"] as? String,
                            let email = facebookDict["email"] as? String else {
                                
                                print("Parsing Facebook failied")
                                return
                        }
                        let pictureURL = "https://graph.facebook.com/\(id)/picture?type=large"
                        
                        
                        //Auth Facebook through Firebase
                        
                        let credential: AuthCredential? = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                        
                        Auth.auth().signIn(with: credential!, completion: { (user, err) in
                            if(err != nil){
                                print("Authentication Error- ",err!.localizedDescription)
                                return
                            }
                            else{
                                print("Authentication Successfully with facebook")
                                let uid = (user?.uid)!
                                
                                self.ref.child("user").child(uid).updateChildValues(["username": name,"email":email,"profileImage": pictureURL])
                                
                                self.ref.child("publicUser").child(uid).updateChildValues(["username": name, "email":email, "profileImage": pictureURL])
                                
                                
                                let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabbarViewController") as UIViewController
                                self.present(viewController, animated: false, completion: nil)
                            }
                        })
                        
                    }
                })
            }
            
        }
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
