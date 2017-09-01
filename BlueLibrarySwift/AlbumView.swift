//
//  AlbumView.swift
//  BlueLibrarySwift
//
//  Created by neal on 2017/9/1.
//  Copyright © 2017年 neal. All rights reserved.
//

import UIKit

class AlbumView: UIView {

    fileprivate var converImage : UIImageView!
    fileprivate var indicator :UIActivityIndicatorView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    init(frame: CGRect,albumCover:String) {
        super.init(frame: frame)
        commonInit()
        setupNotification(albumCover)
    }
    
    deinit {
        converImage.removeObserver(self, forKeyPath: "image")
    }
    
    func commonInit() -> Void {
        setupUI()
        setupComponents()
    }
    
    func highlightAlbum(_ didHighlishtView:Bool) -> Void {
        if didHighlishtView {
            backgroundColor = UIColor.white
        }else {
            backgroundColor = UIColor.black
        }
    }
    
    fileprivate func setupUI() {
        backgroundColor = UIColor.blue
    }
    
    fileprivate func setupComponents() -> Void {
        converImage = UIImageView(frame: CGRect(x: 5, y: 5, width: frame.size.width - 10, height: frame.size.height - 10))
        addSubview(converImage)
        
        indicator = UIActivityIndicatorView()
        indicator.center = center
        indicator.activityIndicatorViewStyle = .whiteLarge
        indicator.startAnimating()
        addSubview(indicator)
        converImage.addObserver(self, forKeyPath: "image", options: [], context: nil)
    }
    
    fileprivate func setupNotification(_ albumCover:String) -> Void {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: downloadImageNotification), object: self, userInfo: ["imageView":converImage,"converUrl": albumCover])
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "image" {
            indicator.stopAnimating()
        }
    }
}
