//
//  VideoPickerClass.swift
//  iOSVideoPlug
//
//  Created by Rahul Panzade on 05/04/19.
//  Copyright © 2019 Omni-Bridge. All rights reserved.
//

import UIKit
import AVKit
import MobileCoreServices

/// Class for VideoPickerClass
class VideoPickerClass: UIViewController {
    
    // MARK:- Variables
    
    /**
     UIImagePickerController declaration for videoController
     */
    let videoController = UIImagePickerController()
    /**
     String declaration for strVideoUrl
     */
    var strVideoUrl = ""
    /**
     VideoPickerDelegates delegated
     */
    var delegate : VideoPickerDelegates?
    
    /**
     Used to open video gallery
     */
    func openVideoGallery(){
        videoController.sourceType = .photoLibrary
        videoController.delegate = self
        videoController.mediaTypes = ["public.movie"]
        self.present(videoController, animated: true, completion: nil)
    }
    
    /**
     Used to open video camera
     */
    func openVideoCamera(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
            videoController.sourceType = .camera
            videoController.mediaTypes = [kUTTypeMovie as String]
            videoController.delegate = self
            self.present(videoController, animated: true, completion: nil)
        }
    }
    
    /**
     Used to check video is not exceed than 50MB
     - Parameter :
     - url: videoURL
     - Returns: result
     */
    func isValidVideoUrl(url :URL)->Bool{
        self.strVideoUrl = url.absoluteString
        videoController.dismiss(animated: false, completion: nil)
        let asset = AVURLAsset(url: url)
        if ((asset.fileSize ?? 0) / (1024 * 1024)) > 50{
            return false
        }
        return true
    }
}


// MARK: - UIImagePickerControllerDelegate,UINavigationControllerDelegate
extension VideoPickerClass : UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL
        if  isValidVideoUrl(url: videoURL!) {
            delegate?.isVideoSuccessfullyPickedUP(url: videoURL!)
        }else{
            Generals.presentAlert(title: EXCEED_TITLE, msg: EXCEED_MSG, VC: self)
        }
    }
}

/// Video picker delegated
protocol VideoPickerDelegates {
    func isVideoSuccessfullyPickedUP(url : URL)
}
