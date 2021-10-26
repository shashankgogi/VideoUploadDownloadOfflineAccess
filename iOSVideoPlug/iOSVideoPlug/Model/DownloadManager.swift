//
//  DownloadManager.swift
//  iOSVideoPlug
//
//  Created by Rahul Panzade on 17/04/19.
//  Copyright © 2019 Omni-Bridge. All rights reserved.
//

import UIKit
import Alamofire

/// This is a class Which handle downloading with pause/resume feature
class DownloadManager: NSObject {
    
    // MARK:- Variables
    /**
     DownloadManager Singleton object
     */
    static let shared = DownloadManager()
    /**
     DownloadManager Singleton request
     */
    static var requestArray = [Int : Alamofire.Request?] ()
    /**
     UserDefaults Object
     */
    let userDefault = UserDefaults.standard
    
    /**
     This method is used to download the video.
     - Parameters:
     - videoModel: VideoDetails
     
     ### Usage Example: ###
     ````
     DownloadManager.shared.beginDownloadVideo(with videoModel : VideoDetails) {
     }
     ````
     */
    func beginDownloadVideo(with videoModel : VideoDetails) {
        
        let destination = self.getDistinationPath(videoName: videoModel.strVideoName)
        var downloadProgress = 0.0
        let videoInfo:[String: Int] = ["videoId":videoModel.id]
        DownloadManager.requestArray[videoModel.id] = Alamofire.download( URL(string: videoModel.strVideoUrl)!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil, to: destination).downloadProgress(closure: { (progress) in
            downloadProgress = progress.fractionCompleted
            CoreDataOperations.updateDownloadStatus(id: videoModel.id, progress: downloadProgress, status: "start")
            NotificationCenter.default.post(name: NSNotification.Name(DOWNLOAD_PAUSE_NOTIF_NAME), object: nil , userInfo : videoInfo)
        }).response(completionHandler: { (defaultDownloadResponse) in
            if defaultDownloadResponse.error == nil{
                CoreDataOperations.updateDownloadStatus(id: videoModel.id, progress: 1, status: "finish")
                DownloadManager.requestArray.removeValue(forKey: videoModel.id)
            }else if let downloadedData = defaultDownloadResponse.resumeData{
                self.userDefault.set(downloadedData, forKey: videoModel.strVideoUrl)
                CoreDataOperations.updateDownloadStatus(id: videoModel.id, progress: downloadProgress, status: "pause")
            }
            NotificationCenter.default.post(name: NSNotification.Name(DOWNLOAD_PAUSE_NOTIF_NAME), object: nil , userInfo : videoInfo)
        })
    }
    
    /**
     This method is used to save video at path.
     - Parameters:
     - videoName: videoName
     - returns: destination path
     */
    func getDistinationPath(videoName : String) -> DownloadRequest.DownloadFileDestination{
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let fileManager = FileManager.default
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            var fileURL = documentsURL.appendingPathComponent(DOWNLOAD_DIRECTORY)
            if !fileManager.fileExists(atPath: fileURL.path){
                try? fileManager.createDirectory(atPath: fileURL.path, withIntermediateDirectories: true, attributes: nil)
            }
            fileURL = fileURL.appendingPathComponent("\(videoName).mp4")
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        return destination
    }
    
    /**
     This method is used to resume downloading video.
     - Parameters:
     - videoModel: VideoDetails
     
     ### Usage Example: ###
     ````
     DownloadManager.shared.resumeDownloadingVideo(with videoModel : VideoDetails) {
     }
     ````
     */
    func resumeDownloadingVideo(with videoModel : VideoDetails) {
        
        guard  let data = self.userDefault.value(forKey: videoModel.strVideoUrl) as? Data else {
            return
        }
        var downloadProgress = 0.0
        let destination = self.getDistinationPath(videoName: videoModel.strVideoName)
        let videoInfo:[String: Int] = ["videoId":videoModel.id]
        DownloadManager.requestArray[videoModel.id] = Alamofire.download(resumingWith: data, to: destination).downloadProgress(closure: { (progress) in
            downloadProgress = progress.fractionCompleted
            CoreDataOperations.updateDownloadStatus(id: videoModel.id, progress: downloadProgress, status: "start")
            NotificationCenter.default.post(name: NSNotification.Name(DOWNLOAD_PAUSE_NOTIF_NAME), object: nil , userInfo : videoInfo)
        }).response(completionHandler: { (defaultDownloadResponse) in
            if defaultDownloadResponse.error == nil{
                self.userDefault.removeObject(forKey: videoModel.strVideoUrl)
                CoreDataOperations.updateDownloadStatus(id: videoModel.id, progress: 1, status: "finish")
                DownloadManager.requestArray.removeValue(forKey: videoModel.id)
            }else if let downloadedData = defaultDownloadResponse.resumeData{
                self.userDefault.set(downloadedData, forKey: videoModel.strVideoUrl)
                CoreDataOperations.updateDownloadStatus(id: videoModel.id, progress: downloadProgress, status: "pause")
            }
            NotificationCenter.default.post(name: NSNotification.Name(DOWNLOAD_PAUSE_NOTIF_NAME), object: nil , userInfo : videoInfo)
        })
    }
}


