//
//  TableViewCellForVideoDetails.swift
//  iOSVideoPlug
//
//  Created by Rahul Panzade on 02/04/19.
//  Copyright © 2019 Omni-Bridge. All rights reserved.
//

import UIKit
import AlamofireImage
import  Alamofire

/// Class for TableViewCellForVideoDetails
class TableViewCellForVideoDetails: UITableViewCell {
    /**
     imageview outlet for thumbnail image
     */
    @IBOutlet weak var imgViewForVideo : UIImageView!
    /**
     label outlet for video title
     */
    @IBOutlet weak var lblForVideoTitle : UILabel!
    /**
     label outlet for video size
     */
    @IBOutlet weak var lblForVideoSize : UILabel!
    /**
     label outlet for video downloading progress
     */
    @IBOutlet weak var lblForVideoProgress : UILabel!
    /**
     UIDownloadProgressButton outlet for download button
     */
    @IBOutlet weak var btnForVideoProgress : UIDownloadProgressButton!
    
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        DispatchQueue.main.async {
            self.lblForVideoProgress.isHidden = true
            self.btnForVideoProgress.status = .none
        }
    }
    
    /**
     Used configure cell
     - Parameters:
     - videoModel: VideoDetails
     */
    func configure(videoModel : VideoDetails){
        
        self.lblForVideoTitle.text = videoModel.strVideoName
        self.lblForVideoSize.text = "\(((videoModel.size / (1024 * 1024)) >= 1 ? "\(Float(videoModel.size / (1024 * 1024))) MB" : "\(Float(videoModel.size / (1024)) >= 1000 ? "1 MB" : "\(Float(videoModel.size / (1024))) KB" )"))"
        
        DispatchQueue.main.async {
            if videoModel.status == "none" {
                self.lblForVideoProgress.isHidden = true
                self.btnForVideoProgress.status = .none
                self.lblForVideoProgress.isHidden = true
            }else if videoModel.status == "start" {
                self.btnForVideoProgress.drawCircle()
                self.lblForVideoProgress.isHidden = false
                self.btnForVideoProgress.status = .downloading
            }else if videoModel.status == "pause"{
                self.btnForVideoProgress.drawCircle()
                self.lblForVideoProgress.isHidden = false
                self.btnForVideoProgress.status = .paused
                self.btnForVideoProgress.progress = videoModel.progress
                self.lblForVideoProgress.text = "Downloading Paused"
            }else if videoModel.status == "finish"{
                self.btnForVideoProgress.status = .downloaded
                self.btnForVideoProgress.progress = 0.0
                self.lblForVideoProgress.isHidden = true
            }
        }
        
        
        if videoModel.strThubnailUrl.isEmpty{
            return
        }
        guard let imageUrl = URL(string: videoModel.strThubnailUrl) else{return}
        self.imgViewForVideo.image =  UIImage(named: "play")!
        self.imgViewForVideo.af_setImage(withURL: imageUrl, placeholderImage: Image(named: "Ic_UploadVideo"), filter: nil, progress: nil, progressQueue: DispatchQueue.main, imageTransition: UIImageView.ImageTransition.noTransition, runImageTransitionIfCached: false) { (image) in
            guard let img = image.value else {return}
            DispatchQueue.main.async {
                self.imgViewForVideo.contentMode = .center
                self.imgViewForVideo.image = img.combineWith(image: UIImage(named: "play")!)
            }
        }
    }
}
