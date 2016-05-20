//
//  DetailViewController.swift
//  Flicks
//
//  Created by randy_zhao on 5/16/16.
//  Copyright © 2016 randy_zhao. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {

    @IBOutlet weak var dropbackImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var overviewLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var infoView: UIView!
    
    @IBOutlet weak var trailerWebView: UIWebView!
    
    @IBOutlet weak var posterImageView: UIImageView!
    
    @IBOutlet weak var voteAverageLabel: UILabel!
    
    @IBOutlet weak var voteCountLabel: UILabel!
    
    @IBOutlet weak var detailsTableView: UITableView!
    
    @IBOutlet weak var profileScrollView: UIScrollView!
    
    @IBOutlet weak var fullscreenImageView: UIImageView!
    
    @IBOutlet weak var fullscreenImageScrollView: UIScrollView!
    
    @IBAction func watchTrailerButtonClicked(sender: AnyObject) {
        if trailerLinks.count > 0 {
            let code: String = "<html><body><iframe width=\"320\" height=\"184\" src=\(trailerLinks[0]) frameborder=\"0\" allowfullscreen></iframe></body></html>"
            self.trailerWebView.hidden = false
            self.trailerWebView.loadHTMLString(code, baseURL: NSBundle.mainBundle().bundleURL)
        }

    }
    var movie: NSDictionary!
    
    var trailerLinks: Array<String> = []
    
    var details: Array<(String, String)> = []
    
    var cast: Array<(name: String, profilePath: String)> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let title = movie["title"] as? String
        titleLabel.text = title
        
        let overview = movie["overview"]
        overviewLabel.text = overview as? String
        
        //overviewLabel.sizeToFit()
        
        //if let posterPath = movie["poster_path"] as? String {
        if let backdropPath = movie["backdrop_path"] as? String {
            //fetchImageAndFadeIn(posterImageView, imageUrl: largePosterUrl(posterPath), smallerImageUrl: smallPosterUrl(posterPath))
            fetchImageAndFadeIn(dropbackImageView, imageUrl: largePosterUrl(backdropPath))
        }
        if let posterPath = movie["poster_path"] as? String {
            fetchImageAndFadeIn(posterImageView, imageUrl: largePosterUrl(posterPath), smallerImageUrl: smallPosterUrl(posterPath))
        }
        trailerWebView.allowsInlineMediaPlayback = true
        trailerWebView.mediaPlaybackRequiresUserAction = false
        
        
        trailerWebView.allowsInlineMediaPlayback = true
        trailerWebView.hidden = true
        NetworkHelper.fetchYoutubeLinks(
            String(self.movie["id"]!),
            successHandler: { (links: [String]) -> Void in
                self.trailerLinks = links
                if links.count > 0 { // TODO: only play first trailer now
                    let code: String = "<html><body><iframe width=\"320\" height=\"320\" src=\(links[0]) frameborder=\"0\" allowfullscreen></iframe></body></html>"
                    //self.trailerWebView.hidden = false
                    self.trailerWebView.loadHTMLString(code, baseURL: NSBundle.mainBundle().bundleURL)
                }
                
            },
            failureHandler: { (error: NSError?) -> Void in }// TODO: add an error handler here
        )
        
        voteAverageLabel.text = "\(movie["vote_average"]!)/10"
        voteCountLabel.text = String(movie["vote_count"]! )
        
        detailsTableView.dataSource = self
        detailsTableView.delegate = self
        
        NetworkHelper.networkRequest(
            NetworkHelper.urlRequestFromString("http://api.themoviedb.org/3/movie/" + String(movie["id"]!)),
            successHandler: {
                (data: NSData) -> Void in
                self.generateMovieDetails(data)
            },
            failureHandler: {
                (error: NSError?) -> Void in
                // TODO: something here
            }
        )
        
        NetworkHelper.networkRequest(
            NetworkHelper.urlRequestFromString("http://api.themoviedb.org/3/movie/" + String(movie["id"]!) + "/credits"),
            successHandler: { (data: NSData) -> Void in
                self.cast = []
                if let rd = try! NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSDictionary {
                    let cast = rd["cast"] as! NSArray
                    for person in cast {
                        let pdict = person as! NSDictionary
                        if pdict["name"] as? String != nil && pdict["profile_path"] as? String != nil {
                            self.cast.append((name: pdict["name"] as! String, profilePath: pdict["profile_path"] as! String))
                        }
                    }
                    self.setupProfileViews()
                }
            },
            failureHandler: {
                (error: NSError?) -> Void in
            }
        )
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: detailsTableView.frame.origin.y + detailsTableView.frame.size.height)
        scrollView.delegate = self
        
        fullscreenImageScrollView.delegate = self
        dropbackImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "imageTapped"))
        print(movie)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func imageTapped() {
        fullscreenImageScrollView.hidden = false
        fullscreenImageView.image = dropbackImageView.image
        fullscreenImageScrollView.contentSize = fullscreenImageView.image!.size
        fullscreenImageView.hidden = false
        scrollView.hidden = true
    }
    
    func setupProfileViews() {
        var xPos: CGFloat = 0
        
        for (name, profilePath) in cast {
            let profileView = generateSingleProfileView(name, profilePath: profilePath)
            profileView.frame.origin.x = xPos
            profileView.frame.origin.y = 0
            profileScrollView.addSubview(profileView)
            
            xPos += profileView.frame.size.width + 5
        }
        profileScrollView.contentSize = CGSize(width: xPos, height: 100)
    }
    
    func generateSingleProfileView(name: String, profilePath: String) -> UIView {
        let profileView = UIView()
        profileView.frame.size.width = 80
        profileView.frame.size.height = 100
        
        let imageView = UIImageView()
        imageView.frame.size.width = 60
        imageView.frame.size.height = 80
        imageView.frame.origin.x = 0
        imageView.frame.origin.y = 0
        fetchImageAndFadeIn(imageView, imageUrl: smallPosterUrl(profilePath))
        profileView.addSubview(imageView)
        
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.frame.size.height = 13
        nameLabel.frame.size.width = 60
        nameLabel.frame.origin.x = 0
        nameLabel.frame.origin.y = 85
        //nameLabel.font = UIFont(name: "systemFont", size: 5)
        nameLabel.font = UIFont.systemFontOfSize(7)
        profileView.addSubview(nameLabel)
        
        return profileView
    }
    
    func generateMovieDetails(data: NSData) -> Void {
        details = []
        if let rd = try! NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSDictionary {
            if let releaseDate = rd["release_date"] as? String {
                let outputFormatter = NSDateFormatter()
                outputFormatter.dateFormat = "MMMM d, yyyy"
                
                let inputFormatter = NSDateFormatter()
                inputFormatter.dateFormat = "yyyy-MM-dd"
                
                let dateString = outputFormatter.stringFromDate(inputFormatter.dateFromString(releaseDate)!)
                details.append(("Release Date", dateString))
            }
            
            if let languageList = rd["spoken_languages"] as? NSArray {
                var languages: Array<String> = []
                for language in languageList {
                    languages.append(language["name"] as! String)
                }
                details.append(("Languages", languages.joinWithSeparator(", ")))
            }
            
            if let genreList = rd["genres"] as? NSArray {
                var genres: Array<String> = []
                for genre in genreList {
                    genres.append(genre["name"] as! String)
                }
                details.append(("Genres", genres.joinWithSeparator(", ")))
            }
        }
        detailsTableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return details.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DetailsTableViewCell", forIndexPath: indexPath) as! DetailsTableViewCell
        cell.setContent(details[indexPath.row].0, value: details[indexPath.row].1)
        return cell
    }

    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return fullscreenImageView
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
