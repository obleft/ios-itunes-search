//
//  SearchResultController.swift
//  ios-itunes-search
//
//  Created by Benjamin Hakes on 12/5/18.
//  Copyright © 2018 Benjamin Hakes. All rights reserved.
//

import Foundation

class SearchResultController {
    
    static let baseURL = "https://itunes.apple.com/search"
    
    var searchResults: [SearchResult] = [] //This will be the data source for the table view.
    
    // Add the completion last
    func performSearch(with searchTerm: String, resultType: ResultType, completion: @escaping ([SearchResult]?, Error?) -> Void) {
        
        // Establish the base url for our search
        guard let baseURL = URL(string: SearchResultController.baseURL)
            else {
                fatalError("Unable to construct baseURL")
        }
        
        // Decompose it into its components
        guard var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
            fatalError("Unable to resolve baseURL to components")
        }
        
        // Create the query item using `search` and the search term
        let searchQueryItem = URLQueryItem(name: "term", value: searchTerm)

        let searchQueryItem2 = URLQueryItem(name: "entity", value: resultType.rawValue)
        
        // Add in the search term
        urlComponents.queryItems = [searchQueryItem,searchQueryItem2]
        
        // Recompose all those individual components back into a fully
        // realized search URL
        guard let searchURL = urlComponents.url else {
            NSLog("Error constructing search URL for \(searchTerm)")
            completion(nil, NSError())
            return
        }

        // Create a GET request
        var request = URLRequest(url: searchURL)
        request.httpMethod = "GET" // basically "READ"
        
        // Asynchronously fetch data
        // Once the fetch completes, it calls its handler either with data
        // (if available) _or_ with an error (if one happened)
        // There's also a URL Response but we're going to ignore it
        let dataTask = URLSession.shared.dataTask(with: request) {
            // This closure is sent three parameters:
            data, _, error in
            
            // Rehydrate our data by unwrapping it
            guard error == nil, let data = data else {
                if let error = error { // this will always succeed
                    NSLog("Error fetching data: \(error)")
                    completion(nil, error) // we know that error is non-nil
                }
                return
            }
            
            // We know now we have no error *and* we have data to work with
            
            // Convert the data to JSON
            do {
                // Declare, customize, use the decoder
                let jsonDecoder = JSONDecoder()
                
                // Perform decoding into [SearchResult] stored in SearchResults
                let searchResults = try jsonDecoder.decode(SearchResults.self, from: data)
                let results = searchResults.results
                
                // Send back the results to the completion handler
                self.searchResults = results
                completion(results, nil)
                
            } catch {
                NSLog("Unable to decode data into search results: \(error)")
                completion(nil, error)
                //        return
            }
        }
        
        // A data task needs to be run. To start it, you call `resume`.
        // "Newly-initialized tasks begin in a suspended state, so you need to call this method to start the task."
        dataTask.resume()
    }
}
