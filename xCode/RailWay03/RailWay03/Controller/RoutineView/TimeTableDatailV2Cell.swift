//
//  TimeTableDatailV2Cell.swift
//  RailWay03
//
//  Created by T2P mac mini on 6/2/2563 BE.
//  Copyright © 2563 T2P. All rights reserved.
//

import Cocoa

class TimeTableDatailV2Cell: NSCollectionViewItem {
    
    
    
    @IBOutlet weak var btPath: NSPopUpButton!
    
    //    @IBOutlet weak var depart: NSDatePicker!
    
    
    @IBOutlet weak var tfDewell: NSTextField!
    
    @IBOutlet weak var tfDuration: NSTextField!
    
    @IBOutlet weak var viLine: NSView!
    
    @IBOutlet weak var lbToStation: NSTextField!
    var myTag:NSInteger = 0
    
    
    var arriveDateChangeCallBack:(NSInteger, Date)->Void = {(tag, date) in }
    //var departDateChangeCallBack:(NSInteger, Date)->Void = {(tag, date) in }
    var tapOnStationCallBack:(NSInteger, TileCellDataModel)->Void = {(tag, station) in }
    
    
    
    var arStationChoice:[TileCellDataModel] = [TileCellDataModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.view.wantsLayer = true
        
        viLine.wantsLayer = true
        viLine.layer?.backgroundColor = NSColor.app_space_blue.cgColor
        
        
        btPath.removeAllItems()
    }
    
    
    func updateStationList(stations:[TileCellDataModel]){
        self.arStationChoice = stations
        
        btPath.removeAllItems()
        
        btPath.addItem(withTitle: "-")
        
        for s in stations{
            let title = s.id
            btPath.addItem(withTitle: title)
        }
        /*
         if let mvc = ShareData.shared.masterVC{
         let paths = mvc.pathListViewDataModel.arPath
         for part in paths{
         
         let title = part.getTitle()
         btPath.addItem(withTitle: title)
         }
         }*/
    }
    
    func setSelectState(select:Bool) {
        
        self.view.wantsLayer = true
        
        
        if(select){
            self.view.layer?.backgroundColor = NSColor.app_space_blue2.cgColor
        }else{
            
            self.view.layer?.backgroundColor = NSColor.clear.cgColor
        }
    }
    
    
    
    @IBAction func tapOnPath(_ sender: NSPopUpButton) {
        
        if((sender.indexOfSelectedItem >= 0) && (sender.indexOfSelectedItem <= self.arStationChoice.count)){
            
            let indexStation = sender.indexOfSelectedItem - 1
            
            if((indexStation >= 0) && (indexStation < self.arStationChoice.count)){
                let station = self.arStationChoice[indexStation]
                self.tapOnStationCallBack(self.myTag, station)
            }
            
        }
        
        print(sender.indexOfSelectedItem)
    }
    
    
}
