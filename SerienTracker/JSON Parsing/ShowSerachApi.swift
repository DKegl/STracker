//
//  ShowSerachApi.swift
//  SerienTracker
//
//  Created by Daniel Keglmeier on 20.10.18.
//  Copyright © 2018 Daniel Keglmeier. All rights reserved.
//

import Alamofire
import Foundation

class ShowSearchAPI {
    func searchShowJson(name: String, complition: @escaping SearchCompletion) {
        var results = [ShowSearch]()
        
        guard let url = URL(string: "\(SEARCH_URL)"+"\(name)") else { return }
        print(url)
        
        Alamofire.request(url).responseJSON { response in
            if let error = response.result.error {
                print("hier")
                print(error.localizedDescription)
                complition(nil)
                return
            }
            guard let data = response.data else { return }
            let jsonDecoder = JSONDecoder()
            do {
                let showResults = try jsonDecoder.decode([ShowSearch?].self, from: data)
                for result in showResults {
                    if let result = result {
                        results.append(result)
                    }
                }
                complition(results)
                
            } catch {
                print("oder hier")
                debugPrint(error.localizedDescription)
                complition(nil)
            }
        }
    }
}
