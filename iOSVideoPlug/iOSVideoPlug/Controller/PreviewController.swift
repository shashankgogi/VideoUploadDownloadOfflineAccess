//
//  PreviewController.swift
//  iOSVideoPlug
//
//  Created by Rahul Panzade on 01/04/19.
//  Copyright © 2019 Omni-Bridge. All rights reserved.
//

import UIKit
import AVKit
import CoreMedia
import Alamofire

/// Class for PreviewController
class PreviewController: PreviewClass{
    
    // MARK:- Variable & Outlets declaration
    
    /**
     UIView outlet for viewForVideoPreview
     */
    @IBOutlet weak var viewForVideoPreview: UIView!
    /**
     UITextView outlet for txtForName
     */
    @IBOutlet weak var txtForName : UITextView!
    /**
     UITextView outlet for txtForCategory
     */
    @IBOutlet weak var txtForCategory : UITextView!
    
    // MARK:- View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initVideoPlayer(view: viewForVideoPreview)
    }
    
    // MARK:- Button action methods
    
    @IBAction func uploadPressed(_ sender : UIButton){
        uploadVideoWithLocalValidation(txtName: txtForName, txtCat: txtForCategory)
    }
    
    @IBAction func cancelPressed(_ sender : UIButton){
        self.navigationController?.popViewController(animated: true)
    }
}

