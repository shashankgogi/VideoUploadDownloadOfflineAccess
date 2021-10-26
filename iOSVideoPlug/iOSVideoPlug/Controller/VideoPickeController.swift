//
//  ViewController.swift
//  iOSVideoPlug
//
//  Created by Rahul Panzade on 29/03/19.
//  Copyright © 2019 Omni-Bridge. All rights reserved.
//

import UIKit
import AVKit
import MobileCoreServices

/// Class for VideoPickeController
class VideoPickeController: VideoPickerClass , VideoPickerDelegates{
    
    // MARK:- View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            videoController.videoExportPreset = AVAssetExportPreset1920x1080
        }
        self.delegate = self
    }
    
    // MARK:- Button action methods
    @IBAction func pickVideoFromGallery(_sender : UIButton){
        openVideoGallery()
    }
    
    @IBAction func shootNewVideoUsingCamera(_sender : UIButton){
        openVideoCamera()
    }
    
    // MARK:- segue action
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PreviewSegue"{
            let previewVC = segue.destination as! PreviewController
            previewVC.strURL = strVideoUrl
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            backItem.tintColor = UIColor.black
            navigationItem.backBarButtonItem = backItem
        }
    }
    
    // MARK:- VideoPickerDelegates
    func isVideoSuccessfullyPickedUP(url: URL) {
        self.performSegue(withIdentifier: "PreviewSegue", sender: self)
    }
}




