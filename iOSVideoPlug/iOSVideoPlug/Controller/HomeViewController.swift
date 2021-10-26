//
//  HomeViewController.swift
//  iOSVideoPlug
//
//  Created by Rahul Panzade on 02/04/19.
//  Copyright © 2019 Omni-Bridge. All rights reserved.
//

import UIKit
import Alamofire

/// Class for HomeViewController
class HomeViewController: HomeClass {
    
    // MARK:- Variables and Outlets
    /**
     UISegmentedControl outlet for segmentController
     */
    @IBOutlet weak var segmentController: UISegmentedControl!
    /**
     UISearchBar outlet for searchBar
     */
    @IBOutlet weak var searchBar: UISearchBar!
    /**
     UIButton outlet for btnForAddNewVideo
     */
    @IBOutlet weak var btnForAddNewVideo: UIButton!
    /**
     UITableView outlet for tableView
     */
    @IBOutlet weak var tableView: UITableView!
    /**
     UIActivityIndicatorView outlet for spinner
     */
    @IBOutlet weak var spinner : UIActivityIndicatorView!
    
    
    /**
     Bool flag of isServerHasMoreDataToFetch
     */
    var isServerHasMoreDataToFetch = true
    /**
     [Int:UIDownloadProgressButton] of progressButtonArray
     */
    var progressButtonArray = [Int:UIDownloadProgressButton]()
    /**
     [Int:UILabel] of progressLabelArray
     */
    var progressLabelArray = [Int:UILabel]()
    
    // MARK:- View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        baseSearchBar = searchBar
        baseTableView = tableView
        baseSpinner = spinner
        setShadowToAddNewVideoButton(button: self.btnForAddNewVideo)
        self.tableView.addSubview(self.refreshControl)
        //self.segmentController.addUnderlineForSelectedSegment()
        hideKeyboardWhenTappedAround()
        initNoResultFoundView(vc: self, frame: tableView.frame)
        fetchInitailData()
        //self.addNetworkChangedNotification()
        NotificationCenter.default.addObserver(self, selector: #selector(captureDownloadingNotification(notification: )), name: NSNotification.Name(rawValue: DOWNLOAD_PAUSE_NOTIF_NAME), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fetchInitailData), name: NSNotification.Name(rawValue: REFRESH_HOMEVIEW_NOTIF_NAME), object: nil)
    }
    
    /**
     used to fetch fresh data
     */
    @objc func fetchInitailData(){
        if Generals.isConnectedToNetwork() {
            uploadedVideoArray.removeAll()
            filteredUploadedVideoArray.removeAll()
            tableView.reloadData()
            fetchVideoAPI(skip: 0)
        }else{
            stopSpinner()
            loadOfflineVideoData()
            Generals.presentAlert(title: NOINTERNET_TITLE, msg: NOINTERNET_MESSAGE, VC: self)
        }
    }
    
    /**
     used to load offlone data
     */
    func loadOfflineVideoData(){
        isServerHasMoreDataToFetch = false
        //uploadedVideoArray = CoreDataOperations.fetchOfflineData() as! [VideoDetails]
        uploadedVideoArray = CoreDataOperations.fetchOfflineDownloadedVideoData() as! [VideoDetails]
        self.tableView.reloadData()
        if uploadedVideoArray.isEmpty{
            Generals.presentAlert(title: DONT_HAVE_OFFLINE_DATA_TITLE, msg: DONT_HAVE_OFFLINE_DATA_MSG, VC: self)
        }
    }
    
    /**
     used to combine server data with downloaded data
     */
    @objc func combinedOfflineDataWithServerData(){
        for index in 0..<uploadedVideoArray.count {
            if let offlineModel = CoreDataOperations.fetchOfflineVideoData(id: uploadedVideoArray[index].id){
                self.uploadedVideoArray[index] = offlineModel
            }
        }
    }
    
    /**
     used to handle pull to refresh
     */
    override func handleRefresh(_ refreshControl: UIRefreshControl) {
        if searchBar.text != ""{
            self.tableView.reloadData()
            refreshControl.endRefreshing()
            return
        }
        self.fetchInitailData()
        refreshControl.endRefreshing()
    }
    
    /**
     used to get cell index
     - Parameter :
     - videoId : videoId
     */
    func getCellIndex(videoId : Int) -> Int {
        for index in 0..<uploadedVideoArray.count{
            if uploadedVideoArray[index].id == videoId{
                return index
            }
        }
        return 0
    }
    
    /**
     used to capture download notification
     - Parameter :
     - notification : Notification
     */
    @objc func captureDownloadingNotification(notification : Notification){
        if let videoId = notification.userInfo?["videoId"] as? Int {
            let cellIndex = self.getCellIndex(videoId: videoId)
            if cellIndex >= uploadedVideoArray.count{
                return
            }
            
            if let offlineModel = CoreDataOperations.fetchOfflineVideoData(id: videoId){
                self.uploadedVideoArray[cellIndex] = offlineModel
                for indexPath in (tableView?.indexPathsForVisibleRows)!{
                    if indexPath.row == cellIndex && searchBar.text == ""{
                        let cell = tableView.cellForRow(at: IndexPath(row: cellIndex, section: 0)) as! TableViewCellForVideoDetails
                        self.progressButtonArray[videoId] = cell.btnForVideoProgress
                        self.progressLabelArray[videoId] = cell.lblForVideoProgress
                        DispatchQueue.main.async {
                            if offlineModel.status == "start"{
                                self.progressButtonArray[videoId]?.drawCircle()
                                self.progressButtonArray[videoId]?.status = .downloading
                                self.progressButtonArray[videoId]?.progress = offlineModel.progress
                                self.progressLabelArray[videoId]?.isHidden = false
                                self.progressLabelArray[videoId]?.text = "\(String(format: "%.2f", (offlineModel.progress * 100)))% Downloading"
                            }else if offlineModel.status == "finish"{
                                self.progressButtonArray[videoId]?.status = .downloaded
                                self.progressLabelArray[videoId]?.isHidden = true
                            }else if offlineModel.status == "pause"{
                                self.progressLabelArray[videoId]?.isHidden = false
                                self.progressButtonArray[videoId]?.status = .paused
                                self.progressButtonArray[videoId]?.progress = offlineModel.progress
                                self.progressLabelArray[videoId]?.text = "Downloading Paused"
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    /**
     Used to fet video details from server
     - Parameters:
     - skip: skip count
     */
    func fetchVideoAPI(skip : Int){
        startSpinner()
        getUploadedVideoDataFromServer(skip: skip) { (dataDict) in
            let videoDataArray = dataDict.value(forKey: "data") as? NSArray ?? NSArray()
            if videoDataArray.count == 0{
                self.stopSpinner()
                self.isServerHasMoreDataToFetch = false
                return
            }
            for videoData in videoDataArray {
                let model = VideoDetails(videoData as! [String : Any])
                self.uploadedVideoArray.append(model)
            }
            self.combinedOfflineDataWithServerData()
            self.stopSpinner()
            self.isServerHasMoreDataToFetch = true
            self.tableView.reloadData()
        }
    }
    
    // MARK:- Button action methods
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        sender.changeUnderlinePosition()
    }
    
    @IBAction func addNewVideoPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "AddNewVideoSegue", sender: self)
    }
    
    @objc func downloadPressed(_ sender : UIDownloadProgressButton){
        let videoData = uploadedVideoArray[sender.tag]
        if Generals.isConnectedToNetwork(){
            if uploadedVideoArray[sender.tag].status == "finish"{
                self.presentDeleteVideoAlert(videoDetails: videoData,index : sender.tag, isOffline: false)
            }else if uploadedVideoArray[sender.tag].status == "pause"{
                sender.status = .downloading
                DownloadManager.shared.resumeDownloadingVideo(with: videoData)
            }else if uploadedVideoArray[sender.tag].status == "start"{
                sender.status = .paused
                DownloadManager.requestArray[videoData.id]!?.cancel()
            }else{
                sender.status = .downloading
                CoreDataOperations.saveDownloadStatus(videoModel: videoData)
                DownloadManager.shared.beginDownloadVideo(with: videoData)
            }
            self.progressButtonArray[videoData.id] = sender
            self.progressLabelArray[videoData.id] = (tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! TableViewCellForVideoDetails).lblForVideoProgress
        }else if uploadedVideoArray[sender.tag].status == "finish"{
            self.presentDeleteVideoAlert(videoDetails: videoData,index : sender.tag, isOffline: true)
        }else{
            Generals.presentAlert(title: NOINTERNET_TITLE, msg: NOINTERNET_MESSAGE, VC: self)
        }
    }
    
    
    /**
     Used to present delete confirm alert
     - Parameters:
     - videoDetails: videoDetails
     - index: index
     - isOffline: isOffline flag
     */
    func presentDeleteVideoAlert(videoDetails : VideoDetails, index : Int,isOffline : Bool){
        let alertVc = UIAlertController(title: DELETE_VIDEO_TITLE, message: DELETE_DOWNLOADING_VIDEO_MSG, preferredStyle: UIAlertController.Style.alert)
        alertVc.addAction(UIAlertAction(title: "No Thanks!", style: UIAlertAction.Style.cancel, handler: nil))
        alertVc.addAction(UIAlertAction(title: "Yes Sure!", style: UIAlertAction.Style.default, handler: { (action) in
            let strUrl = Generals.GetURLOfFileFromDocumentDirectory(fileName: "\(videoDetails.strVideoName).mp4")
            try? FileManager.default.removeItem(atPath: strUrl)
            CoreDataOperations.deleteDownloadedData(videoId: videoDetails.id)
            if isOffline{
                self.uploadedVideoArray.remove(at: index)
                self.tableView.reloadData()
            }else{
                self.uploadedVideoArray[index].status = "none"
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: UITableView.RowAnimation.none)
            }
        }))
        self.present(alertVc, animated: true, completion: nil)
    }
    
    // MARK:- Segue action
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        backItem.tintColor = UIColor.black
        navigationItem.backBarButtonItem = backItem
    }
}

// MARK: - UITableViewDataSource
extension HomeViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if checkSearchBarStatusActive() {
            return filteredUploadedVideoArray.count
        }
        return uploadedVideoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == uploadedVideoArray.count - 1 && isServerHasMoreDataToFetch {
            self.fetchVideoAPI(skip: uploadedVideoArray.count)
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as! TableViewCellForVideoDetails
        cell.btnForVideoProgress.tag = indexPath.row
        cell.btnForVideoProgress.addTarget(self, action: #selector(downloadPressed(_:)), for: UIControl.Event.touchUpInside)
        if checkSearchBarStatusActive(){
            cell.configure(videoModel: filteredUploadedVideoArray[indexPath.row])
            cell.btnForVideoProgress.isHidden = true
            cell.lblForVideoProgress.isHidden = true
        }else{
            cell.configure(videoModel: uploadedVideoArray[indexPath.row])
            cell.btnForVideoProgress.isHidden = false
            cell.lblForVideoProgress.isHidden = false
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension HomeViewController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        if searchBar.text != "" && Generals.isConnectedToNetwork(){
            if filteredUploadedVideoArray[indexPath.row].status == "finish"{
                playOfflineVideo(name: filteredUploadedVideoArray[indexPath.row].strVideoName)
            }else{
                playOnlineVideo(url:filteredUploadedVideoArray[indexPath.row].strVideoUrl)
            }
        }else if Generals.isConnectedToNetwork(){
            if uploadedVideoArray[indexPath.row].status == "finish"{
                playOfflineVideo(name: uploadedVideoArray[indexPath.row].strVideoName)
            }else{
                playOnlineVideo(url:uploadedVideoArray[indexPath.row].strVideoUrl)
            }
        }else{
            if uploadedVideoArray[indexPath.row].status == "finish"{
                playOfflineVideo(name: uploadedVideoArray[indexPath.row].strVideoName)
            }else{
                Generals.presentAlert(title: NOINTERNET_TITLE, msg: NOINTERNET_MESSAGE, VC: self)
            }
        }
    }
}

/*
 // MARK: - Used to network notifications
 extension  HomeViewController {
 func addNetworkChangedNotification(){
 NotificationCenter.default.addObserver(self, selector: #selector(appWentToOffilne(notification:)), name: NSNotification.Name(rawValue: REACHABILITY_NOTIF_NAME), object: nil)
 }
 
 @objc func appWentToOffilne(notification : Notification){
 DownloadManager.request?.cancel()
 }
 }
 */
