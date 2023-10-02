//
//  ViewController.swift
//  StoreSearch Part 1
//
//  Created by James Fernandez on 9/29/23.
//

import UIKit

class SearchViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    
    //Chapter 32 - The search bar delegate method will put some fake data into this array and then display it using the table.
    var searchResults = [SearchResult]()
    var hasSearched = false

    //Chapter 33 - This defines a new struct, TableView, containing a secondary struct named CellIdentifiers which contains a constant named searchResultCell with the value “SearchResultCell”.
    struct TableView {
        struct CellIdentifiers {
            static let searchResultCell = "SearchResultCell"
            static let nothingFoundCell = "NothingFoundCell"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Chapter 32 - This tells the table view to add a 51-point margin at the top to account for the Search Bar.
        tableView.contentInset = UIEdgeInsets(top: 51, left: 0, bottom: 0, right: 0)
        //Chapter 33 - load the nib you just created then you ask the table view to register this nib for the reuse identifier “SearchResultCell”.
        var cellNib = UINib(nibName: TableView.CellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.searchResultCell)
        //Chapter 33 - This also requires you to change let cellNib two lines up to var because you’re re- using the cellNib local variable.
        cellNib = UINib(nibName: TableView.CellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.nothingFoundCell)
        searchBar.becomeFirstResponder()
    }
    
    // MARK: - Helper Methods
    //Chapter - 34 - This first builds a URL string by placing the search text behind the “term=” parameter, and then turns this string into a URL object. Because URL(string:) is a failable initializer, it returns an optional. You force unwrap that using url! to return an actual URL object.
    func iTunesURL(searchText: String) -> URL {
        //chapter 34 - This calls the addingPercentEncoding(withAllowedCharacters:) method to create a new string where all the special characters are escaped, and you use that string for the search term.
        let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let urlString = String(format: "https://itunes.apple.com/search?term=%@", encodedText)
        let url = URL(string: urlString)
        return url!
    }
    
    func performStoreRequest(with url: URL) -> Data? {
        do {
            return try Data(contentsOf: url)
        } catch {
            print("Download Error: \(error.localizedDescription)")
            showNetworkError()
            return nil
        }
    }
    
    //Chapter 34 - You use a JSONDecoder object to convert the response data from the server to a temporary ResultArray object from which you extract the results property.
    func parse(data: Data) -> [SearchResult] {
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(ResultArray.self, from: data)
            return result.results
        } catch {
            print("JSON Error: \(error)")
            return [] }
    }
    
    func showNetworkError() {
        let alert = UIAlertController(title: "Whoops...", message: "There was an error accessing the iTunes Store." + " Please try again.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Search Bar Delegate
//Chapter 32 - instantiate a new String array and replace the contents of searchResults property with it. This is done each time the user performs a search.
extension SearchViewController: UISearchBarDelegate {
    //Chapter 34 - call the new iTunesURL(searchText:) method.
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !searchBar.text!.isEmpty {
            searchBar.resignFirstResponder()
            hasSearched = true
            searchResults = []
            let url = iTunesURL(searchText: searchBar.text!)
            print("URL: '\(url)'")
            //chapter 34 - You simply change the constant for the result from the call to performStoreRequest(with:) from jsonString to data, call the new parse(data:) method, and print the return value.
            if let data = performStoreRequest(with: url) {
                searchResults = parse(data: data)
                //Chapter 34 - After the results array is fetched, you call sort on the searchResults array with a trailing closure that determines the sorting rules.
                searchResults.sort { $0 < $1 } //or searchResults.sort(by: <)
            }
            tableView.reloadData()
        }
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
      return .topAttached
    }
}


// MARK: - Table View Delegate
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    //Chapter 32 - You simply return the number of rows to display based on the contents of the searchResults array and you create a UITableViewCell by hand to display the table rows.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !hasSearched {
            return 0
        } else if searchResults.count == 0 {
            return 1
        } else {
            return searchResults.count
        }
    }
    
    //chapter 33 - You only make a SearchResultCell if there are actually any results. If the array is empty, you’ll simply dequeue the cell for the nothingFoundCell identifier and return it since there is nothing to configure for that cell.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if searchResults.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.nothingFoundCell, for: indexPath)
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
            let searchResult = searchResults[indexPath.row]
            cell.nameLabel.text = searchResult.name
            //Chapter 34 - check that the SearchResult’s artist is not empty.
            if searchResult.artist.isEmpty {
                cell.artistNameLabel.text = "Unknown"
            } else {
                cell.artistNameLabel.text = String(
                    format: "%@ (%@)",
                    searchResult.artist,
                    searchResult.type)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
    tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if searchResults.count == 0 {
            return nil
        } else {
            return indexPath
        }
    }
}
