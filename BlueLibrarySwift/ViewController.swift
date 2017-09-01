//
//  ViewController.swift
//  BlueLibrarySwift
//
//  Created by neal on 2017/9/1.
//  Copyright © 2017年 neal. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var dataTable: UITableView!
    @IBOutlet weak var toobar: UIToolbar!
    @IBOutlet weak var scroller: HorizontalScroller!
    
    fileprivate var allAlbums = [Album]()
    fileprivate var currentAlbumData : (titles:[String] , value:[String])?
    fileprivate var currentAlbumIndex = 0
    
    fileprivate var undoStack:[(Album, Int)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupUI()
        setupData()
        setupComponents()
        showDataForAlbum(currentAlbumIndex)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.saveCurrentState), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupUI() {
        navigationController?.navigationBar.isTranslucent = false
    }
    
    func setupData() {
        currentAlbumIndex = 0
        allAlbums = LibraryAPI.shareInstance.getAlbums()
    }
    
    func setupComponents() {
        dataTable.backgroundView = nil
        loadPreviousState()
        scroller.delegate = self
        reloadScroller()
        
        let undoButton = UIBarButtonItem(barButtonSystemItem: .undo, target: self, action: #selector(ViewController.undoAction))
        undoButton.isEnabled = false
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let trashButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(ViewController.deleteAlbum))
        let toobarButtonItems = [undoButton,space,trashButton]
        toobar.setItems(toobarButtonItems, animated: true)
    }
    
    func showDataForAlbum(_ index:Int) {
        if index < allAlbums.count && index > -1 {
            let album = allAlbums[index]
            currentAlbumData = album.ae_tableRepresentation()
        }else {
            currentAlbumData = nil
        }
        
        if let dataTable = dataTable {
            dataTable.reloadData()
        }
    }
    
    
//   MARK:
    
    func saveCurrentState() {
        UserDefaults.standard.set(currentAlbumIndex, forKey: "currentAlbumIndex")
        LibraryAPI.shareInstance.saveAlbums()
    }
    
    func loadPreviousState() {
        currentAlbumIndex = UserDefaults.standard.integer(forKey: "currentAlbumIndex")
        showDataForAlbum(currentAlbumIndex)
    }

    func reloadScroller() {
        allAlbums = LibraryAPI.shareInstance.getAlbums()
        if currentAlbumIndex < 0 {
            currentAlbumIndex = 0
        }else if currentAlbumIndex >= allAlbums.count {
            currentAlbumIndex = allAlbums.count - 1
        }
        
        scroller.reload()
        showDataForAlbum(currentAlbumIndex)
    }
    
    func addAlbumAtIndex(_ album: Album, index: Int) {
        LibraryAPI.shareInstance.addAlbum(album, index: index)
        currentAlbumIndex = index
        reloadScroller()
    }
    
    func deleteAlbum() {
        let deleteAlbum: Album = allAlbums[currentAlbumIndex]
        
        let undoAction = (deleteAlbum, currentAlbumIndex)
        undoStack.insert(undoAction, at: 0)
        
        LibraryAPI.shareInstance.deleteAlbum(currentAlbumIndex)
        reloadScroller()
        
        let barButtonItems = toobar.items! as [UIBarButtonItem]
        let undoButton:UIBarButtonItem = barButtonItems[0]
        undoButton.isEnabled = true
        if allAlbums.count == 0 {
            let trashButton:UIBarButtonItem = barButtonItems[2]
            trashButton.isEnabled = false
        }
    }
    
    func undoAction() {
        let barButtonItems = toobar.items! as [UIBarButtonItem]
        
        if undoStack.count > 0 {
            let (deletedAlbum , index) = undoStack.remove(at: 0)
            addAlbumAtIndex(deletedAlbum, index: index)
        }
        
        if undoStack.count == 0 {
            let undoButton: UIBarButtonItem = barButtonItems[0]
            undoButton.isEnabled = false
        }
        
        let transhButton: UIBarButtonItem = barButtonItems[2]
        transhButton.isEnabled = true
        
    }
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let albumData = currentAlbumData {
            return albumData.titles.count
        }else {
        return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        if let albumData = currentAlbumData {
            cell.textLabel?.text = albumData.titles[(indexPath as NSIndexPath).row]
            cell.detailTextLabel?.text = albumData.value[(indexPath as NSIndexPath).row]
        }
        
        return cell
    }
}
//MARK: - HorizontalScroller
extension ViewController:HorizontalScrollerDelegate {
    func numberOfViewsForHorizontalScroller(_ scroller: HorizontalScroller) -> Int {
        return allAlbums.count
    }
    
    func horizontalScrollerViewAtIndex(_ scroller: HorizontalScroller, index: Int) -> UIView {
        let album = allAlbums[index]
        let albumView = AlbumView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), albumCover: album.converUrl)
        
        if currentAlbumIndex == index {
            albumView.highlightAlbum(true)
        }else {
            albumView.highlightAlbum(false)
        }
        
        return albumView
    }
    
    func horizontalScrollerClickedViewAtIndex(_ scroller: HorizontalScroller, index: Int) {
        let previousAlbumView = scroller.viewAtIndex(currentAlbumIndex) as! AlbumView
        previousAlbumView.highlightAlbum(false)
        
        currentAlbumIndex = index
        
        let albumView = scroller.viewAtIndex(currentAlbumIndex) as! AlbumView
        albumView.highlightAlbum(true)
        
        showDataForAlbum(currentAlbumIndex)
        
    }
    
    func initialViewIndex(_ scroller: HorizontalScroller) -> Int {
        return currentAlbumIndex
    }
}

