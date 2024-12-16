//
//  URL_Extensions.swift
//  Tempestas
//
//  Created by endeavour42 on 15/12/2024.
//

import Foundation

extension URL {
    func loadData(configuration: URLSessionConfiguration? = nil, mock: Bool = false, mockDelay: Double = 3, mockDataName: String? = nil, mockResponse: URLResponse? = nil, mockError: Error? = nil, delegate: URLSessionDelegate? = nil, queue: OperationQueue? = .main, execute: @escaping (Data?, URLResponse?, Error?) -> Void) {
        
        func completionHandler(data: Data?, response: URLResponse?, error: Error?) {
            dispatchPrecondition(condition: .onQueue(queue?.underlyingQueue ?? .main))
            var error = error
            var data = data
            
            if let error {
                print("••• request completed with error: \(error)")
            } else if let r = response as? HTTPURLResponse, r.statusCode < 200 || r.statusCode >= 300 {
                print("••• request completed with URLResponse error: \(r.statusCode), \(r)")
                error = NSError(domain: "URLResponseError", code: r.statusCode)
                data = nil
            } else {
                precondition(data != nil)
                print("request completed with data size \(String(describing: data?.count))")
            }
            execute(data, response, error)
        }
        
        #if code_disabled
        func loadWithMock() {
            let start = Date()
            let session = URLSession(configuration: configuration ?? .default, delegate: delegate, delegateQueue: queue)
            let task = session.dataTask(with: URLRequest(url: self)) { data, response, error in
                if let error {
                    completionHandler(data: nil, response: response, error: error)
                } else {
                    precondition(data != nil)
                    if let mockDataName {
                        let mockData = resourceData(named: mockDataName)
                        if Date() < start + mockDelay {
                            DispatchQueue.main.asyncAfter(deadline: .now() + mockDelay) {
                                completionHandler(data: mockData, response: mockResponse, error: mockError)
                            }
                        } else {
                            completionHandler(data: mockData, response: mockResponse, error: mockError)
                        }
                    } else {
                        completionHandler(data: nil, response: mockResponse, error: mockError)
                    }
                }
            }
            task.resume()
            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                (queue ?? .main).addOperation {
//                    completionHandler(data: mockData, response: mockResponse, error: mockError)
//                }
//            }
        }
        #endif

        // Contrary to a popular misbelief it is fine to "start" asynchronous networking on the main thread.
        // The actual "networking" machinery happens on the system background thread (the main thread is not blocked).
        // Once completed URLSession will hop onto the queue provided (we specified main queue above).
        
        let session = URLSession(configuration: configuration ?? .default, delegate: delegate, delegateQueue: queue)
        let task = session.dataTask(with: URLRequest(url: self), completionHandler: completionHandler)
        task.resume()
    }
}
