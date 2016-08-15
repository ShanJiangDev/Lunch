//
//  APIClient.swift
//  Lunch
//
//  Created by shan jiang on 09/08/16.
//  Copyright © 2016 Shan Jiang. All rights reserved.
//

import Foundation

// NSSError:
// 1.Domain
// Pre-fix: (for method name in extension of objective c also)
//       Add three capital letters at beginning of name to make it unique
//       In order to avoid rewrite prive method

// First part of NSError domain structure
// Because Objective-c does not differenciate the error from system, our project and third-party
//       the solution to prevent naming colleation is to add three letter to pre-fix names

public let SHANetworkingErrorDomain = "com.shanjiang.Lunch.NetworkingError"
// 2.Error Code
public let MissingHTTPResponseError: Int = 10
public let UnexpectedResponseError: Int  = 20


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
    
    // Watch S3V3
    
}

// Default implementation
extension APIClient{
    
    // Return
    //      JSON object or error back
    func JSONTaskWithRequest(request: NSURLRequest, completion: JSONTaskCompletion) -> JSONTask{
        
        // Response can be nil in the scope of NSURLResponse
        //      but NSHTTPURLResponse will always have a return value
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            // Completion handler code: Describe what we wanna do with the value of
            //      "data, response and error"
            
            // 1. Varify "response" value
            guard let HTTPResponse = response as? NSHTTPURLResponse else{
                
                // When we can not convert "response" to HTTPResponse
                
                // NSError Object
                // Structure:
                //      1.Domain; String, which identify what category error is this error coming from
                //      2.Error code
                //      3.User Info Dictionary
                
                // First two part were created at the top of this file
                // 3.User Info Dictionary(global constents)
                
                // Functionalities:
                // Used to hold any user information beyond domain(1 part) and code(2 part).
                //      As a more powerful version of associated value in swift enum
                
                // Struecture:
                // Information in User dictionary sotred in strings(localized strings) as server dictionaries
                //      Descriotion for error
                //      Reason for failure
                //      Suggestion on how to recover from this error
                //      Different oppation for recovery
                
                // Localized strings: If you want to access strings in a launage other then english,
                //      you will get the string in whatever language you work in, translations among 
                //      launages are provided
                
                let userInfo = [
                    NSLocalizedDescriptionKey: NSLocalizedString("Missing HTTP Response", comment: "")
                ]
                
                let error = NSError(domain: SHANetworkingErrorDomain, code: MissingHTTPResponseError, userInfo: userInfo)
                
                completion(nil, nil, error)
                // Return: transfer the control out of the current function scope(from let task..)
                //      to the func JSONTaskWithResk()
                return
            }
            // 2. Varify "data" value
            
            // When data received from server is empty
            // Which means error occures
            if data  == nil{
                // If error existed:
                if let error = error{
                    completion(nil, HTTPResponse, error)
                }
            // Data object is not nil:
            }else{
                switch HTTPResponse.statusCode{
                    // When httprespose is success:
                    //      Convert NSdata to JSON
                case 200:
                    do{
                        // "options: []" takes a bunch of options which is a set to configure
                        //      how json object is created
                        // Use default to pass an empty set in "options" parameter
                        // “Set”: same as array but not store duplicate
                        let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? [String: AnyObject]
                        completion(json, HTTPResponse, nil)
                    } catch let error as NSError{
                        completion(nil, HTTPResponse, error)
                    }
                // When the statusCode is not 200
                default: print("Received HTTP Response: \(HTTPResponse.statusCode) - not handled")
                }
            }
        }
        // Can not through an error in foundation clousre, will lead to type miss match
        return task
    }
    
    func fetch<T>(request:NSURLRequest, parse: JSON -> T?, completion:APIResult<T> -> Void){
        
        // Parsing json which JSONTaskWithRequest() returns and indicated weather the method is
        //      successed or failed
        
        // 1. Use the request to get a Json object
        
        // This function returns a task which carrys out the data fetch
        //      but this task has never started before
        //      So, here we sign this resulting task to a constant

        let task = JSONTaskWithRequest(request) { json, response, error in
        
        // 2. Parse json object
            // In the clousure, will provide implementation for how we are going to 
            //      work with the result json
            
            // Because json is an optional type
            // "NSJSONSerialization.JSONObjectWithData" this method use in the function before
            //      can not garuntee successed, so we need to unwrape it in here
            
            guard let json = json else{
                if let error = error{
                    
                    // This function has a completion handler as the third parameter
                    //      and it has a generaic type APIResult<T> to Void
                    // When we call fetch(), the completion handler will contain a value
                    //      of API result with an error in failure case or a success case 
                    //      containning the module instance
                    
                    // Here we have an error, so failure case implemented here
                    
                    // Errors regardless what kind, go through to the call side via Failure case
                    
                    
                     completion(.Failure(error))
                    
        // 2.1 Parse json object ----- Fail
                    
                } else {
                    
                    // When the json and error both values are nil
                    // TODO: implementing error handling
                    
                }
                
                // Completion has a return type of void, so we can call return without excess the scope
                
                return
            }
            
            // Now we have a json objecut(type of [String: AnyObject]) of Dictionary structure
            // parse: JSON -> T?: takes a clousure expression
            //      it takes the arguments of JSON, and returns an optional <T>, and will provide
            //      implementation when fetch is called and get us from the json object to an instanciated
            //      module instance
            // Useage: when call this clousure with a json object, it will return as T
        
        // 3. Provide an instance of the module
            
            if let value = parse(json){
                
                // Now we have a fully instancized module type
                
                completion(.Success(value))
                
        // 2.1 Parse json object ----- Success
                
            }else{
                
                // Did have a valued json object, but it is in the wrong format, so parse function return nil
                
                let error = NSError(domain: SHANetworkingErrorDomain, code: UnexpectedResponseError, userInfo:nil)
                completion(.Failure(error))
            }
        }
        
        // Start task and download data
        task.resume()
        
        

        
       
        
        
        
    }
    
    
}


























