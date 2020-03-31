//
//  DBHelper.swift
//  SwiftChat
//
//  Created by anita on 2020-03-30.
//  Copyright © 2020 anita. All rights reserved.
//

import UIKit
import Foundation
import SQLite3

class DBHelper {
    
    init()
    {
        db = openDatabase()
        createTable()
    }
    
    let dbPath: String = "myDb.sqlite"
    var db:OpaquePointer?
    
    func openDatabase() -> OpaquePointer?
    {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(dbPath)
        var db: OpaquePointer? = nil
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK
        {
            print("error opening database")
            return nil
        }
        else
        {
            print("Successfully opened connection to database at \(dbPath)")
            return db
        }
    }
    
    func createTable() {
        let createTableString = "CREATE TABLE IF NOT EXISTS users(Id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT, password TEXT);"
        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK
        {
            if sqlite3_step(createTableStatement) == SQLITE_DONE
            {
                print("users table created.")
            } else {
                print("users table could not be created.")
            }
        } else {
            print("CREATE TABLE statement could not be prepared.")
        }
        sqlite3_finalize(createTableStatement)
    }
    
    func insert(username:String, password:String) -> Bool
        {
            var result:Bool
            let insertStatementString = "INSERT INTO users(username, password) VALUES (?, ?);"
            var insertStatement: OpaquePointer? = nil
            if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
                sqlite3_bind_text(insertStatement, 1, (username as NSString).utf8String, -1, nil)
                sqlite3_bind_text(insertStatement, 2, (password as NSString).utf8String, -1, nil)
                
                if sqlite3_step(insertStatement) == SQLITE_DONE {
                    print("Successfully inserted row.")
                    result = true
                } else {
                    print("Could not insert row.")
                    result = false
                }
            } else {
                print("INSERT statement could not be prepared.")
                result = false
            }
            sqlite3_finalize(insertStatement)
            return result
        }
        
        func read() -> [User] {
            let queryStatementString = "SELECT * FROM users;"
            var queryStatement: OpaquePointer? = nil
            var psns : [User] = []
            if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                while sqlite3_step(queryStatement) == SQLITE_ROW {
                    let id = sqlite3_column_int(queryStatement, 0)
                    print("id: \(id)")
                    let username = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                    print("username: \(username)")
                    let password = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                    print("password: \(password)")
                    psns.append(User(id: Int(id), username: username, password: password))
                    print("Query Result:")
                    print("\(id) | \(username) | \(password)")
                }
            } else {
                print("SELECT statement could not be prepared")
            }
            sqlite3_finalize(queryStatement)
            return psns
        }
        
        func deleteByID(id:Int) {
            let deleteStatementStirng = "DELETE FROM users WHERE Id = ?;"
            var deleteStatement: OpaquePointer? = nil
            if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
                sqlite3_bind_int(deleteStatement, 1, Int32(id))
                if sqlite3_step(deleteStatement) == SQLITE_DONE {
                    print("Successfully deleted row.")
                } else {
                    print("Could not delete row.")
                }
            } else {
                print("DELETE statement could not be prepared")
            }
            sqlite3_finalize(deleteStatement)
        }
        
    }
    
    
    

