//: Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"


let url = NSURL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=57.7087176,11.9669538&radius=500&type=restaurant&key=AIzaSyC133fhGP0pWWyxsJIcO1p5JeAG6T5OdmY")

// Synchronise method
//let searchResult = NSData(contentsOfURL: url!)
//
//let json = try! NSJSONSerialization.JSONObjectWithData(searchResult!, options: []) as! [String: AnyObject]
//print(json)


// Asynchnoise method

let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
let session = NSURLSession(configuration: configuration)

let request = NSURLRequest(URL: url!)

let dataTask = session.dataTaskWithRequest(request) { data, response, error in
    print(data!)
}

dataTask.resume()

