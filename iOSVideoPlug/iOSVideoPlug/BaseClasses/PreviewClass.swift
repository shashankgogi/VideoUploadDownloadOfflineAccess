//
//  PreviewClass.swift
//  iOSVideoPlug
//
//  Created by Rahul Panzade on 05/04/19.
//  Copyright © 2019 Omni-Bridge. All rights reserved.
//

import UIKit
import AVKit
import CoreMedia
import Alamofire

/// Class for PreviewClass
class PreviewClass: UIViewController {
    // MARK:- Variables
    
    /**
     AVPlayer declaration for videoPlayer
     */
    var videoPlayer : AVPlayer!
    /**
     CircularProgressView declaration for progressView
     */
    var progressView : CircularProgressView!
    /**
     String reference of strURL
     */
    var strURL  = ""
    
    /**
     Used to set video player with pause option
     - Parameters:
     - view: view
     */
    func initVideoPlayer(view : UIView) {
        let videoURL = URL(string: strURL)
        if let videoURL = videoURL{
            let player = AVPlayer(url: videoURL)
            let playerController = AVPlayerViewController()
            playerController.player = player
            self.addChild(playerController)
            view.addSubview(playerController.view)
            playerController.view.frame = view.bounds
            player.pause()
        }
    }
    
    /**
     Used to create progress view
     - Parameters:
     - view: view
     */
    func createProgressView(){
        let bgView = UIView(frame: self.view.bounds)
        bgView.layer.backgroundColor = UIColor.lightGray.cgColor
        bgView.alpha = 0.7
        bgView.tag = 101
        self.view.addSubview(bgView)
        progressView = CircularProgressView()
        progressView.frame = CGRect(x: self.view.bounds.width / 2 - 50, y: self.view.bounds.height / 2 - 50, width: 100, height: 100)
        progressView.progress = 0.5
        self.view.addSubview(progressView)
        progressView.drawCircle()
    }
    
    /**
     Used to upload video with local validation
     - Parameters:
     - txtName: txtName
     - txtCat: txtCat
     */
    func uploadVideoWithLocalValidation(txtName : UITextView? , txtCat : UITextView?){
        
        if txtName != nil && ((txtName?.text ?? "").replacingOccurrences(of: " ", with: "")).count == 0{
            Generals.presentAlert(title: WARNING_TITLE, msg: NAME_REQUIRED_MSG, VC: self)
            return
        }
        if txtCat != nil && ((txtCat?.text ?? "").replacingOccurrences(of: " ", with: "")).count == 0{
            Generals.presentAlert(title: WARNING_TITLE, msg: CATEGORY_REQUIRED_MSG, VC: self)
            return
        }
        if Generals.isConnectedToNetwork(){
            createProgressView()
            progressView.status = .start
            progressView.progress = 0.0
            self.view.isUserInteractionEnabled = false
            uploadVideo(fileName: txtName?.text ?? "defaultName", category: txtCat?.text ?? "")
        }else{
            Generals.presentAlert(title: NOINTERNET_TITLE, msg: NOINTERNET_MESSAGE, VC: self)
        }
    }
    
    /**
     Used to upload video with local validation
     - Parameters:
     - path: video path url
     - Returns: thumbnail image
     */
    func generateThumbnailFromVideoAt(path: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: path, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
    
    /**
     Used to upload video
     - Parameters:
     - fileName: fileName
     */
    func uploadVideo(fileName : String , category : String) {
        let url : URL! = URL(string: strURL)
        let thumbnailImage : UIImage! = self.generateThumbnailFromVideoAt(path: url)
        let thumbnailImageData = thumbnailImage.jpegData(compressionQuality: 1)
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(url, withName: "file",fileName: "\(fileName).mp4", mimeType: "mov/mp4")
            multipartFormData.append(thumbnailImageData!, withName: "thumbnail", fileName: "\(fileName.utf8).jpeg", mimeType: "image/jpeg")
        },to:"\(UserDefaults.standard.value(forKey: "StartURLFromServer") ?? "")\(UPLOAD_VIDEO_PATH)?title=\(fileName)&category=\(category)".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
        { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (progress) in
                    self.progressView.progress = Float(progress.fractionCompleted)
                })
                
                upload.responseJSON { response in
                    if response.result.value == nil{
                        self.progressView.removeFromSuperview()
                        self.view.isUserInteractionEnabled = true
                        Generals.presentAlert(title: WARNING_TITLE, msg: SOMETHING_WENT_WRONG_MSG, VC: self)
                        return
                    }
                    guard let resopnse = response.result.value as? NSDictionary ,let resopnseDict = resopnse.value(forKey: "data") as? NSDictionary else{ return}
                    guard let message = resopnseDict.value(forKey: "message") as? String else {
                        Generals.presentAlert(title: WARNING_TITLE, msg: SOMETHING_WENT_WRONG_MSG, VC: self)
                        return
                    }
                    self.progressView.removeFromSuperview()
                    if let bgView = self.view.viewWithTag(101){
                        bgView.removeFromSuperview()
                    }
                    self.view.isUserInteractionEnabled = true
                    if message == "Video saved succesfully."{
                        NotificationCenter.default.post(name: NSNotification.Name(REFRESH_HOMEVIEW_NOTIF_NAME), object: nil)
                        self.navigationController?.popToRootViewController(animated: true)
                    }else{
                        Generals.presentAlert(title: WARNING_TITLE, msg: SOMETHING_WENT_WRONG_MSG, VC: self)
                    }
                }
            case .failure(let encodingError):
                print(encodingError)
            }
        }
    }
}


// MARK: - UITextViewDelegate
extension PreviewClass : UITextViewDelegate{
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false}
        let changeText = currentText.replacingCharacters(in: stringRange, with: text)
        textView.layer.borderColor = UIColor.black.cgColor
        if (textView.text ?? "" == "" && text == " "){
            return false
        }
        if textView.tag == 1{
            if changeText.count > 100{
                textView.layer.borderColor = UIColor.red.cgColor
            }
            return changeText.count <= 100
        }else{
            if changeText.count > 50{
                textView.layer.borderColor = UIColor.red.cgColor
            }
            return changeText.count <= 50
        }
    }
}
