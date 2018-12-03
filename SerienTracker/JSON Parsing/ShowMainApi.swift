//
//  ShowMainApi.swift
//  SerienTracker
//
//  Created by Daniel Keglmeier on 13.10.18.
//  Copyright © 2018 Daniel Keglmeier. All rights reserved.
//

import Foundation
import Alamofire

class ShowMainApi {
    //Added DispatchQueue 03.12.2018 by default Alamofire uses the main thread in some rare cases (to sync the call )you must use a different queue
    func getShowOverview(id: Int,queue:DispatchQueue?=nil,complition: @escaping ShowResponseCompletion) {
        
        guard let url = URL(string: "\(SHOW_URL)"+"\(id)") else { return}
        print(url)
        
        Alamofire.request(url).responseJSON(queue: queue, options: JSONSerialization.ReadingOptions.mutableContainers) { (response) in
            if let error = response.result.error {
                print("hier")
                print(error.localizedDescription)
                complition(nil)
                return
            }
            guard let data = response.data else { return }
            let jsonDecoder = JSONDecoder()
            do {
                let showInfo = try jsonDecoder.decode(ShowMainInformation.self, from: data)
                complition(showInfo)
                
            } catch  {
                print("oder hier")
                debugPrint(error.localizedDescription)
                complition(nil)
            }
        }
    }
    
}
