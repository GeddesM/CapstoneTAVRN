//
//  ChannelVC.swift
//  SwiftChat
//
//  Created by anita on 2020-02-28.
//  Copyright © 2020 anita. All rights reserved.
//
//  This project was built using Xcode version 11 & iOS 13 & Swift 5.
//  Please run the SwiftChat.workspace file.
//  We are using PubNub API to publish, subscribe, and get the history of our
//  channel chat messages.
//

import UIKit
import PubNub

class ChannelVC: UIViewController, PNObjectEventListener, UITableViewDataSource, UITableViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = channelName
        tableView.delegate = self
        tableView.dataSource = self
        
        //getting the tableview to autosize
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 88.0
        
        //configuration info from pubnub
        let configuration = PNConfiguration(publishKey: "pub-c-264f8e39-eff4-4568-a989-0285966c3231", subscribeKey: "sub-c-a1371fc6-5a50-11ea-b226-5aef0d0da10f")
        configuration.uuid = UUID().uuidString
        client = PubNub.clientWithConfiguration(configuration)
        client.addListener(self)
        client.subscribeToChannels([channelName],withPresence: true)
        loadLastMessages()
    }
    
    //called during initial load to populate the tableview
    func loadLastMessages()
    {
        addHistory(start: nil, end: nil, limit: 10)
        //bring the tableview down to the bottom to the most recent messages
        if(!self.messages.isEmpty){
            let indexPath = IndexPath(row: self.messages.count-1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    //get and put the history of the channel into the messages array
    func addHistory(start:NSNumber?,end:NSNumber?,limit:UInt){
        client.historyForChannel(channelName, start: start, end: end, limit:limit){ (result, status) in
            if(result != nil && status == nil){
                // save when the earliest message was sent in order to get ones previous to it when we want to load more.
                self.earliestMessageTime = result!.data.start
                // convert the [Any] package we get into a dictionary of String and Any
                let messageDict = result!.data.messages as! [[String:String]]
                // creating new messages from it & putting them at the end of messages array
                var newMessages :[Message] = []
                for m in messageDict{
                    let message = Message(message: m["message"]! , username: m["username"]!, uuid: m["uuid"]! )
                    newMessages.append(message)
                }
                self.messages.insert(contentsOf: newMessages, at: 0)
                // reload table with new messages & bring tableview down to the bottom to the most recent messages
                self.tableView.reloadData()
                // making sure that we wont be able to try to reload more data until this is completed
                self.loadingMore = false
            }
            else if(status !=  nil){
                print(status!.category)
            }
            else{
                // testing
                print("everything is nil")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell") as! MessageCell
        cell.messageLabel.text = messages[indexPath.row].message
        cell.usernameLabel.text = messages[indexPath.row].username
        return cell
    }
    
    @IBAction func leaveChannel(_ sender: Any) {
        client.unsubscribeFromAll()
        self.performSegue(withIdentifier: "leaveChannelSegue", sender: self)
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var txtMessage: UITextField!
    
    
    struct Message {
        var message: String
        var username: String
        var uuid: String
    }
            
    var messages: [Message] = []
        
    var earliestMessageTime: NSNumber = -1
    var loadingMore = false
    
    //pubnub object to publish, subscribe, and get the history of our channel
    var client: PubNub!
    //temporary values
    var channelName = "Channel Name"
    var username = "Username"
    
    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
        // whenever we receive a new message, we add it to the end of our messages array and reload the table so that it shows at the bottom.
        if(channelName == message.data.channel)
        {
            let m = message.data.message as! [String:String]
            self.messages.append(Message(message: m["message"]!, username: m["username"]!, uuid: m["uuid"]!))
            tableView.reloadData()
            let indexPath = IndexPath(row: messages.count-1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
        print("Received message in Channel:",message.data.message!)
    }
    
    // allows users to query for more messages by dragging down from the top.
    func scrollViewDidScroll(_ scrollView: UIScrollView){
        // if we are not loading more messages already:
        if(!loadingMore){
            //-40 is when you have dragged down from the top of all the messages
            if(scrollView.contentOffset.y < -40 ) {
                loadingMore = true
                addHistory(start: earliestMessageTime, end: nil, limit: 10)
            }
        }
    }
    
    //function runs when send button is clicked
    func publishMessage() {
        if(txtMessage.text != "" || txtMessage.text != nil){
            let messageString: String = txtMessage.text!
            // add msg to messageObject
            let messageObject : [String:Any] =
                [
                    "message" : messageString,
                    "username" : username,
                    "uuid": client.uuid()
            ]
            client.publish(messageObject, toChannel: channelName) { (status) in
                print(status.data.information)
            }
            //clear text field
            txtMessage.text = ""
        }
    }
    
    //onclick function for send message button runs function above:
    @IBAction func sendBtn(_ sender: Any) {
        publishMessage()
    }
    
    
    
}
    
    
