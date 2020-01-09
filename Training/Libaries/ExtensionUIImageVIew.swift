//
//  ExtensionUIImageVIew.swift
//  Training
//
//  Created by ManhLD on 1/6/20.
//  Copyright © 2020 ManhLD. All rights reserved.
//

import Foundation
import UIKit


var imageCache = NSCache<NSString, AnyObject>()

extension UIImageView {
    public func roundCorners() {
        let maskPath1 = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topLeft , .topRight], cornerRadii: CGSize(width: 20, height: 20))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }
    
    public func loadImage(urlString : String) {
        let url = URL(string: urlString)
        
        if let imageFromCache = imageCache.object(forKey: urlString as NSString) as? UIImage {
              self.image = imageFromCache
              return
        }
        
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, respones, error) in
                 
                 if error != nil {
                     print(error!)
                     return
                 }
                 
            DispatchQueue.main.async {
                     
                let imageToCache = UIImage(data: data!)
                self.image = imageToCache

                imageCache.setObject(imageToCache!, forKey: urlString as NSString)
            }
            
        }).resume()
              
//        let queue = DispatchQueue(label: "loadIMGNEWS")
//        queue.async {
//            if url != nil {
//                do {
//                    if let data = try? Data(contentsOf: url!) {
//                        if let image = UIImage(data: data) {
//                            DispatchQueue.main.async {
//                                self.image = image
//                            }
//                        }
//                    }
//                } 
//            }
//        }
    }
}

class ImageLoader {

    var cache = NSCache<AnyObject, AnyObject>()
    

    class var getInstance : ImageLoader {
        struct Static {
            static let instance : ImageLoader = ImageLoader()
        }
        return Static.instance
    }

    func imageForUrl(urlString: String, completionHandler: @escaping (_ image: UIImage?, _ url: String) -> ()) {
        
        let data: Data? = self.cache.object(forKey: urlString as AnyObject) as? Data

        if let imageData = data {
            let image = UIImage(data: imageData)
            DispatchQueue.main.async {
                completionHandler(image, urlString)
            }
            return
        }

        let downloadTask = URLSession.shared.dataTask(with: URL(string: urlString)!) { [weak self] (data, response, error) in
            if error == nil {
                if data != nil {
                    let image = UIImage(data: data!)
                    self?.cache.setObject(data! as AnyObject, forKey: urlString as AnyObject)
                    DispatchQueue.main.async {
                        completionHandler(image, urlString)
                    }
                }
            } else {
                completionHandler(nil, urlString)
            }
        }
        downloadTask.resume()
    }
    
    

}

