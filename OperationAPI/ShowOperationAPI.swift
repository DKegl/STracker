//
//  BaseOperation.swift
//  SerienTracker
//
//  Created by Andre Frank on 14.11.18.
//  Copyright © 2018 Daniel Keglmeier. All rights reserved.
//

import Foundation


class EpisodesOperation : BaseOperation {
    
    private var epListAPI=ShowEpListApi()
    //Public show property
    var outData:[Any]?=[Any]()
    let id:Int
    
    init(id:Int) {
        self.id=id
        super.init()
    }
    
    
    override func main() {
        if isCancelled {
            completeOperation()
            return
        }
        
        epListAPI.getEpList(id: id) {[unowned self] (episoden) in
            if let episoden=episoden{
                self.outData=episoden
            }
            
            self.completeOperation()
            return
        }
       
        
    }
}

class ShowOperation : BaseOperation {
    
    private var showMainAPI=ShowMainApi()
    
    //Public show property
    var outData:Any?
    let id:Int
    
    init(id:Int) {
        self.id=id
        super.init()
    }

    
    override func main() {
        if isCancelled {
            completeOperation()
            return
        }
    
        showMainAPI.getShowOverview(id: id, complition: {[unowned self] (info) in
            self.outData=info
            self.completeOperation()
            return
        })
        
    }
}

class BaseOperation: Operation {
    private var backing_executing : Bool
    override var isExecuting : Bool {
        get { return backing_executing }
        set {
            willChangeValue(forKey: "isExecuting")
            backing_executing = newValue
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    private var backing_finished : Bool
    override var isFinished : Bool {
        get { return backing_finished }
        set {
            willChangeValue(forKey: "isFinished")
            backing_finished = newValue
            didChangeValue(forKey: "isFinished")
        }
    }
    
    override init() {
        backing_executing = false
        backing_finished = false
        
        super.init()
    }
    
    func completeOperation() {
        isExecuting = false
        isFinished = true
    }
}
