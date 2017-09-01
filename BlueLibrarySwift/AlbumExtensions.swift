//
//  AlbumExtensions.swift
//  BlueLibrarySwift
//
//  Created by neal on 2017/9/1.
//  Copyright © 2017年 neal. All rights reserved.
//

import Foundation

extension Album {
    func ae_tableRepresentation() -> (titles:[String],value:[String]) {
        return (["Artist","Album","Genre","Year"],[artist,title,genre,year]);
    }
}
