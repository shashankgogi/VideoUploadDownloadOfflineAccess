//
//  Generals.swift
//  iOSVideoPlug
//
//  Created by Rahul Panzade on 03/04/19.
//  Copyright © 2019 Omni-Bridge. All rights reserved.
//

import UIKit
import SystemConfiguration

/// Class for Generals
class Generals {
    /**
     Used to pause all downloadings
     ### Usage Example: ###
     ````
     Generals.pausedlAllDownloading{
     }
     ````
     */
    
    class func pausedlAllDownloading(){
        for request in DownloadManager.requestArray{
            request.value?.cancel()
        }
    }
    
    
    /**
     Used to present alert
     - Parameters:
     - title: title
     - msg: msg
      - VC: View controller
     
     ### Usage Example: ###
     ````
     Generals.presentAlert(title : String,msg: String, VC:UIViewController) {
     }
     ````
     */
 
    class func presentAlert(title : String,msg: String, VC:UIViewController){
        let alertVc = UIAlertController(title: title, message: msg, preferredStyle: UIAlertController.Style.alert)
        alertVc.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.cancel, handler: nil))
        VC.present(alertVc, animated: true, completion: nil)
    }
    
    
    /**
     used to GetURLOfFileFromDocumentDirectory
     - Parameters:
     - fileName: file name
     - Returns: DocumentDirectory path
     ### Usage Example: ###
     ````
     Generals.GetURLOfFileFromDocumentDirectory(fileName : String){
     }
     ````
     */
    class func GetURLOfFileFromDocumentDirectory(fileName : String) -> String{
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePathUrl = documentsURL.appendingPathComponent(DOWNLOAD_DIRECTORY)
        let filePath = filePathUrl.appendingPathComponent(fileName).path
        return filePath
    }
    /**
     Used to check connectivity
     - Parameters:
     - Returns: flag
     ### Usage Example: ###
     ````
     Generals.isConnectedToNetwork(){
     }
     ````
     */
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let isConnected = (isReachable && !needsConnection)
        
        return isConnected
    }
}
