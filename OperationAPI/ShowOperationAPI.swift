//
//  BaseOperation.swift
//  SerienTracker
//
//  Created by Andre Frank on 14.11.18.
//  Copyright © 2018 Daniel Keglmeier. All rights reserved.
//

import Foundation

// MARK: - Using NSOperation queue to save/delete bookmarks

extension MainShowInformationVC {
    func excuteOperationsWithShowInformation(id: Int) {
        let queue = OperationQueue()
        
        // Create Operations in sequence for nested asyn methods
        let operation1 = ShowOperation(id: id)
        let operation2 = EpisodesOperation(id: id)
        // Output operation
        let combinedOperation = BlockOperation { [unowned operation1, operation2] in
            let show = operation1.outData as? ShowMainInformation
            let episodes = operation2.outData as? [ShowEpisodenInformation]
            // Output must be executed in main thread
            OperationQueue.main.addOperation {
                if let showObject = self.realm.object(ofType: RealmBookmarkShow.self, forPrimaryKey: show?.showId) {
                    _ = self.deleteBookmarkShow(realmShow: showObject)
                } else {
                    _ = self.saveAsBookmarkShow(show: show!, episodes: episodes!)
                }
            }
        }
        
        // Dependencies between them
        operation2.addDependency(operation1)
        combinedOperation.addDependency(operation2)
        // Execute all operations
        queue.addOperations([operation1, operation2, combinedOperation], waitUntilFinished: false)
    }
}


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
