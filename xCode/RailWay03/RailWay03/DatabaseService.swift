//
//  DatabaseService.swift
//  RailWay03
//
//  Created by Supapon Pucknavin on 22/5/2563 BE.
//  Copyright © 2563 T2P. All rights reserved.
//

import Cocoa
import RealmSwift


class DatabaseService {

    var realm:Realm?
    init() {
        
        var config = Realm.Configuration()
        
        do{
            self.realm = try Realm()
        }catch{
            print(error.localizedDescription)
        }
        
        
    }
    
  
    func addTimetableData(data:RealmTrainTimeTableDataModel){
        guard let realmDB = self.realm else {
            return
        }
        
        do{
            try realmDB.write{
                realmDB.add(data)
            }
        }catch{
            print(error.localizedDescription)
        }
    }
}
