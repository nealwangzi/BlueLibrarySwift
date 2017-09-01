//
//  HorizontalScroller.swift
//  BlueLibrarySwift
//
//  Created by neal on 2017/9/1.
//  Copyright © 2017年 neal. All rights reserved.
//

import UIKit

@objc protocol HorizontalScrollerDelegate {
    
    func numberOfViewsForHorizontalScroller(_ scroller: HorizontalScroller) -> Int
    
    func horizontalScrollerViewAtIndex(_ scroller: HorizontalScroller, index: Int) -> UIView
    
    func horizontalScrollerClickedViewAtIndex(_ scroller: HorizontalScroller, index: Int)
    
    @objc optional func initialViewIndex(_ scroller:HorizontalScroller) -> Int
}

class HorizontalScroller: UIView {

    weak var delegate: HorizontalScrollerDelegate?
    
//    MARK: - 
    
    fileprivate let VIEW_PADDING = 10
    fileprivate let VIEW_DIMENTSIONS = 100
    fileprivate let VIEW_OFFSET = 100
    
    fileprivate var scroller: UIScrollView!
    
    var viewArray = [UIView]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeScrollView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeScrollView()
    }
    
    func initializeScrollView() -> Void {
        scroller = UIScrollView()
        scroller.delegate = self
        addSubview(scroller)
        
        scroller.translatesAutoresizingMaskIntoConstraints = false
        
        self.addConstraint(NSLayoutConstraint(item: scroller, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: scroller, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: scroller, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: scroller, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(HorizontalScroller.scrollerTapped(_:)))
        scroller.addGestureRecognizer(tapRecognizer)
    }
    
    override func didMoveToSuperview() {
        reload()
    }
    
    func scrollerTapped(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: gesture.view)
        
        guard let delegate = delegate else {
            return
        }
        
        for index in 0..<delegate.numberOfViewsForHorizontalScroller(self)  {
            let view = scroller.subviews[index]
            if view.frame.contains(location) {
                delegate.horizontalScrollerClickedViewAtIndex(self, index: index)
                
                scroller.setContentOffset(CGPoint(x: view.frame.origin.x - self.frame.size.width / 2 + view.frame.size.width / 2, y: 0), animated: true)
                
                break
            }
        }
    }
    
    func viewAtIndex(_ index: Int) -> UIView {
        return viewArray[index]
    }
    
    func reload() {
        if let delegate = delegate {
            viewArray = []
            
            let views: NSArray = scroller.subviews as NSArray
            
            for view in views {
                (view as AnyObject).removeFromSuperview()
            }
            
            var xValue = VIEW_OFFSET
            for index in 0..<delegate.numberOfViewsForHorizontalScroller(self) {
                xValue += VIEW_PADDING
                let view = delegate.horizontalScrollerViewAtIndex(self, index: index)
                view.frame = CGRect(x: CGFloat(xValue), y: CGFloat(VIEW_PADDING), width: CGFloat(VIEW_DIMENTSIONS), height: CGFloat(VIEW_DIMENTSIONS))
                scroller.addSubview(view)
                xValue += VIEW_DIMENTSIONS + VIEW_PADDING
                
                viewArray.append(view)
            }
            
            scroller.contentSize = CGSize(width: CGFloat(xValue + VIEW_OFFSET), height: frame.size.height)
            
            if let initialView = delegate.initialViewIndex?(self) {
                scroller.setContentOffset(CGPoint(x: CGFloat(initialView) * CGFloat(
                    (VIEW_DIMENTSIONS + (2 * VIEW_PADDING))), y: 0), animated: true)
            }
            
        }
    }
    
    func centerCurrentView() {
        var xFinal = Int(scroller.contentOffset.x) + (VIEW_OFFSET / 2) + VIEW_PADDING
        let viewIndex = xFinal / (VIEW_DIMENTSIONS + (2 * VIEW_PADDING))
        xFinal = viewIndex * (VIEW_DIMENTSIONS + (2 * VIEW_PADDING))
        scroller.setContentOffset(CGPoint(x: xFinal, y: 0), animated: true)
        if let delegate = delegate {
            delegate.horizontalScrollerClickedViewAtIndex(self, index: Int(viewIndex))
        }
    }
}


extension HorizontalScroller: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            centerCurrentView()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        centerCurrentView()
    }
}
