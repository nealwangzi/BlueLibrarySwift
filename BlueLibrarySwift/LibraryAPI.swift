//
//  LibraryAPI.swift
//  BlueLibrarySwift
//
//  Created by neal on 2017/9/1.
//  Copyright © 2017年 neal. All rights reserved.
//

import UIKit

class LibraryAPI: NSObject {

    static let shareInstance = LibraryAPI()
    
    fileprivate let persistencyManager: PersistencyManager
    fileprivate let httpClient: HTTPClient
    fileprivate let isOnline: Bool
    
    fileprivate override init() {
        persistencyManager = PersistencyManager()
        httpClient = HTTPClient()
        isOnline = false
        
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(LibraryAPI.downloadImage(_:)), name: NSNotification.Name(rawValue:downloadImageNotification), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
//    MARK:- Public API

    
    func getAlbums() -> [Album] {
        return persistencyManager.getAlbums()
    }
    
    func addAlbum(_ album:Album,index: Int) -> Void {
        persistencyManager.addAlbum(album, index: index)
        if isOnline {
            let _ = httpClient.postRequest("/api/addAlbum", body: album.description)
        }
    }
    
    func deleteAlbum(_ index:Int) -> Void {
        persistencyManager.deleteAlbumAtIndex(index)
        if isOnline {
            let _ = httpClient.postRequest("api/deleteAlbum", body: "\(index)")
        }
    }
    
    func downloadImage(_ notification: Notification) -> Void {
        let userInfo = (notification as Notification).userInfo as! [String:AnyObject]
        let imageView = userInfo["imageView"] as! UIImageView?
        let converUrl = userInfo["converUrl"] as! String
        
        if let imageViewUnWrapped = imageView {
            imageViewUnWrapped.image = persistencyManager.getImage(URL(string: converUrl)!.lastPathComponent)
            
            if imageViewUnWrapped.image == nil {
                DispatchQueue.global().async {
                    let downloadedImage = self.httpClient.downloadImage(converUrl as String)
                    DispatchQueue.main.async {
                        imageViewUnWrapped.image = downloadedImage
                        self.persistencyManager.saveImage(downloadedImage, filename: URL(string: converUrl)!.lastPathComponent)
                    }
                }
            }
        }
    }
    
    func saveAlbums() -> Void {
        persistencyManager.saveAlbums()
    }
}
