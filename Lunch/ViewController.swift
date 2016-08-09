//
//  ViewController.swift
//  Lunch
//
//  Created by shan jiang on 17/06/16.
//  Copyright © 2016 Shan Jiang. All rights reserved.


// TO DO
// API key security storage
// Watch till S2V3

import UIKit
import GoogleMaps
import CoreLocation
import WebKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let currentLocation = SharingManager.sharedInstance.currentLocation;
    let apiServerKey = SharingManager.sharedInstance.apiServerKey
    
    // Google Map
    var placesClient: GMSPlacesClient?
    var placePicker: GMSPlacePicker?

    // Fetch curretnLocation
    var locationManager = CLLocationManager()
    var didFindMyLocation = false
    
    // Fetch nearyby location
    enum SearchKeyWord: String{
        case Resturant = "resturant"
        case Cafe = "cafe"
        
        var description: String {
            return self.rawValue
        }
    }
    
    // 1
    let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    // 2
    var placesTask: NSURLSessionDataTask?
    
    // Instantiate UI Component
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    var webView: WKWebView?
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get current place
        placesClient = GMSPlacesClient()
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
                
        // Get current GOlocation
        didFindMyLocation = false

        // Initialize for get location
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(locationManager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation:CLLocation = locations[0]
        currentLocation.lat = userLocation.coordinate.latitude
        currentLocation.long = userLocation.coordinate.longitude
        
        NSLog("CurrentLocation: \n " + "Lat: " + "\(currentLocation.lat)\n"
            + "long: " + "\(currentLocation.long)")
        //Do What ever you want with it
    }
    

    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        print("Error while updating location " + error.localizedDescription)
        
        let alertView = UIAlertController(title: "Location Error", message: "Failed to get your location", preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        presentViewController(alertView, animated: true, completion: nil)
    }
    
    func fetchResturantNearBy(radius: Double, searchKey: String){
        
        if placesTask != nil{
            placesTask?.cancel()
            print("--------------------------------------")
            print("DEBUG: task1 canclled")
        }
    
        let baseURL = NSURL(string: "https://maps.googleapis.com/maps/api/place/")
        let searchURL = NSURL(string: "nearbysearch/json?location=\(currentLocation.lat),\(currentLocation.long)&radius=\(radius)&type=\(searchKey)&key=\(apiServerKey)", relativeToURL: baseURL)
        
        // Settled location for testing
        //let url = NSURL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=57.7087176,11.9669538&radius=500&type=restaurant&key=\(apiServerKey)"
        
        if let task = placesTask{
            if task.taskIdentifier > 0 && task.state == .Running {
                task.cancel()
                print("--------------------------------------")
                print("DEBUG: task2 canclled")
            }
        }
        
        placesTask = session.dataTaskWithURL(searchURL!) {
            data, response, error in
            dispatch_async(dispatch_get_main_queue()) {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            }
            var placesArray = [String]()
            do{
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options:[]) as? NSDictionary
                    if let results = json!["results"] as? NSArray {
                        print("--------------------------------------")
                        print("DEBUG: has result")
                        
                        print("--------------------------------------")
                        print("Results content:")
                        print(results)
                        
                        for rawPlace:AnyObject in results {
                            //let place = placesArray(dictionary: rawPlace as NSDictionary, acceptedTypes: types)
                            placesArray.append(rawPlace as! String)
//                            if let reference = place.photoReference {
//                                self.fetchPhotoFromReference(reference) { image in
//                                    place.photo = image
//                                }
//                            }
                            print("--------------------------------------")
                            print("DEBUG: result added")
                        }
                        print("--------------------------------------")
                        print("result: \(results)")
                    }
                
            }catch{
                print("--------------------------------------")
                print("DEBUG: json error: \(error)")
                
            }
//            dispatch_async(dispatch_get_main_queue()) {
//                completion(placesArray)
//            }
            if let error = error {
                print("--------------------------------------")
                print("DEBUG: location error: \(error)")
                print(error.localizedDescription)
            } else if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    print("--------------------------------------")
                    print("DEBUG: Has response")
                    print("Data: ")
                    print(data)
                    print("--------------------------------------")
                }
            }
        }
        placesTask?.resume()
        
//        if placesTask.taskIdentifier > 0 && placesTask.state == .Running {
//            placesTask.cancel()
//        }
//        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
//        var session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
//        
//        session.dataTaskWithURL(url!, completionHandler: { (data : NSData?, response : NSURLResponse?, error : NSError?) -> Void in
//            if error != nil {
//                callback(items: nil, errorDescription: error.localizedDescription)
//            }
//            
//            if let statusCode = response as? NSHTTPURLResponse {
//                if statusCode.statusCode != 200 {
//                    callback(items: nil, errorDescription: "Could not continue.  HTTP Status Code was \(statusCode)")
//                }
//            }
//            
//            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
//                callback(items: GooglePlaces.parseFromData(data), errorDescription: nil)
//            })
//            
//        }).resume()
        
        
    }
    
    
    

    
    
    @IBAction func getCurrentPlace(sender: UIButton) {
        
       
        
        placesClient?.currentPlaceWithCallback({
            (placeLikelihoodList: GMSPlaceLikelihoodList?, error: NSError?) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            self.nameLabel.text = "No current place"
            self.addressLabel.text = ""
            
            if let placeLikelihoodList = placeLikelihoodList {
                let place = placeLikelihoodList.likelihoods.first?.place
                if let place = place {
                    //self.currentLocation.country = place.name
                    self.nameLabel.text = place.name
                    //self.currentLocation.address = place.formattedAddress!.componentsSeparatedByString(", ").joinWithSeparator("\n")
                    self.addressLabel.text = place.formattedAddress!.componentsSeparatedByString(", ")
                        .joinWithSeparator("\n")
                    if let tempAdd = self.addressLabel.text{
                        self.currentLocation.address = tempAdd
                    }
                    if let tempName = self.nameLabel.text{
                        self.currentLocation.country = tempName
                    }
          
                    print("Address: " + self.currentLocation.address + "Country: " + self.currentLocation.country)
                }
            }
        })
      
       
        
        
    }
    
    @IBAction func pickPlace(sender: UIBarButtonItem) {
        
        
        let center = CLLocationCoordinate2DMake(currentLocation.lat, currentLocation.long)
        let northEast = CLLocationCoordinate2DMake(center.latitude + 0.001, center.longitude + 0.001)
        let southWest = CLLocationCoordinate2DMake(center.latitude - 0.001, center.longitude - 0.001)
        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        let config = GMSPlacePickerConfig(viewport: viewport)
        placePicker = GMSPlacePicker(config: config)
        
        placePicker?.pickPlaceWithCallback({ (place: GMSPlace?, error: NSError?) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            if let place = place {
                
                self.currentLocation.address = place.name
                self.nameLabel.text = self.currentLocation.address
                
                
                if let tempName = place.formattedAddress{
                    self.currentLocation.country = tempName
                    self.addressLabel.text = self.currentLocation.country
                }
                print("Place name: \(place.name)")
                print("Place address: \(place.formattedAddress)")
                print("Place attributions: \(place.attributions)")
            } else {
                print("No place selected")
            }
        })
    }

    @IBAction func searchNearby(sender: AnyObject) {
        
         fetchResturantNearBy(5000, searchKey: SearchKeyWord.Resturant.description)
        
    }

}

