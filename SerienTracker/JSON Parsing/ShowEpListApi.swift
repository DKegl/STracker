//
//  ShowEpListApi.swift
//  SerienTracker
//
//  Created by Daniel Keglmeier on 13.10.18.
//  Copyright © 2018 Daniel Keglmeier. All rights reserved.
//

import Alamofire
import Foundation

class ShowEpListApi {
    func getEpList(id: Int, complition: @escaping EpListCompletion) {
        var episoden=[ShowEpisodenInformation]()
        
        guard let url = URL(string: "\(SHOW_URL)"+"\(id)"+"/episodes") else { return }
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
                let epInfo = try jsonDecoder.decode([ShowEpisodenInformation?].self, from: data)
                for episode in epInfo {
                    if let episode = episode{
                        episoden.append(episode)
                    }
                }
                complition(episoden)
                
            } catch {
                print("oder hier")
                debugPrint(error.localizedDescription)
                complition(nil)
            }
        }
    }
}
