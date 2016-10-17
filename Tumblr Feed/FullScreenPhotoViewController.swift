//
//  FullScreenPhotoViewController.swift
//  Tumblr Feed
//
//  Created by Arjun Shukla on 10/16/16.
//  Copyright © 2016 arjunshukla. All rights reserved.
//

import UIKit

class FullScreenPhotoViewController: UIViewController, UIScrollViewDelegate {

    public var photoUrl : URL!
    
    @IBOutlet weak var imgViewFullScreen: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imgViewFullScreen.setImageWith(photoUrl)
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imgViewFullScreen
    }
    
    @IBAction func onCLoseBtnTap(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

}
