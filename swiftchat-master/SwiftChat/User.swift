//
//  User.swift
//  SwiftChat
//
//  Created by anita on 2020-03-30.
//  Copyright © 2020 anita. All rights reserved.
//

import UIKit

class User: NSObject {
    
    var id: Int = 0
    var username: String = ""
    var password: String = ""
    
    init(id: Int, username:String, password:String)
    {
        self.id = id
        self.username = username
        self.password = password
    }

}
