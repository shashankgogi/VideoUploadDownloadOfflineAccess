//
//  HomeClass.swift
//  iOSVideoPlug
//
//  Created by Rahul Panzade on 09/04/19.
//  Copyright © 2019 Omni-Bridge. All rights reserved.
//

import UIKit
import Alamofire
import AVKit

/// Class for HomeClass
class HomeClass: UIViewController {
    
    // MARK:- Variables
    
    /**
     UIView declaration for viewForNoResultFound
     */
    var viewForNoResultFound : UIView!
    /**
     [VideoDetails] declaration for uploadedVideoArray
     */
    var uploadedVideoArray = [VideoDetails]()
    /**
     [VideoDetails] object for filteredUploadedVideoArray
     */
    var filteredUploadedVideoArray = [VideoDetails]()
    /**
     UITableView declaration for baseTableView
     */
    var baseTableView : UITableView! = nil
    /**
     UISearchBar declaration for baseSearchBar
     */
    var baseSearchBar : UISearchBar! = nil
    /**
     UIActivityIndicatorView declaration for baseSpinner
     */
    var baseSpinner : UIActivityIndicatorView! = nil
    
    /**
     UIRefreshControl lazy declaration for refreshControl
     */
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(handleRefresh(_:)),
                                 for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.red
        return refreshControl
    }()
    
    /**
     used to handle pull to refresh
     - Parameter :
     - refreshControl: UIRefreshControl
     */
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {}
    /**
     used to add no result found view
     - Parameter :
     - vc: VC
     - frame: frame
     */
    func initNoResultFoundView(vc : UIViewController , frame : CGRect){
        let controller = storyboard!.instantiateViewController(withIdentifier: "NoResultFoundViewController") as! NoResultFoundController
        viewForNoResultFound = controller.view
        viewForNoResultFound.frame.origin.y = frame.origin.y
        vc.view.addSubview(controller.view)
        viewForNoResultFound.isHidden = true
    }
    
    /**
     Used to start spinner
     */
    func stopSpinner(){
        self.view.isUserInteractionEnabled = true
        baseSpinner.isHidden = true
        baseSpinner.stopAnimating()
    }
    
    /**
     Used to stop spinner
     */
    func startSpinner(){
        self.view.isUserInteractionEnabled = false
        baseSpinner.isHidden = false
        baseSpinner.startAnimating()
    }
    
    /**
     Used to check search bar is active or having search text
     - Returns: result
     */
    func checkSearchBarStatusActive() -> Bool {
        if baseSearchBar.isFirstResponder && baseSearchBar.text != "" {
            return true
        }else {
            return false
        }
    }
    
    /**
     Used get list of uploaded video
     - Parameter :
     - comletion: comletion closure
     */
    func getUploadedVideoDataFromServer(skip : Int, comletion : @escaping (NSDictionary)->Void){
        Alamofire.request("\(UserDefaults.standard.value(forKey: "StartURLFromServer") ?? "")\(GET_VIDEO_LIST_PATH)?skip=\(skip)&take=\(PER_PAGE_TAKE_COUNT)").validate().responseJSON { (json) in
            if let jsonDict = json.result.value as? NSDictionary {
                comletion(jsonDict)
            }else{
                comletion(NSDictionary())
            }
        }
    }
    
    /**
     Used to add 3D effect on button
     - Parameter :
     - button: button
     */
    func setShadowToAddNewVideoButton(button : UIButton){
        button.clipsToBounds = false
        button.layer.shadowOffset = CGSize(width: 0, height: 5.5)
        button.layer.shadowOpacity = 1
        button.layer.shadowRadius = 4.0
        button.layer.shadowColor = UIColor.gray.cgColor
    }
    
    /**
     Used to open player with playing video
     - Parameter :
     - url: videoURL
     */
    func playOnlineVideo(url : String){
        let videoURL = URL(string: url)
        if let videoURL = videoURL{
            let player = AVPlayer(url: videoURL)
            let playerController = AVPlayerViewController()
            playerController.player = player
            self.present(playerController, animated: true) {
                player.play()
            }
        }
    }
    
    /**
     used to play local Video
     - Parameter :
     - name: name
     */
    func playOfflineVideo(name : String) {
        let thumUrl = Generals.GetURLOfFileFromDocumentDirectory(fileName: "\(name).mp4")
        let player = AVPlayer(url: URL(fileURLWithPath: thumUrl))
        let playerController = AVPlayerViewController()
        playerController.player = player
        present(playerController, animated: true) {
            player.play()
        }
    }
    
    /**
     Used to filter the video details on search text based.
     - Parameter :
     - searchText: filter text
     */
    func filterVideosList(_ searchText: String) {
        for videoDetails in uploadedVideoArray{
            if (videoDetails.strVideoName).lowercased().contains(searchText.lowercased()) {
                filteredUploadedVideoArray.append(videoDetails)
            }
        }
        if filteredUploadedVideoArray.count == 0 && baseSearchBar.text != "" {
            viewForNoResultFound.isHidden = false
        }else {
            viewForNoResultFound.isHidden = true
        }
        baseTableView.reloadData()
        if filteredUploadedVideoArray.count > 0{
            self.baseTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
}


// MARK: - UISearchBar Delegate

extension HomeClass : UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredUploadedVideoArray.removeAll()
        self.filterVideosList(searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
