//  SearchTableViewController.swift
//  Life-FormSearch
//  Created by .b[u]mpagram on 22/2/24.

import UIKit


class SearchTableViewController: UITableViewController, UISearchBarDelegate {
    
    var searchResults = [LifeForm]() 
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var loadingActivityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLoadingActivity(isVisible: false)
    }
    
    
    func processUserInput() {
        // для обработки query параметров из searchBar + task на Network.fetchSearch
        searchResults = []
        tableView.reloadData()
        let searchTerm = searchBar.text ?? ""
        guard !searchTerm.isEmpty else {return}
        let userQuery = [
            "q" : "\(searchTerm.lowercased())"
        ]
        
        Task {
            do {
                let serverResponce = try await NetworkClass.shared.fetchSearchResults(for: userQuery)
                // if successful, use the main queue to set property and reload the table view
                searchResults = serverResponce
                print("Successfully fetched SearchResult items.")
                tableView.reloadData()
            } catch {
                print("Error fetching items: \(error)")
            }
        }
    }
    
    func updateLoadingActivity(isVisible now: Bool?) {
        if now == true {
            loadingActivityIndicator.isHidden = false
        } else {
            loadingActivityIndicator.isHidden = true
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // метод из протокола для захвата события типо editingDidEnd/returnKeyPressed
        searchBar.resignFirstResponder()
        updateLoadingActivity(isVisible: true)
        processUserInput()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.resignFirstResponder()
        searchResults.removeAll()
        tableView.reloadData()
        updateLoadingActivity(isVisible: false)
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        // Configure the cell...
        var content = cell.defaultContentConfiguration()
        let elementToShow = searchResults[indexPath.row]
        content.text = elementToShow.commonName
        content.secondaryText = elementToShow.scientificName
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */


   
    // MARK: - Navigation

     @IBSegueAction func showDetails(_ coder: NSCoder, sender: Any?, segueIdentifier: String?) -> DetailsViewController? {
         guard let cell = sender as? UITableViewCell, let indexpath = tableView.indexPath(for: cell) else { return nil }
         let tappedElement = searchResults[indexpath.row]
         
      return DetailsViewController(coder: coder, lifeForm: tappedElement)
     }
     
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension Data {
    func prettyPrintedJSONstring() {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: self, options: []),
              let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
              let prettyJSONstring = String(data: jsonData, encoding: .utf8) else {
            print("Failed to read JSON object")
            return
        }
        print(prettyJSONstring) // кастомный метод для вывода в консоль джейсонов в читабельном виде
    }
}
