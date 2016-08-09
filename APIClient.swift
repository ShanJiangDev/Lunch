//
//  APIClient.swift
//  Lunch
//
//  Created by shan jiang on 09/08/16.
//  Copyright © 2016 Shan Jiang. All rights reserved.
//

import Foundation

typealias JSON = [String: AnyObject]
typealias JSONTaskCompletion = (JSON?, NSHTTPURLResponse?, NSError?) -> Void
typealias JSONTask = NSURLSessionDataTask

// T present as a generic one
// To be able to use any type as associate value for the Success case
// ErrorType: Both swift ErrorType and objective NSError class
enum APIResult<T>{
    case Success(T)
    case Failure(ErrorType)
}

protocol APIClient{
    // Not modify these variable after they created
    var configuration: NSURLSessionConfiguration { get }
    var session: NSURLSession { get }
    
    init(config: NSURLSessionConfiguration)
    // Goal:
    //      Create a data task
    
    // Structure:
    //      1. In the body of completion, we will define some logic to convert
    //      the nsdata object we get from request into a json object
    //      2. Because this is only a protocal so brackets are not needed, since no implementation will
    //      be done here
    //      3. This method has a completation handler, which allows us to works with json, response and
    //      error object that the data task returns
    
    // This function has a single objective: create and return a data task, 
    //      that fetchs the data from a request object

    
    func JSONTaskWithRequest(request: NSURLRequest, completion: JSONTaskCompletion) -> JSONTask
    
    // Fetch method:
    //      Making call to the JSONTask with request, so we will be able to work with JSONResponse
    //      return in the body of JSONTaskWithRequest clousure
    
    //      It will take a request, but instead creating an execute a dataTask it self
    //      This method is going to call JSONTaskWithRequest. Since the JSONTaskWithRequest method
    //      has a completion handler containning the JSON object. Inside the fetch(), we will use that
    //      object to do some further work
    
    // Useful: Convert json response to a model object(SearchResult), and provide an clear idecation to the
    //      user,that all these network fetching work successfully
    
    // Structure(3 cloursure expresure):
    //      "request:NSURLRequest": Pass through the request object to JSONTask with request, so it can 
    //       actually got to the url and get the data.
    //      " parse: JSON ": add this parameter to fetch, it takes a function or cloursure expression
    //      " JSON -> T ": It take the json return from "JSONTaskCompletion" and convert to "T"
    //      "completion": Completation handler
    
    // Goal:
    //      Take the response we get from "JSONTaskCompletion" and convert to "T"
    
    //  Fetch takes a request, and then use this request to create a dataTask using JSONTaskWithRequest method. JSONTaskWithRequest mehod returns a JSONTask, which we can use in the body of fetch method to make a download. The completion of JSONTaskWithRequest contains a JSON object. If this object is not nil and then everything execute without errors. Then we use the clousure expression that is passed in as an argument through "parse" to convert from "JSON" to "T". If this works we can take the type "T" returns from parse and put it inside a success value of "APIResult" and assign it as an argument to "completion" handler.
    func fetch<T>(request:NSURLRequest, parse: JSON -> T?, completion:APIResult<T> -> Void)
    
    
    
    
}