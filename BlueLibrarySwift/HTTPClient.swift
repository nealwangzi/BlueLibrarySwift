//
//  HTTPClient.swift
//  BlueLibrarySwift
//
//  Created by neal on 2017/9/1.
//  Copyright © 2017年 neal. All rights reserved.
//

import UIKit

class HTTPClient: NSObject {
    func getRequest(_ url:String) -> (AnyObject) {
        return Data() as AnyObject
    }

    func postRequest(_ url:String,body:String) -> (AnyObject) {
        return Data() as AnyObject
    }
    
    func downloadImage(_ url: String) -> (UIImage) {
        let aUrl = URL(string: url)
        
        guard let data = try? Data(contentsOf: aUrl!) else {
            return UIImage()
        }
        
        let image = UIImage(data: data)
        return image!
    
    }
}
