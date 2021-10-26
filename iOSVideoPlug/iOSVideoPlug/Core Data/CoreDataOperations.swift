//
//  CoreDataOperations.swift
//  iOSVideoPlug
//
//  Created by Rahul Panzade on 17/04/19.
//  Copyright © 2019 Omni-Bridge. All rights reserved.
//

import UIKit
import CoreData

class CoreDataOperations: NSObject {
    // MARK:- Downloading Status
    
    /// Used to save downloading status into DownloadingStatus table
    ///
    /// - Parameter videoModel: VideoDetails
    class func saveDownloadStatus(videoModel : VideoDetails){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        let entity = NSEntityDescription.entity(forEntityName: "VideoDetailsData", in: context)
        let downStatus = NSManagedObject(entity: entity!, insertInto: context)
        /*
         id integer16
         size integer64
         status String
         thumbnailUrl String
         timestamp integer64
         title String
         videoUrl String
         
         1.start
         2.pause
         3.finish
         4.none
         */
        downStatus.setValue(videoModel.id, forKey: "id")
        downStatus.setValue(videoModel.size, forKey: "size")
        downStatus.setValue("none", forKey: "status")
        downStatus.setValue(videoModel.strThubnailUrl, forKey: "thumbnailUrl")
        downStatus.setValue(videoModel.timestamp, forKey: "timestamp")
        downStatus.setValue(videoModel.strVideoName, forKey: "title")
        downStatus.setValue(videoModel.strVideoUrl, forKey: "videoUrl")
        downStatus.setValue(0.0, forKey: "progress")
        do {
            try context.save()
        } catch {
            print("Failed to save")
        }
    }
    
    /// Used to delete downloading data
    ///
    /// - Parameter videoId: videoId
    class func deleteDownloadedData(videoId : Int){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let manageContex = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "VideoDetailsData")
        request.predicate = NSPredicate(format: "id == \(videoId)", 0)
        
        if let result = try? manageContex.fetch(request){
            for object in result{
                manageContex.delete(object as! NSManagedObject)
            }
        }
        do{
            try manageContex.save()
        }catch{
            print("failed to delete")
        }
    }
    
    /// Used to update downloading status
    ///
    /// - Parameters:
    ///   - id: id
    ///   - progress: progress
    ///   - status: status
    class func updateDownloadStatus(id : Int ,progress : Double, status : String){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "VideoDetailsData")
        request.predicate = NSPredicate(format: "id == \(id)", 0)
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                data.setValue(status, forKey: "status")
                data.setValue(progress, forKey: "progress")
            }
            try context.save()
        } catch {
            print("Failed")
        }
    }
    
    /// Used to pause all downloading
    class func pauseAllDownloading(){
        let appDelegates = UIApplication.shared.delegate as! AppDelegate
        let contex = appDelegates.persistentContainer.viewContext
        let reuest = NSFetchRequest<NSFetchRequestResult>(entityName: "VideoDetailsData")
        reuest.predicate = NSPredicate(format: "status == 'start'", 0)
        reuest.returnsObjectsAsFaults = false
        do{
            let result = try contex.fetch(reuest)
            for data in result as! [NSManagedObject]{
                data.setValue("pause", forKey: "status")
                try contex.save()
            }
        }catch{
            print("failed")
        }
    }
    
    
    /// used to get offline downloaded data
    ///
    /// - Parameter id: id
    /// - Returns: VideoDetails
    class func fetchOfflineVideoData(id : Int) -> VideoDetails?{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "VideoDetailsData")
        request.predicate = NSPredicate(format: "id == \(id)", 0)
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                let offlineVideoDict = NSMutableDictionary()
                offlineVideoDict.setValue(data.value(forKey: "id"), forKey: "id")
                offlineVideoDict.setValue(data.value(forKey: "size"), forKey: "sizeInBytes")
                offlineVideoDict.setValue(data.value(forKey: "status"), forKey: "status")
                offlineVideoDict.setValue(data.value(forKey: "thumbnailUrl"), forKey: "thumbnailUrl")
                offlineVideoDict.setValue(data.value(forKey: "timestamp"), forKey: "timestamp")
                offlineVideoDict.setValue(data.value(forKey: "title"), forKey: "videoTitle")
                offlineVideoDict.setValue(data.value(forKey: "videoUrl"), forKey: "videoURL")
                offlineVideoDict.setValue(data.value(forKey: "progress"), forKey: "progress")
                return VideoDetails(offlineVideoDict as! [String : Any])
            }
        } catch {
            print("Failed")
        }
        return nil
    }
    
    
    /// used to get offline downloaded data
    ///
    /// - Returns: VideoDetails Array
    class func fetchOfflineData() -> NSArray{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "VideoDetailsData")
        request.returnsObjectsAsFaults = false
        let offlineArr = NSMutableArray()
        do {
            let result = try context.fetch(request)
            print(result.count)
            for data in result as! [NSManagedObject] {
                let offlineVideoDict = NSMutableDictionary()
                offlineVideoDict.setValue(data.value(forKey: "id"), forKey: "id")
                offlineVideoDict.setValue(data.value(forKey: "size"), forKey: "sizeInBytes")
                offlineVideoDict.setValue(data.value(forKey: "status"), forKey: "status")
                offlineVideoDict.setValue(data.value(forKey: "thumbnailUrl"), forKey: "thumbnailUrl")
                offlineVideoDict.setValue(data.value(forKey: "timestamp"), forKey: "timestamp")
                offlineVideoDict.setValue(data.value(forKey: "title"), forKey: "videoTitle")
                offlineVideoDict.setValue(data.value(forKey: "videoUrl"), forKey: "videoURL")
                offlineVideoDict.setValue(data.value(forKey: "progress"), forKey: "progress")
                
                offlineArr.add(VideoDetails(offlineVideoDict as! [String : Any]))
            }
        } catch {
            print("Failed")
        }
        return offlineArr
    }
    
    /// used to get offline downloaded data
    ///
    /// - Returns: VideoDetails Array
    class func fetchOfflineDownloadedVideoData() -> NSArray{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "VideoDetailsData")
        request.predicate = NSPredicate(format: "status == 'finish'", 0)
        request.returnsObjectsAsFaults = false
        let offlineArr = NSMutableArray()
        do {
            let result = try context.fetch(request)
            print(result.count)
            for data in result as! [NSManagedObject] {
                let offlineVideoDict = NSMutableDictionary()
                offlineVideoDict.setValue(data.value(forKey: "id"), forKey: "id")
                offlineVideoDict.setValue(data.value(forKey: "size"), forKey: "sizeInBytes")
                offlineVideoDict.setValue(data.value(forKey: "status"), forKey: "status")
                offlineVideoDict.setValue(data.value(forKey: "thumbnailUrl"), forKey: "thumbnailUrl")
                offlineVideoDict.setValue(data.value(forKey: "timestamp"), forKey: "timestamp")
                offlineVideoDict.setValue(data.value(forKey: "title"), forKey: "videoTitle")
                offlineVideoDict.setValue(data.value(forKey: "videoUrl"), forKey: "videoURL")
                offlineVideoDict.setValue(data.value(forKey: "progress"), forKey: "progress")
                
                offlineArr.add(VideoDetails(offlineVideoDict as! [String : Any]))
            }
        } catch {
            print("Failed")
        }
        return offlineArr
    }
}
