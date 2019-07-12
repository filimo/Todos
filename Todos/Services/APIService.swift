//
//  APIService.swift
//  test-SwiftUI-3
//
//  Created by Viktor Kushnerov on 7/10/19.
//  Copyright © 2019 Viktor Kushnerov. All rights reserved.
//

import Foundation
import Combine


public enum APIError: Error, LocalizedError {
    case apiError(reason: String)
    case parserError(reason: String)
    
    public var errorDescription: String? {
        switch self {
        case .apiError(let reason),
             .parserError(let reason):
            return reason
        }
    }
}

final class APIService {
    private var url: String
    
    init(_ url: String) {
        self.url = url
    }
    
    func fetch(with queryItems: [URLQueryItem]? = nil) -> AnyPublisher<Data, APIError> {
        var urlComponents = URLComponents(string: url)!
        urlComponents.queryItems = queryItems
        
        let request = URLRequest(url: urlComponents.url!)
        
        return URLSession.DataTaskPublisher(request: request, session: .shared)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.apiError(reason: "Invalid response: \(response)")
                }
                    
                guard 200..<300 ~= httpResponse.statusCode else {
                    let response = "Recieved the following status code: \(httpResponse.statusCode)"
                    throw APIError.apiError(reason: response)
                }
                return data
            }
            .mapError { error in
                if let error = error as? APIError {
                    return error
                } else {
                    return APIError.apiError(reason: error.localizedDescription)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func fetch<T: Decodable>(with queryItems: [URLQueryItem]? = nil) -> AnyPublisher<T, APIError> {
        print(T.self)
        
        return fetch(with: queryItems)
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                if let error = error as? DecodingError {
                    var errorToReport = error.localizedDescription
                    switch error {
                    case .dataCorrupted(let context):
                        let details = context.underlyingError?.localizedDescription ?? context.codingPath.map { $0.stringValue }.joined(separator: ".")
                        errorToReport = "\(context.debugDescription) - (\(details))"
                    case .keyNotFound(let key, let context):
                        let details = context.underlyingError?.localizedDescription ?? context.codingPath.map { $0.stringValue }.joined(separator: ".")
                        errorToReport = "\(context.debugDescription) (key: \(key), \(details))"
                    case .typeMismatch(let type, let context), .valueNotFound(let type, let context):
                        let details = context.underlyingError?.localizedDescription ?? context.codingPath.map { $0.stringValue }.joined(separator: ".")
                        errorToReport = "\(context.debugDescription) (type: \(type), \(details))"
                    @unknown default:
                        break
                    }
                    return APIError.parserError(reason: errorToReport)
                }  else {
                    return APIError.apiError(reason: error.localizedDescription)
                }
            }
            .eraseToAnyPublisher()
    }
}

