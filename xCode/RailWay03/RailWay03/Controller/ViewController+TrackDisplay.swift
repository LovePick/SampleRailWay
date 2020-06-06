//
//  ViewController+TrackDisplay.swift
//  RailWay03
//
//  Created by T2P mac mini on 7/1/2563 BE.
//  Copyright © 2563 T2P. All rights reserved.
//

import Cocoa

extension ViewController {

    
   
    
    // MARK: - Edit Mode
    func updateCarPosition(cars:[CarDataModel]){
        if let gameScene = ShareData.shared.gamseSceme{
         
            gameScene.updateCarsData(carsData: cars)
        }
        
        self.autoUpdateCarControllDisplay()
    }
    
    
    func updateDisplayWithPath(paths:[PathDataModel]){
        
        
        
        guard let gameScene = ShareData.shared.gamseSceme else { return }
        
        
        var newItem:[PathDataModel] = [PathDataModel]()
        
        if(paths.count <= 0){
            gameScene.model.deselectAllCell()
            self.lastSelectPaths.removeAll()
        }else{
            
            
            var i:NSInteger = self.lastSelectPaths.count - 1
            while i >= 0 {
                let last = self.lastSelectPaths[i]
                var remove:Bool = true
                for update in paths{
                    if(update.id == last.id){
                        remove = false
                        break
                    }
                }
                
                if(remove == true){
                    gameScene.model.deselectPath(path: last)
                    self.lastSelectPaths.remove(at: i)
                }
                i -= 1
            }
            
            
            
        
        }
        
        for pathData in paths{
            var have:Bool = false
            for ready in self.lastSelectPaths{
                if(pathData.id == ready.id){
                    have = true
                    break
                }
            }
            
            if(have == false){
                newItem.append(pathData)
            }
        }
        
      
        
        for pathData in newItem{
            self.lastSelectPaths.append(pathData)
            self.updateTileDisplay(pathData: pathData)
        }
            
            
    }
    
    
    
    
    func updateTileDisplay(pathData:PathDataModel){
        
        guard let gameScene = ShareData.shared.gamseSceme else { return }
        
        let arCellX = gameScene.model.arCell
        
        for item in pathData.setPath.values{
            
            if((item.i >= 0) && (item.i < arCellX.count)){
                let cellY = arCellX[item.i]
                
                if((item.j >= 0) && (item.j < cellY.count)){
                    let tile = arCellX[item.i][item.j]
                    if let m = TileCell.Mode(rawValue: item.mode){
                        tile.mode = m
                        
                        if(pathData.bufferRevertDirection == true){
                            tile.toRight = !item.toRight
                        }else{
                            tile.toRight = item.toRight
                        }
                        
                    }
                    
                    tile.selectedStage(select: true)
                }
            }
            
        }
    }
    
    // MARK: - Display
    
    
    func addDisplayPath(path:PathDataModel){
        
        var acPath:PathDataModel? = nil
        
        for p in self.arActivePath{
            if(path.id == p.id){
                acPath = p
                break
            }
        }
        

        guard let pathActive = acPath else {
            // add new display path
            self.updateTileDisplay(pathData: path)
            
            self.arActivePath.append(path)
            return
        }
        

        self.updateTileDisplay(pathData: pathActive)
        
        
    }
    
    
    func removeDisplayPath(path:PathDataModel){
        guard let gameScene = ShareData.shared.gamseSceme else { return }
        
        let arCellX = gameScene.model.arCell
        
        for item in path.setPath.values{
            
            if((item.i >= 0) && (item.i < arCellX.count)){
                let cellY = arCellX[item.i]
                
                if((item.j >= 0) && (item.j < cellY.count)){
                    let tile = arCellX[item.i][item.j]
                    tile.highlightStage(active: false)
                    tile.selectedStage(select: false)
                }
            }
            
        }
        //---
        
        var count:NSInteger = self.arActivePath.count - 1
        
        while (count >= 0) {
            let item = self.arActivePath[count]
            if(item.id == path.id){
                self.arActivePath.remove(at: count)
            }
            
            count -= 1
        }
    }
    
}
