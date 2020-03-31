//
//  RegisterVC.swift
//  SwiftChat
//
//  Created by anita on 2020-03-30.
//  Copyright © 2020 anita. All rights reserved.
//

import UIKit

class RegisterVC: UIViewController {
    
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    var db: DBHelper!
    
    @IBAction func register(_ sender: Any) {
    
        let username = txtUsername.text!
        let password = txtPassword.text!
        
        if (username != "") {
            let res = db.insert(username:username, password:password)
            if res {
                
                let alert = UIAlertController(title:"Registry Successful!", message:"User has been created",
                preferredStyle: .alert)
                
                let okAction = UIAlertAction(title:"OK", style: .default, handler: {
                  action -> Void in
                })
                
                alert.addAction(okAction)
                
                self.present(alert, animated: true)
            }
            
            else {
                let alert = UIAlertController(title:"Error", message:"User could not be added",
                preferredStyle: .alert)
                
                let okAction = UIAlertAction(title:"OK", style: .default, handler: {
                  action -> Void in
                })
                
                alert.addAction(okAction)
                
                self.present(alert, animated: true)
            }
            
            
        }
        
        
    }
    
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = DBHelper();        
        
        

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
