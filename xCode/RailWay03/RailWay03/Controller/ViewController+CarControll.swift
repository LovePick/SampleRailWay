//
//  ViewController+CarControll.swift
//  RailWay03
//
//  Created by Supapon Pucknavin on 9/5/2563 BE.
//  Copyright © 2563 T2P. All rights reserved.
//

import Cocoa

extension ViewController {

    func showCarControllView(show:Bool, car:CarDataModel?){
        
        viCarControll.wantsLayer = true
        
        
        if(show){
            viCarControll.isHidden = false
        }else{
            viCarControll.isHidden = true
        }
        
        self.btCarControllTrackCar.isHighlighted = false
        self.btCarControllTrackCar.state = .off
        
        self.updateDisplayCallControll(car: car)
        
        self.cooldinater.trackCarID = ""
    }
    
    
    func updateDisplayCallControll(car:CarDataModel?){
        if let car = car{
            self.btCarControllStop.isEnabled = true
            self.lbCarControllName.stringValue = car.name
            self.lbCarControllID.stringValue = car.id
            
            /*
             case unknow = 0 // ไม่ทราบสถาณะ
             case dewell     //จอดรับผู้โดยสาร
             case waitDepart //รอออกรถ
             case onTheWay   //กำลังเดินทาง
             case arrived    //ถึงที่หมาย
             case emergencyStop  //หยุดรถฉุกเฉิน
             case stop       //รถหยุดวิ่ง / ไม่ทำงาน / จบการทำงาน
             case inProgress // อยู่ระหว่างประมวลผล
             case error
             */
            
            var status:String = "Status:"
            var stopBTTitle:String = "Stop"
           
            switch car.activeStatus {
            case .unknow:
                status = "Status: Unknow"
 
                if((car.progressStatus == .waitActive) || (car.progressStatus == .active)){
                    status = "Status: Waiting"
                }
                break
            case .dewell:
                status = "Status: Dewell"
                
                if((car.progressStatus == .waitActive)){
                    status = "Status: Waiting"
                }
                
                break
            case .onTheWay:
                status = "Status: On the way"
                break
            case .arrived:
                status = "Status: Arrived"
                break
            case .emergencyStop:
                status = "Status: Emergency Stop"
                stopBTTitle = "Continue"
                break
            case .inProgress:
                status = "Status: In Progress"
                break
            case .stop:
                status = "Status: Stop/Terminate"
                break
            case .error:
                status = "Status: Error"
                break
            default:
                break
            }
            self.lbCarControllStatus.stringValue = status
            
            self.btCarControllStop.title = stopBTTitle
            
            
        }else{
            self.lbCarControllName.stringValue = ""
            self.lbCarControllID.stringValue = ""
            self.lbCarControllStatus.stringValue = "Error"
            self.btCarControllStop.isEnabled = false
            self.btCarControllStop.title = ""
        }
    }
    
    
    func autoUpdateCarControllDisplay(){
        if((self.btCarControllStop.tag >= 0) && (self.btCarControllStop.tag < self.carListViewDataModel.arCars.count)){
            
            let car = self.carListViewDataModel.arCars[self.btCarControllStop.tag]
            self.updateDisplayCallControll(car: car)
        }else{
            self.cooldinater.trackCarID = ""
            self.updateDisplayCallControll(car: nil)
        }
    }
    
    @IBAction func selectCarControllTrank(_ sender: NSButton) {
        
      
        if((sender.tag >= 0) && (sender.tag < self.carListViewDataModel.arCars.count)){
            let car = self.carListViewDataModel.arCars[sender.tag]
            
            if(self.btCarControllTrackCar.state == .on){
                self.cooldinater.trackCarID = car.id
            }else{
              self.cooldinater.trackCarID = ""
            }
        }
    }
    
    @IBAction func clickOnCarcontrollStop(_ sender: NSButton) {
        
        if((sender.tag >= 0) && (sender.tag < self.carListViewDataModel.arCars.count)){
            let car = self.carListViewDataModel.arCars[sender.tag]
            
            var stopBTTitle:String = "Stop"
            
            
            switch car.activeStatus {
                case .emergencyStop:
                    self.cooldinater.continueCarWith(carID: car.id)
                    break
                default:
                    self.cooldinater.stopCarWith(carID: car.id)
                    stopBTTitle = "Continue"
                    break
                
            }
            
            self.btCarControllStop.title = stopBTTitle
            
        }
    }
}
