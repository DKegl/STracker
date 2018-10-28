//
//  UIImageView+Extension.swift
//  SerienTracker
//
//  Created by Andre Frank on 20.10.18.
//  Copyright © 2018 Daniel Keglmeier. All rights reserved.
//

import UIKit
import Alamofire

fileprivate let imageCache=NSCache<AnyObject,UIImage>()

class CachedImageView:UIImageView{
    var imageUrlString:String?
    
    func loadImageFromUrl(_ stringUrl:String){
        
        //Save url string
        imageUrlString=stringUrl
        
        //Get image from cache storage if available
        if let imageFromCache = imageCache.object(forKey: stringUrl as AnyObject){
            self.image=imageFromCache
            return
        }
        
        //No cached image from stringUrl available then request from url
        guard let url = URL(string: stringUrl) else {return}
        
        Alamofire.request(url).response { response in
            if response.error != nil{
                print(response.error.debugDescription)
                return
            }
            
            DispatchQueue.main.async {
                //Save image in cache with key name
                if let image = UIImage(data: response.data!){
                    
                    //Cache might be empty to show up the image for the first time load
                    if self.imageUrlString == stringUrl{
                        self.image = image
                    }
                    
                    imageCache.setObject(image, forKey:stringUrl as AnyObject)
                }
                
            }
        }
        
        return
    }

}



    


