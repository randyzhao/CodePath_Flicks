//
//  MoviesViewController.swift
//  Flicks
//
//  Created by randy_zhao on 5/16/16.
//  Copyright © 2016 randy_zhao. All rights reserved.
//

import UIKit
import AFNetworking
import EZLoadingActivity

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var movies: [NSDictionary]?
    var endPoint: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        networkRequest()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refershControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
    }
    
    func refershControlAction(refreshControl: UIRefreshControl) {
        NetworkHelper.fetchMovies(
            NetworkHelper.getRequestByEndpoint(endPoint),
            successHandler: {
                (movies: [NSDictionary]) -> Void in
                self.movies = movies
                self.tableView.reloadData()
                refreshControl.endRefreshing()
            },
            failureHandler: {
                (_: NSError?) -> Void in
            }
        )
    }
    
    func networkRequest() {
        EZLoadingActivity.show("Loading...", disableUI: true)
        let request = NetworkHelper.getRequestByEndpoint(endPoint)
        NetworkHelper.fetchMovies(
            request,
            successHandler: {
                (movies: [NSDictionary]) -> Void in
                self.movies = movies
                EZLoadingActivity.hide()
                self.tableView.reloadData()
            },
            failureHandler: {
                (_: NSError?) -> Void in
                EZLoadingActivity.hide(success: false, animated: true)
            }
        )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        cell.titleLabel.text = movie["title"] as! String
        cell.overviewLabel.text = movie["overview"] as! String
        
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        
        if let posterPath = movie["poster_path"] as? String {
            let imageUrl = NSURL(string: baseUrl + posterPath)
            cell.posterView.setImageWithURL(imageUrl!)
        }
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        let movie = movies![indexPath!.row]
        
        let detailViewController = segue.destinationViewController as! DetailViewController
        detailViewController.movie = movie
    }

}
