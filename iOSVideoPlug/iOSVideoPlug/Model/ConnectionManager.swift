//
//  ConnectionManager.swift
//  iOSVideoPlug
//
//  Created by Rahul Panzade on 17/04/19.
//  Copyright © 2019 Omni-Bridge. All rights reserved.
//

import UIKit
import Reachability
/// This is a class Which handle network changes
class ConnectionManager {
    /**
     ConnectionManager Singleton object
     */
    static let sharedInstance = ConnectionManager()
    /**
     Reachability declaration
     */
    private var reachability : Reachability!
    
    /**
     This method is used to add observer.
     - Parameters:
     
     ### Usage Example: ###
     ````
     ConnectionManager.sharedInstance.observeReachability {
     }
     ````
     */
    func observeReachability(){
        self.reachability = Reachability()
        NotificationCenter.default.addObserver(self, selector:#selector(self.reachabilityChanged), name: NSNotification.Name.reachabilityChanged, object: nil)
        do {
            try self.reachability.startNotifier()
        }
        catch(let error) {
            print("Error occured while starting reachability notifications : \(error.localizedDescription)")
        }
    }
    
    /**
     This method is used to handle change in network.
     - Parameters:
     - note: Notification
     */
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        switch reachability.connection {
        case .cellular:
            print("Network available via Cellular Data.")
            break
        case .wifi:
            print("Network available via WiFi.")
            break
        case .none:
            Generals.pausedlAllDownloading()
            print("Network is not available.")
            break
        }
    }
}

