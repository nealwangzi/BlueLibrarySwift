//
//  Album.swift
//  BlueLibrarySwift
//
//  Created by neal on 2017/9/1.
//  Copyright © 2017年 neal. All rights reserved.
//

import UIKit

class Album: NSObject,NSCoding {
    var title: String!
    var artist: String!
    var genre: String!
    var converUrl:String!
    var year: String!
    
    init(title:String , artist:String , genre:String, converUrl: String , year: String) {
        super.init()
        
        self.title = title
        self.artist = artist
        self.genre = genre
        self.converUrl = converUrl
        self.year = year
    }
    
    override var description: String {
        return "title:\(title)" + "artist:\(artist)" + "genre:\(genre)" + "converUrl:\(converUrl)" + "year:\(year)"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        self.title = aDecoder.decodeObject(forKey:"title") as! String
        self.artist = aDecoder.decodeObject(forKey: "artist") as! String
        self.genre = aDecoder.decodeObject(forKey: "genre") as! String
        self.converUrl = aDecoder.decodeObject(forKey: "converUrl") as! String
        self.year = aDecoder.decodeObject(forKey: "year") as! String
    }
    
//    will be called when album to be achived
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: "title")
        aCoder.encode(artist, forKey: "artist")
        aCoder.encode(genre, forKey: "genre")
        aCoder.encode(converUrl, forKey: "converUrl")
        aCoder.encode(year, forKey: "year")
    }
}
