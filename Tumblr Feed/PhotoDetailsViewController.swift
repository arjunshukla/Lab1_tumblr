//
//  PhotoDetailsViewController.swift
//  Tumblr Feed
//
//  Created by Arjun Shukla on 10/16/16.
//  Copyright © 2016 arjunshukla. All rights reserved.
//

import UIKit

class PhotoDetailsViewController: UIViewController {

    @IBOutlet weak var imgViewPost: UIImageView!
    
    public var photoUrl : URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgViewPost.setImageWith(photoUrl)
    }
    
    @IBAction func onImgTap(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "segueFullScreenPhoto", sender: self)
    }

    // MARK: Navigation methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination as! FullScreenPhotoViewController
        
            destinationViewController.photoUrl = photoUrl
    }

}
