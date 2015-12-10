//
//  PhotoNameTableViewController.swift
//  FlickrPhotoDisplayer
//
//  Created by Harry on 3/12/2015.
//  Copyright © 2015 Snaptee. All rights reserved.
//

import UIKit

class PhotoNameTableViewController: UITableViewController {

    let model = FlickrModel()
    // REVIEW: For `UIView`, you can try to use `lazy` to make them load on request
    lazy var spinner = UIActivityIndicatorView.init(frame: CGRectMake(0, 0, 50, 50))

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "FlickrFetcher"

        // REVIEW: Remove useless comment to make the code more readable.
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        spinner.activityIndicatorViewStyle = .Gray
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        // REVIEW: When do you remove the spinner from the window??
        // just hidden...
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        spinner.center = CGPointMake(UIScreen.mainScreen().bounds.size.width / 2, UIScreen.mainScreen().bounds.size.height / 2)
        appDelegate.window?.addSubview(spinner)

        // REVIEW: When do you remove the observer??
        NSNotificationCenter.defaultCenter().addObserverForName(FlickrInfoDownloaded, object: nil, queue: nil) { (note: NSNotification) -> Void in
            self.tableView.reloadData()
            self.spinner.stopAnimating()
            self.spinner.removeFromSuperview()
            NSNotificationCenter.defaultCenter().removeObserver(self)
        }
    }


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return model.photographers.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PhotographerCell", forIndexPath: indexPath)

        // Configure the cell...
        // REVIEW: Should be an array of `Photographer` object  ???
        let photographerNames = Array(model.photographers.keys)
        cell.textLabel!.text = "Owner: \(photographerNames[indexPath.row])"
        cell.detailTextLabel!.text = "have \(model.photographers[photographerNames[indexPath.row]]!.count) photos"

        return cell
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

//        if segue.identifier == "ShowImageSegue" {
//            if segue.destinationViewController.isKindOfClass(ImageViewController) {
//                let imageVC = segue.destinationViewController as! ImageViewController
//                downloadImage(model.photos[(tableView.indexPathForSelectedRow?.row)!].imageURL, usingBlock: { (image) -> Void in
//                    imageVC.image = image!
//                })
//            }
//        }

        if segue.identifier == "ShowPhotosSegue" {
            if segue.destinationViewController.isKindOfClass(PhotosCollectionViewController) {
                let photosView = segue.destinationViewController as! PhotosCollectionViewController
                let photographerNames = Array(model.photographers.keys)
                photosView.title = "\(photographerNames[tableView.indexPathForSelectedRow!.row])'s Job"
                photosView.photos = model.photographers[photographerNames[tableView.indexPathForSelectedRow!.row]]!
            }
        }

        
    }


}
