//
//  Fetcher.swift
//  Lecture11
//
//  Created by Van Simmons on 7/29/19.
//  Copyright © 2019 ComputeCycles, LLC. All rights reserved.
//

import Foundation

class Fetcher: NSObject, URLSessionDelegate {
    static var session: URLSession {
        return URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: Fetcher(),
            delegateQueue: nil
        )
    }
    
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
        ) {        NSLog("\(#function): Session received authentication challenge")
        completionHandler(.performDefaultHandling, nil)
    }
}

extension String: Error {}

struct DataTaskCompletion {
    var data: Data?
    var response: URLResponse?
    var netError: Error?
}


extension Fetcher {
    typealias RawCompletionHandler = (Result<DataTaskCompletion, String>) -> Void
    static func fetchRaw(url: URL, completion: @escaping RawCompletionHandler) {
        session.dataTask(with: url) { (data: Data?, response: URLResponse?, netError: Error?) in
            let result = DataTaskCompletion(data: data, response: response, netError: netError)
            completion(.success(result))
        }
        .resume()
    }
    
}
