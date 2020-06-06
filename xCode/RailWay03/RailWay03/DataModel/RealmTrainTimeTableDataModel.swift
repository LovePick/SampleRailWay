//
//  RealmTrainTimeTableDataModel.swift
//  RailWay03
//
//  Created by Supapon Pucknavin on 22/5/2563 BE.
//  Copyright © 2563 T2P. All rights reserved.
//

import Cocoa
import RealmSwift

class RealmTrainTimeTableDataModel: Object {

    @objc dynamic var carID:String = ""
    @objc dynamic var carName:String = ""
    
    @objc dynamic var stationID:String = ""
    @objc dynamic var stationName:String = ""
    
    @objc dynamic var action:String = ""
    @objc dynamic var note:String = ""
    @objc dynamic var time:Date? = nil
         
    
    @objc dynamic var fromStationID:String = ""
    @objc dynamic var fromStationName:String = ""
    
    @objc dynamic var toStationID:String = ""
    @objc dynamic var toStationName:String = ""
    
}
