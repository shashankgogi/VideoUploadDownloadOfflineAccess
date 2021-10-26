//
//  UIDownloadProgressButton.swift
//  iOS_DownloadUIPlug
//
//  Created by macbook pro on 16/10/18.
//  Copyright © 2018 Omni-Bridge. All rights reserved.
//

import UIKit


/// enum constant for Downloading Status

enum DownloadStatus {
    /**
     for not downloading start yet
     */
    case none
    /**
     for downloading in progress
     */
    case downloading
    /**
     for downloading paused
     */
    case paused
    /**
     for completed downloads
     */
    case downloaded
}


/// class for UIDownloadProgressButton
class UIDownloadProgressButton: UIButton {
    
    /**
     Circular progress between 0 to 1.0
     */
    var progress: Float = 0 {
        didSet {
            circleShape.strokeEnd = CGFloat(self.progress)
            self.addAnimation()
        }
    }
    
    /**
     Circular shape object
     */
    var circleShape = CAShapeLayer()
    /**
     Inner Circular shape object
     */
    var innerCircleShape = CAShapeLayer()
    
    /**
      used to set default property to UIDownloadProgressButton
     */
    public func drawCircle() {
        let x: CGFloat = 0.0
        let y: CGFloat = 0.0
        let circlePath = UIBezierPath(roundedRect: CGRect(x: x, y: y, width: self.frame.height, height: self.frame.height), cornerRadius: self.frame.height / 2).cgPath
        
        innerCircleShape.path = circlePath
        innerCircleShape.lineCap = CAShapeLayerLineCap.round
        innerCircleShape.lineWidth = 1
        innerCircleShape.strokeColor = UIColor.clear.cgColor
        innerCircleShape.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(innerCircleShape)
        
        circleShape.path = circlePath
        circleShape.lineCap = CAShapeLayerLineCap.round
        circleShape.lineWidth = 3
        circleShape.strokeColor = UIColor.purple.cgColor
        //circleShape.strokeStart = 0
        //circleShape.strokeEnd = 0
        circleShape.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(circleShape)
    }
    
    /**
     Used to animate the progress of UIDownloadProgressButton
     */
    func addAnimation(){
        DispatchQueue.main.async {
            let animation = CABasicAnimation(keyPath: "StrokeEnd")
            animation.toValue = 1
            animation.duration = 1
            animation.fillMode = CAMediaTimingFillMode.forwards
            animation.isRemovedOnCompletion = false
            self.circleShape.add(animation, forKey: "urSoBasic")
        }
    }
    
    // MARK: - Update the download status of UIDownloadProgressButton
    var status: DownloadStatus = .none {
        didSet{
            DispatchQueue.main.async {
                var buttonImageName = ""
                switch self.status {
                case .none:
                    self.progress = 0
                    self.innerCircleShape.strokeColor = UIColor.clear.cgColor
                    buttonImageName = "Download"
                case .downloading:
                    self.innerCircleShape.strokeColor = UIColor.gray.cgColor
                    buttonImageName = "downloading"
                case .downloaded:
                    self.progress = 0
                    self.innerCircleShape.strokeColor = UIColor.clear.cgColor
                    buttonImageName = "Trash"
                case .paused:
                    self.innerCircleShape.strokeColor = UIColor.gray.cgColor
                    buttonImageName = "paused"
                }
                self.setImage(UIImage(named: buttonImageName), for: .normal)
            }
        }
    }
}
