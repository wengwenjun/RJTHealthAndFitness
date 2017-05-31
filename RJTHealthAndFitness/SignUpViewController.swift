//
//  SignUpViewController.swift
//  RJTHealthAndFitness
//
//  Created by Wenjun Weng on 5/19/17.
//  Copyright © 2017 rjt.compquest. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: BaseViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    var ref: DatabaseReference!
    var imagePicker: UIImagePickerController!
    var profileImageURL: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: false)
        ref = Database.database().reference()
        self.title = "SIGN UP"
        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        username.resignFirstResponder()
        password.resignFirstResponder()
        confirmPassword.resignFirstResponder()
        email.resignFirstResponder()
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallary()
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
        {
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    func openGallary()
    {
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        // use the image
        imageView.image = chosenImage
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func saveProfileImage(){
        let userid = Auth.auth().currentUser?.uid
        let storage = Storage.storage()
        let storageRef = storage.reference(forURL: "gs://fitness-8aada.appspot.com/")
        let imageID = NSUUID().uuidString
        let imageName1 = "Profile Pictures/"
        let imageName2 = "\(imageID).jpg"
        let imageName = imageName1 + imageName2
        let profilePicRef = storageRef.child(imageName);
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let imageData = UIImageJPEGRepresentation(imageView.image!, 0.8)
        profilePicRef.putData(imageData!, metadata: metadata) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                print("Error!")
                return
            }
            self.profileImageURL = (metadata.downloadURL()?.absoluteString)!
            print("Success upload data!")
            self.ref.child("user").child(userid!).updateChildValues(["profileImage": self.profileImageURL])
            self.ref.child("publicUser").child(userid!).updateChildValues(["profileImage": self.profileImageURL])
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    @IBAction func signup(_ sender: Any) {
        //check if email is valid or not
        if(!isValidEmail(testStr: email.text!)){
            let alert = UIAlertController(title: "Try again", message: "Email is not valid!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title:"OK",style:UIAlertActionStyle.cancel,handler:{
                (action) in print ("action")
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else if (password.text! != confirmPassword.text!){
            let alert = UIAlertController(title: "Try again", message: "Your password is not matched!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title:"OK",style:UIAlertActionStyle.cancel,handler:{
                (action) in print ("action")
            }))
            self.present(alert, animated: true, completion: nil)
        } else if username.text == "" || password.text == "" || confirmPassword.text == ""{
            let alert = UIAlertController(title: "Try again", message: "Please fill in all information", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title:"OK",style:UIAlertActionStyle.cancel,handler:{
                (action) in print ("action")
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else{
        Auth.auth().createUser(withEmail: email.text!, password: password.text!) { (user, error) in
            if error != nil{
                let alert = UIAlertController(title: "Try again", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title:"OK",style:UIAlertActionStyle.cancel,handler:{
                    (action) in print ("action")
                }))
                self.present(alert, animated: true, completion: nil)
            }else{
                self.ref.child("user").child((user?.uid)!).updateChildValues(["username": self.username.text!, "password": self.password.text!, "email":self.email.text!])
                self.ref.child("publicUser").child((user?.uid)!).updateChildValues(["username": self.username.text!, "password": self.password.text!, "email":self.email.text!])
                self.saveProfileImage()
                let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabbarViewController") as UIViewController
                self.present(viewController, animated: false, completion: nil)
            }
        }
        }
    }
    
    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
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
