//
//  DTAPIClient.swift
//  DentalTrauma
//
//  Created by AlphaVed Mac on 28/09/17.
//  Copyright © 2017 AlphaVed. All rights reserved.
//

import UIKit
//import AFNetworking

class DTAPIClient: NSObject { //Using URLSession
    
    class var sharedInstance : DTAPIClient {
        
        struct Static {
        
            static var instance : DTAPIClient = DTAPIClient()
        }
        return Static.instance
    }

    //MARK:- Get API Call
    func getAPICall(urlString: String!, parameters: Any!, completionHandler:@escaping (Any?, URLResponse?, Error?)->()) ->() {
        
        print("Calling API: \(urlString!)")
        
        let urlSession = URLSession(configuration: URLSessionConfiguration.default)
        let newURLString : String = (urlString! as String).replacingOccurrences(of: " ", with: "%20")
        let callURL = URL.init(string: newURLString)
        var request = URLRequest.init(url: callURL!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 60.0)
        request.httpMethod = "GET"
        
        let dataTask = urlSession.dataTask(with: request) { (data,response,error) in
            
            if error != nil {
                
                completionHandler(nil, response, error)
            }
            else{
                
                do {
                    
                    let resultJson = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String:AnyObject]
                    completionHandler(resultJson, response, nil)
                }
                catch {
                    
                    print("Error -> \(error)")
                    completionHandler(nil, response, error)
                }
            }
            
        }
        dataTask.resume()
    }
    
    func getAPICallWithReturnData(urlString: NSString!, parameters: Any!, completionHandler:@escaping (Any?, URLResponse?, Error?)->()) ->() {
        
        print("Calling API: \(urlString!)")
        
        let urlSession = URLSession(configuration: URLSessionConfiguration.default)
        let newURLString : String = (urlString! as String).replacingOccurrences(of: " ", with: "%20")
        let callURL = URL.init(string: newURLString)
        var request = URLRequest.init(url: callURL!, cachePolicy: URLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: 60.0)
        request.httpMethod = "GET"
        
        let dataTask = urlSession.dataTask(with: request) { (data,response,error) in
            
            if error != nil {
                
                completionHandler(nil, response, error)
            }
            else {
                
                completionHandler(data, response, nil)
            }
            
        }
        dataTask.resume()
    }
    
    
    //MARK:- POST API Call
    func postAPICall(urlString: String!, parameters: Any!, completionHandler:@escaping (Any?, URLResponse?, Error?)->()) ->() {
        
        print("Calling API: \(urlString!)")

        var postString = String()
        if parameters != nil {
            postString = DTHelperClass.sharedInstance.dictionaryToString(dict: parameters as! NSDictionary)
        }
        
        let urlSession = URLSession(configuration: URLSessionConfiguration.default)
        let newURLString : String = (urlString! as String).replacingOccurrences(of: " ", with: "%20")
        let callURL = URL.init(string: newURLString)
        var request = URLRequest.init(url: callURL!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 60.0)
        request.httpMethod = "POST"
        request.httpBody = postString.data(using: .utf8)
        
        let dataTask = urlSession.dataTask(with: request) { (data,response,error) in
            
            if error != nil {
                
                completionHandler(nil, response, error)
            }
            else{
                do {
                    
                    let resultJson = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String:AnyObject]
                    completionHandler(resultJson, response, nil)
                }
                catch {
                    completionHandler(nil, response, error)
                }
            }
            
        }
        dataTask.resume()
    }
    
    func postAPIcallWithPostData(urlString: String, parameters: Any!, postData: Data, imageKey: String,mimeType: String, completionHandler:@escaping (Any?, URLResponse?, Error?)->()) ->() {
        
        print("Calling API: \(urlString)")
        
        //Create request
        let callURL = URL.init(string: urlString as String)
        var request = URLRequest.init(url: callURL!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 240.0)
        request.httpMethod = "POST"
        request.httpShouldHandleCookies = false
        
        let boundary = "---------------------------14737809831466499882746641449"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let body = NSMutableData()
        
        //Add imagedata
        let fileName : String = imageKey
        let randomstring = ""
        
        var postExtension = String()
        
        if (mimeType == "image/png") {
            postExtension = "jpeg"
        }
        else if (mimeType == "mp4") {
            postExtension = mimeType
        }
        else if (mimeType == "gif") {
            postExtension = mimeType
        }
        
        let photoName: String = "\(randomstring).\(postExtension)"
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"\(fileName)\"; filename=\"\(photoName)\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(postData)
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        
        //Add parameter..
        for (key, value) in parameters as! NSDictionary {
            
            body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: String.Encoding.utf8)!)
            body.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!)
            body.append("\r\n".data(using: String.Encoding.utf8)!)
        }
        
        request.httpBody = body as Data
        request.setValue("\(body.length)", forHTTPHeaderField: "Content-Length")
        
        let urlSession = URLSession(configuration: URLSessionConfiguration.default)
        let dataTask = urlSession.dataTask(with: request) { (data,response,error) in
            
            if error != nil {
                
                completionHandler(nil, response, error)
            }
            do {
                
                let resultJson = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String:AnyObject]
                
                completionHandler(resultJson, response, nil)
            }
            catch {
                print("Error -> \(error)")
            }
        }
        dataTask.resume()
    }
}

//class DTAFNetworkingAPIClient: NSObject,NSURLConnectionDataDelegate { //Using AFNetworking
//
//    let manager : AFHTTPSessionManager = AFHTTPSessionManager()
//
//    //MARK:- Create Instance of Class
//    class var sharedInstance : DTAFNetworkingAPIClient {
//
//        struct Static {
//
//            static let instance : DTAFNetworkingAPIClient = DTAFNetworkingAPIClient()
//        }
//        return Static.instance
//    }
//
//    //MARK:- GET API Call
//    func getAPICall(url: String, parameters: NSDictionary!, completionHandler:@escaping (URLSessionDataTask, NSDictionary?, Error?)->()) ->() {
//
//        print("Calling API: \(url)")
//
//        manager.responseSerializer = AFJSONResponseSerializer(readingOptions: JSONSerialization.ReadingOptions.allowFragments) as AFJSONResponseSerializer
//        manager.responseSerializer.acceptableContentTypes = NSSet(objects:"application/json", "text/html", "text/plain", "text/json", "text/javascript", "audio/wav") as? Set<String>
//
//        manager.requestSerializer = AFJSONRequestSerializer() as AFJSONRequestSerializer
//        manager.requestSerializer.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
//
//        manager.get(url as String, parameters: parameters, progress: nil, success: { (operation, responseObject) in
//
//            print("Response: \(responseObject!)")
//            completionHandler(operation, responseObject! as? NSDictionary , Error?.self as? Error)
//
//        }) {(operation, error) in
//
//            print("Error: " + error.localizedDescription)
//            completionHandler(operation!, nil ,error)
//        }
//    }
//
//    //MARK:- POST API Call
//
//    //POST API
//    func postAPICall(url: String, parameters: NSDictionary!, completionHandler:@escaping (URLSessionDataTask, NSDictionary?, Error?)->()) ->() {
//
//        print("Calling API: \(url)")
//
//        manager.post(url as String, parameters: parameters, progress: nil, success: { (operation, responseObject) in
//
//            print("Response: \(responseObject!)")
//            completionHandler(operation,responseObject! as? NSDictionary, Error?.self as? Error)
//
//        }) { (operation, error) in
//
//            print("Error: " + error.localizedDescription)
//            completionHandler(operation!, nil ,error)
//        }
//    }
//
//    //POST API With Image
//    func postAPICallWithImage(url: String, parameters: NSDictionary!, image : UIImage!, completionHandler:@escaping (URLSessionDataTask, NSDictionary?, Error?)->()) ->() {
//
//        print("Calling API: \(url)")
//
//        manager.post(url as String, parameters: parameters, constructingBodyWith: { (formData: AFMultipartFormData!) in
//
//            /*      FOR IMAGE UPLOAD
//             if data?.allValues.count != 0 && data != nil
//             {
//
//             let fileUrl = NSURL(fileURLWithPath: (data?.valueForKey("filePath"))! as! String)
//             try! formData.appendPartWithFileURL(fileUrl, name: (data?.valueForKey("key"))! as! String)
//             }
//             */
//
//        }, progress: nil, success: { (operation, responseObject) in
//
//            print("Response: \(responseObject!)")
//            completionHandler(operation,responseObject as? NSDictionary, Error?.self as? Error)
//
//        }) { (operation, error) in
//
//            print("Error: " + error.localizedDescription)
//            completionHandler(operation!, nil ,error)
//        }
//    }
//
//    //...END..//
//}

