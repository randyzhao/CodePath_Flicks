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

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var viewTypeSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var movies = [NSDictionary]()
    var filteredMovies = [NSDictionary]()
    var endPoint: String!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        networkRequest()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refershControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        collectionView.insertSubview(refreshControl, atIndex: 0)
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterMoviesForSearchText(searchController.searchBar.text!)
    }
    
    func filterMoviesForSearchText(searchText: String, scope: String = "All") {
        filteredMovies = movies.filter {
            movie in
            return movie["title"]!.lowercaseString.containsString(searchText.lowercaseString)
        }
        tableView.reloadData()
        collectionView.reloadData()
    }
    
    func refershControlAction(refreshControl: UIRefreshControl) {
        NetworkHelper.fetchMovies(
            NetworkHelper.getRequestByEndpoint(endPoint),
            successHandler: {
                (movies: [NSDictionary]) -> Void in
                self.movies = movies
                self.tableView.reloadData()
                self.collectionView.reloadData()
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
                self.collectionView.reloadData()
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
        return moviesToUse().count
    }
    
    private func moviesToUse() -> [NSDictionary] {
        if searchController.active && searchController.searchBar.text != "" {
            return filteredMovies
        } else {
            return movies
        }
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = moviesToUse()[indexPath.row]
        cell.titleLabel.text = movie["title"] as? String
        cell.overviewLabel.text = movie["overview"] as? String
    
        
        if let posterPath = movie["poster_path"] as? String {
            fetchImageAndFadeIn(cell.posterView, imageUrl: largePosterUrl(posterPath))
        }
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let movie: NSDictionary!
        if sender is UITableViewCell {
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)
            movie = moviesToUse()[indexPath!.row]
        } else {
            let cell = sender as! UICollectionViewCell
            let indexPath = collectionView.indexPathForCell(cell)
            movie = moviesToUse()[indexPath!.row]
        }
        
        let detailViewController = segue.destinationViewController as! DetailViewController
        detailViewController.movie = movie
    }

    @IBAction func viewTypeChanged(sender: AnyObject) {
        var fromView: UIView?
        var toView: UIView?
        if viewTypeSegmentedControl.selectedSegmentIndex == 1 {
            fromView = tableView
            toView = collectionView
        } else {
            fromView = collectionView
            toView = tableView
        }
        fromView?.hidden = true
        toView?.hidden = false
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return moviesToUse().count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PosterCell", forIndexPath: indexPath) as! PosterCell
        let movie = moviesToUse()[indexPath.row]
        
        if let posterPath = movie["poster_path"] as? String {
            fetchImageAndFadeIn(cell.posterImageVIew, imageUrl: largePosterUrl(posterPath))
        }
        cell.titleLabel.text = movie["title"] as? String
        return cell
    }
    
}
