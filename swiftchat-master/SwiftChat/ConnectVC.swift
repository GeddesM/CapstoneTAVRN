//
//  ViewController.swift
//  SwiftChat
//
//  Created by anita on 2020-02-28.
//  Copyright © 2020 anita. All rights reserved.
//

import UIKit


class ConnectVC: UIViewController {
    
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var channelTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    
    var db: DBHelper!
    
    @IBAction func register(_ sender: Any) {
        self.performSegue(withIdentifier: "registerSegue", sender: self)
    }
    
    @IBAction func connect(_ sender: Any) {
        
        let username = usernameTxt.text ?? "Anonymous"
        let password = passwordTxt.text ?? "None"
        
        //authenticate user before performing segue
        let res = authorize(username:username, password:password)
        if res {
            self.performSegue(withIdentifier: "connectSegue", sender: self)
        }
        else {
            let alert = UIAlertController(title:"Login Failed", message:"Credentials do not match!",
            preferredStyle: .alert)
            
            let okAction = UIAlertAction(title:"OK", style: .default, handler: {
              action -> Void in
            })
            
            alert.addAction(okAction)
            self.present(alert, animated: true)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()             
        
        // Do any additional setup after loading the view.
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // accessing Nav Controller and ChannelVC view
        if let navigationController = segue.destination as? UINavigationController,
            let channelVC = navigationController.viewControllers.first as? ChannelVC {

            let channel = channelTxt.text ?? "General"
            let username = usernameTxt.text ?? "Anonymous"
            
            // setting values in ChannelVC
            channelVC.username = username
            channelVC.channelName = channel
        }
    }
    
    func authorize(username:String, password:String) -> Bool {
        db = DBHelper();
        let users = db.read();
        for u in users {
            if (u.username == username && u.password == password) {
                return true
            }
        }
        return false
    }
    
    



}

