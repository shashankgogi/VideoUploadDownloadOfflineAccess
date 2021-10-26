//
//  VideoDetails.swift
//  iOSVideoPlug
//
//  Created by Rahul Panzade on 02/04/19.
//  Copyright © 2019 Omni-Bridge. All rights reserved.
//

import UIKit

/// This is a VideoDetails Model.
struct VideoDetails {
    /**
     Video object Id
     */
    let id : Int
    /**
     Video name
     */
    let strVideoName : String
    /**
     video size in bytes
     */
    let size : Int
    /**
     Video thumbnail image url
     */
    let strThubnailUrl : String
    /**
     Video download progress 0 to 1.0
     */
    let progress : Float
    /**
     Downloading status
     */
    var status : String
    /**
     Video url
     */
    let strVideoUrl : String
    /**
     Video timestampp
     */
    let timestamp : Int
    
    /**
     This parameterise init.
     */
    init(_ dictionary : [String : Any]) {
        self.id = dictionary["id"] as? Int ?? 0
        self.strVideoName = dictionary["videoTitle"] as? String  ?? ""
        self.strVideoUrl = dictionary["videoURL"] as? String  ?? ""
        self.size = dictionary["sizeInBytes"] as? Int ?? 0
        self.strThubnailUrl = dictionary["thumbnailUrl"] as? String ?? ""
        self.progress = Float(dictionary["progress"] as? Double ?? 0)
        self.status = dictionary["status"] as? String  ?? "none"
        self.timestamp = dictionary["timestamp"] as? Int ?? 0
    }
    
}
