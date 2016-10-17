//
//  ViewController.swift
//  Tumblr Feed
//
//  Created by Arjun Shukla on 10/16/16.
//  Copyright © 2016 arjunshukla. All rights reserved.
//

import UIKit
import AFNetworking

class PhotosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {

    @IBOutlet weak var tableViewFeed: UITableView!
    
    var arrPostsFeed : Array<AnyObject> = []
    
    let refreshControl = UIRefreshControl()
    
    var isMoreDataLoading = false
    
    var loadingMoreView:InfiniteScrollActivityView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialize a UIRefreshControl
       
        refreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)

        // add refresh control to table view
        tableViewFeed.insertSubview(refreshControl, at: 0)
        fetchFeed(refreshControl: refreshControl)
        
//        let tableFooterView: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: 320, height: 50))//UIView(frame: CGRectMake(0, 0, 320, 50))
//        let loadingView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
//        loadingView.startAnimating()
//        loadingView.center = tableFooterView.center
//        tableFooterView.addSubview(loadingView)
//        self.tableViewFeed.tableFooterView = tableFooterView
        
        tableViewFeed.delegate = self
        tableViewFeed.dataSource = self
        tableViewFeed.rowHeight = 320
//        tableViewFeed.estimatedRowHeight = 320
//        tableViewFeed.rowHeight = UITableViewAutomaticDimension
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x:0, y:tableViewFeed.contentSize.height, width: tableViewFeed.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableViewFeed.addSubview(loadingMoreView!)
        
        var insets = tableViewFeed.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableViewFeed.contentInset = insets
        
    }

    
    func fetchFeed(refreshControl: UIRefreshControl) {
        let apiKey = "Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV"
        let url = URL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=\(apiKey)")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(with: request,completionHandler: { (dataOrNil, response, error) in
            if let data = dataOrNil {
                if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options:[]) as? NSDictionary {
                    NSLog("response: \(responseDictionary)")
                    self.isMoreDataLoading = false
                    // Stop the loading indicator
                    self.loadingMoreView!.stopAnimating()
                    self.arrPostsFeed += responseDictionary.value(forKeyPath: "response.posts") as! Array<AnyObject>
                    self.tableViewFeed.reloadData()
                    refreshControl.endRefreshing()
                }
            }
        });
        task.resume()
    }
    
    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    func refreshControlAction(refreshControl: UIRefreshControl) {
        fetchFeed(refreshControl: refreshControl)
//        refreshControl.endRefreshing()
        
    }
    
//    MARK: Table View Data Source Methods...
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrPostsFeed.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
//    MARK: Table View Delegate Methods
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "feedCell", for: indexPath) as! PhotoCell
        let url = URL(string : (arrPostsFeed[indexPath.row]["photos"] as? Array<AnyObject>)?[0].value(forKeyPath: "original_size.url") as! String)
        cell.imgFeedPhoto.setImageWith(url!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated:true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        headerView.backgroundColor = UIColor(white: 1, alpha: 0.9)
        
        let profileView = UIImageView(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
        profileView.clipsToBounds = true
        profileView.layer.cornerRadius = 15;
        profileView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).cgColor
        profileView.layer.borderWidth = 1;
        
        // set the avatar
        profileView.setImageWith(NSURL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/avatar")! as URL)
        headerView.addSubview(profileView)
        
        // Add a UILabel for the date here
        // Use the section number to get the right URL
        let label: UILabel = UILabel(frame: CGRect(x: 70, y: 0, width: tableViewFeed.frame.width, height: 50))
        label.text = "Humans of New York"
        headerView.addSubview(label)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 150.0
    }

    // MARK: Navigation methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination as! PhotoDetailsViewController
        var indexPath = tableViewFeed.indexPathForSelectedRow
        destinationViewController.photoUrl = URL(string : (arrPostsFeed[(indexPath?.row)!]["photos"] as? Array<AnyObject>)?[0].value(forKeyPath: "original_size.url") as! String)
    }

    // MARK: Infinite Scroll
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Handle scroll behavior here
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableViewFeed.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableViewFeed.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableViewFeed.isDragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: tableViewFeed.contentSize.height, width: tableViewFeed.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                // ... Code to load more results ...
                fetchFeed(refreshControl: refreshControl)
            }
        }
    }
    
}

