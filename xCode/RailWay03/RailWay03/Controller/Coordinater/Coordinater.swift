//
//  Coordinater.swift
//  RailWay03
//
//  Created by T2P mac mini on 8/1/2563 BE.
//  Copyright © 2563 T2P. All rights reserved.
//

import Cocoa


@objc protocol CoordinaterDelegate {
    @objc optional func activePathData(path:PathDataModel)
    @objc optional func activeCarData(car:CarDataModel)
}



class Coordinater: NSObject {
    
    
    enum Mode{
        case simulator
        case controll
    }
    
    enum ControllStatus{
        case ideal
        case runing
        case stop
    }
    static let shared = Coordinater()
    
    var delegate:CoordinaterDelegate? = nil
    
    
    let waitTimeToReRun:Double = 1
    
    
    var simulatorCars:[String:CarDataModel] = [String:CarDataModel]()
    
    
    var bookingPath:[PathDataModel] = [PathDataModel]()
    
    var bookingCell:[TileCellDataModel] = [TileCellDataModel]()
    
    //var arTimeTable:[TimeTableDataModel]? = nil
    
    
    var timer:Timer! = nil
    
    
    var mode:Mode = .simulator
    var controllStatus:ControllStatus = .ideal
    
    var myService:Service = Service()
    
    var trackCarID:String = ""
    
    
    override init() {
        super.init()
        
        myService.delegate = self
    }
    
    
    func connectServer() {
        myService.conntecServer()
    }
    func startSystem()->Bool{
        
        
        return true
    }
    
    
    
    func runSimulator(cars:[CarDataModel], inMode:Mode){
        
        //update car data
        self.mode = inMode
        for car in cars{
            
            if(self.mode == .controll){
                car.inModeSimulator = false
            }else{
                car.inModeSimulator = true
            }
            self.simulatorCars[car.id] = car
        }
        
        self.startTimer()
        
    }
    
    
    
    func startTimer(){
        self.controllStatus = .runing
        
        if(self.timer != nil){
            return
        }
        
        self.adjutTimeToNow()
        
        self.timer = Timer.scheduledTimer(timeInterval: waitTimeToReRun, target: self, selector: #selector(myLoop), userInfo: nil, repeats: true)
    }
    
    
    func continueSimulator() {
        self.controllStatus = .runing
        self.timer = Timer.scheduledTimer(timeInterval: waitTimeToReRun, target: self, selector: #selector(myLoop), userInfo: nil, repeats: true)
    }
    func pauseTimer(){
        self.controllStatus = .stop
        
        if(self.timer == nil){
            return
        }
        
        if(self.timer.isValid){
            self.timer.invalidate()
        }
        self.timer = nil
        
    }
    
    func resetSimulater(){
        self.controllStatus = .ideal
        self.trackCarID = ""
        if(self.timer != nil){
            if(self.timer.isValid){
                self.timer.invalidate()
            }
        }
        
        self.timer = nil
        
        for item in self.bookingCell{
            item.bookByCarID = ""
        }
        
        
        self.simulatorCars.removeAll()
        self.bookingPath.removeAll()
        
        self.myLoop()
    }
    
    
    
    @objc func myLoop(){
        
        let now:Date = Date()//.addingTimeInterval(10)
        
        
        guard let mvc = ShareData.shared.masterVC else { return }
        
        
        
        
        
        var arCar:[CarDataModel] = [CarDataModel]()
        for (_, car) in self.simulatorCars{
            car.updatePriority(time: now)
            arCar.append(car)
        }
        arCar = arCar.sorted(by: { (car1, car2) -> Bool in
            return car1.priority < car2.priority
        })
        
        var arCarDic:[[String:Any]] = [[String:Any]]()
        
        print("=====")
        for car in arCar{
            
            print("Cat: \(car.name) ===> \(car.priority)")
            car.updateStep(time: now)
            print("Status: \(car.activeStatus)")
            let bcDic:[String:Any] = car.broadcastData()
            arCarDic.append(bcDic)
            
        }
        
        
        mvc.updateCarPosition(cars: arCar)
        
        mvc.updateDisplayWithPath(paths: self.bookingPath)
        
        
        var carsDic:[String:Any] = [String:Any]()
        carsDic["cars"] = arCarDic
        
        self.broadcastCars(cars: carsDic)
        
        
        
        if let gameScene = ShareData.shared.gamseSceme{
            gameScene.trackCar(carID: self.trackCarID)
        }
        
        
        
        
        
    }
    
    
    
    
    
    func getCellBooking()->[TileCellDataModel]{
        
        
        return self.bookingCell
    }
    
    func addBookingPath(path:PathDataModel, byCar:CarDataModel){
        self.bookingPath.append(path)
        
        
        for (_, cell) in path.setPath{
            
            cell.bookByCarID = byCar.id
            self.bookingCell.append(cell)
        }
        
    }
    
    func removeBookingPath(path:PathDataModel){
        
        var i:NSInteger = self.bookingPath.count - 1
        while i >= 0 {
            let item = self.bookingPath[i]
            if(item.id == path.id){
                self.bookingPath.remove(at: i)
                
            }
            i -= 1
        }
        
        
        //---------
        
        //remove cell
        for (_, cell) in path.setPath{
            self.removeBookingCell(cell: cell)
        }
        // end remove cell
        
    }
    
    func removeBookingBy(carID:String){
       var i:NSInteger = self.bookingCell.count - 1
       while i >= 0 {
           let item = self.bookingCell[i]
           if(item.bookByCarID == carID){
                item.bookByCarID = ""
               self.bookingCell.remove(at: i)
               
           }
           i -= 1
       }

    }
    
    
    
    func addBookingCell(cell:TileCellDataModel, byCar:CarDataModel){
        
        let item = cell
        item.bookByCarID = byCar.id
        self.bookingCell.append(item)
    }
    
    func removeBookingCell(cell:TileCellDataModel){
        
        var j:NSInteger = self.bookingCell.count - 1
        while j >= 0 {
            let readyCell = self.bookingCell[j]
            if(readyCell.id == cell.id){
                
                readyCell.bookByCarID = ""
                self.bookingCell.remove(at: j)
            }
            
            j -= 1
        }
    }
    
    func adjutTimeToNow(){
        let now:Date = Date().addingTimeInterval(5)
        
        //        let dateFormat:DateFormatter = DateFormatter()
        //        dateFormat.dateFormat = "HH:mm:ss"
        //        dateFormat.calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        
        
        var startTime:Date! = nil
        guard let ms = ShareData.shared.masterVC else { return }
        
        
        for ttbr in ms.timeTableModel.arRoutine{
            let arR = ttbr.arRoutine
            for r in arR{
                
                if(startTime == nil){
                    startTime = r.startTime
                }
                if(r.startTime.timeIntervalSince1970 < startTime.timeIntervalSince1970){
                    startTime = r.startTime
                }
            }
        }
        
        guard startTime != nil else {
            return
        }
        
        var diff = now.timeIntervalSince1970 - startTime.timeIntervalSince1970
        
        diff = diff + 5
        
        
        for ttbr in ms.timeTableModel.arRoutine{
            let arR = ttbr.arRoutine
            for r in arR{
                
                let oldTime = r.startTime
                r.startTime = oldTime.addingTimeInterval(diff)
                
            }
        }
        
        
    }
    
    
    func getStationScheduleWhit(stationID:String)->[ScheduleDetailModel]{
        var arSchedule:[ScheduleDetailModel] = [ScheduleDetailModel]()
        
        
        
        guard let ms = ShareData.shared.masterVC else {
            return arSchedule
        }
    
        
        for car in ms.carListViewDataModel.arCars{
        
            let carSc = self.getScheduleWhit(car: car)
            for scd in carSc.arSchedule{
                if(scd.station == stationID){
                    arSchedule.append(scd)
                }
            }
        }
        
        return arSchedule
    }
    
    func getCarScheduleWhit(carID:String)->CarScheduleDetailModel?{
        
        
        guard let ms = ShareData.shared.masterVC else {
            return nil
        }
        
        
        
        var car:CarDataModel? = nil
        
        for c in ms.carListViewDataModel.arCars{
            if c.id == carID{
                car = c
                break
            }
        }
        
        
        guard let acar = car else {
            return nil
        }
        
        
        return self.getScheduleWhit(car: acar)
        
    }
    
    func getScheduleWhit(car:CarDataModel)->CarScheduleDetailModel{
        
        
        let newCarSchedule:CarScheduleDetailModel = CarScheduleDetailModel()
        newCarSchedule.carID = car.id
        
        
        
        guard let ms = ShareData.shared.masterVC else {
            return newCarSchedule
        }
        
        
        
        guard let ttbRoutine = ms.getTimeTableRoutineWith(timeTableRoutineId: car.timeTableRoutineId) else { return  newCarSchedule }
        
        
        
        
        for rout in ttbRoutine.arRoutine{
            var buffStart:Date = rout.startTime
            
            for _ in 0..<rout.count{
                if let ttb = ms.getTimeTableWith(ttbID: rout.timeTableID){
                    
                    for detail in ttb.arDetails{
                        
                        let newItem:ScheduleDetailModel = ScheduleDetailModel()
                        
                        newItem.arrive = buffStart.addingTimeInterval(TimeInterval(detail.dewell))
                        newItem.depart = newItem.arrive.addingTimeInterval(TimeInterval(detail.duration))
                        
                        buffStart = newItem.arrive
                        
                        if let station = detail.station{
                            newItem.station = station.id
                        }
                        
                        if let to = detail.toStation{
                            newItem.to = to.id
                        }
                        
                        if let from = detail.fromStation{
                            newItem.from = from.id
                        }
                        newItem.car = car.id
                            
                        newCarSchedule.arSchedule.append(newItem)
                    }
                    
                }
            }
            
            
        }
        
        
        
        return newCarSchedule
        
    }
    
    
    
    func broadcastCars(cars:[String:Any]){
        self.myService.sendCarsMessage(json: cars)
    }
    
    
    
    
    func getCarWith(carID:String)->CarDataModel?{
        guard let ms = ShareData.shared.masterVC else {
            return nil
        }
        
        var car:CarDataModel? = nil
        
        for c in ms.carListViewDataModel.arCars{
            if c.id == carID{
                car = c
                break
            }
        }
        
        return car
    }
    
    
    func setStatusCarWith(carID:String, status:CarDataModel.ActiveStatus){
        
        
        guard let ms = ShareData.shared.masterVC else {
            return
        }
        
        for c in ms.carListViewDataModel.arCars{
            if c.id == carID{
                
                if(status == .emergencyStop){
                    c.lastActiveStatus = c.activeStatus
                }
                
                c.activeStatus = status
                break
            }
        }
        
    }

    /*
     func callDepart(car:CarDataModel){
     if let depart = car.timeDetail.depart{
     let now:Date = Date()
     var interval = depart.timeIntervalSince(now)
     if(interval < 0){
     let abs:Double = interval * -1
     interval = self.waitTimeToReRun
     let delay = abs + interval
     if let c = self.simulatorCars[car.id]{
     c.carStatus = .delay
     c.delayTime = delay
     self.simulatorCars[car.id] = c
     }
     
     }
     
     let context = ["carId": car.id]
     Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(departTimer), userInfo: context, repeats: true)
     }else{
     
     guard let car = self.simulatorCars[car.id] else { return }
     car.activeStatus = .stop
     self.simulatorCars[car.id] = car
     self.addScheduledTimerWith(car: car)
     }
     }
     
     */
    
    /*
     @objc func departTimer(timer: Timer) {
     guard let context = timer.userInfo as? [String: String] else { return }
     
     guard let carId = context["carId"] else { return }
     
     guard let car = self.simulatorCars[carId] else { return }
     car.position = .onTheWay
     car.activeStatus = .onTheWay
     self.simulatorCars[car.id] = car
     
     guard let de = self.delegate else { return }
     
     de.activeCarData?(car: car)
     
     guard let detail = car.timeDetail else { return }
     if let path = detail.path{
     de.activePathData?(path: path)
     }
     
     
     }
     */
}

extension Coordinater:ServiceDelegate{
    func getTimeTableWith(stationID: String) {
        
        let arData = self.getStationScheduleWhit(stationID: stationID)
        var arDic:[[String:Any]] = [[String:Any]]()
        for item in arData{
            arDic.append(item.getDicData())
        }
        
        self.myService.sendStationTimeTable(stationId: stationID, json: arDic)
        
    }
    
    func stopCarWith(carID:String){
        self.setStatusCarWith(carID: carID, status: .emergencyStop)
    }
    func continueCarWith(carID:String){
        self.setStatusCarWith(carID: carID, status: .inProgress)
    }
    func carArrive(carID:String, stationID:String){
        
        guard let car = self.getCarWith(carID: carID) else {
            return
        }
        guard let detail = car.timeDetail else {
            self.setStatusCarWith(carID: carID, status: .error)
            return
        }
        
        guard let to = detail.toStation else {
            self.setStatusCarWith(carID: carID, status: .error)
            return
        }
        
        if(to.id == stationID){
            self.setStatusCarWith(carID: carID, status: .arrived)
        }else{
            self.setStatusCarWith(carID: carID, status: .error)
        }
        
        
    }
    
    func restartSimulator(){
        guard let mvc = ShareData.shared.masterVC else { return }
        
        mvc.resetController()
        
        mvc.startRunWithSimulator()
    }
}

