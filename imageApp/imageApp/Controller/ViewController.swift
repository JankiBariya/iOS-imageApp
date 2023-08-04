//
//  ViewController.swift
//  imageApp
//
//  Created by PMCLAP1240 on 06/02/23.
//

import UIKit
import Foundation
import Kingfisher



class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
   
    
    
    // PROPERTIES
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    // DECLARATIONS 
    var response:  ModalClass?
    var photo = Photo?.self
    var source = Src?.self
    var pageNumber = 1
    var dataArray = [Photo]()
    var request = URLRequest(url: URL(string: "https://api.pexels.com/v1/search?query=ocean&per_page=10&page=2")!,timeoutInterval: Double.infinity)
    var photoss: [Photo] = []
    var isLoading = false
  
    
    
    
    
     // TABLE CONTENTS
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photoss.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TableViewCell
        
        let data2 = photoss[indexPath.row]
       
        cell.altTextLabel?.numberOfLines = 0
        cell.photographerLabel.text = " Photographer: \(data2.photographer ?? "")"
        cell.altTextLabel.text = " alt-text: \(data2.alt ?? "")"
        
       //to display image
        URLSession.shared.dataTask(with: request) { data, response, error in
            if data != nil {
                let imageUrl = URL(string: (data2.src?.medium)!)
                cell.imgView.kf.setImage(with: imageUrl, placeholder: UIImage(named: "placeholderImage"))
           DispatchQueue.global().async {
               let data = try? Data(contentsOf: imageUrl!)
               DispatchQueue.main.async {
                   cell.imgView?.image = UIImage(data: data!)
                 }
             }
          }
        }.resume()
        
           
        //for cell background color
        let bgcolor = data2.avgColor ?? ""
        let color = hexStringToUIColor(hex: bgcolor)
        cell.altTextLabel.backgroundColor = color
        cell.photographerLabel.backgroundColor = color
        

        return cell
    }
    

    
    
    // PARSING FUNCTION
    func parse(json: Data) {
        let decoder = JSONDecoder()
        
        do {
            let jsonEvents = try decoder.decode(ModalClass.self, from: json)
                
                response = jsonEvents
                
                photoss.append(contentsOf: jsonEvents.photos)
                
                
                DispatchQueue.main.async { [self] in
                    self.tableView.reloadData()
                }
        }
        catch DecodingError.dataCorrupted(let context) {
            print(context)
        } catch DecodingError.keyNotFound(let key, let context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch DecodingError.valueNotFound(let value, let context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch DecodingError.typeMismatch(let type, let context) {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch {
            print("error: ", error)
        }
        
    }
    
    
    
    // CELL BACKGROUND COLOR FUNCTION
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
            
        }
        if ((cString.count) != 6) {
            return UIColor.gray
            
        }
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        return UIColor(
                       red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                       green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                       blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                       alpha: CGFloat(1.0)
        )
    }
    
    
    
    //scroll function
    func scrollViewDidScroll(_ scrollView: UIScrollView, query: String) {
            let height = scrollView.frame.size.height
            let contentYoffset = scrollView.contentOffset.y
            let distanceFromBottom = scrollView.contentSize.height - contentYoffset*2
        
            if distanceFromBottom < height {
                
                if self.photoss.count <= pageNumber * 10 {
                    isLoading = true
                    pageNumber += 1
                    searchPhotos(query: query)
                }
            }
    }
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        if (maximumOffset - currentOffset <= 10.0) {
            pageNumber += 1
        }
      
    }
    
    
    
    // function to load activity-indicator
    func loader() -> UIAlertController {
        let alert = UIAlertController(title: nil, message: "Please wait a sec...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.color = .blue
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.large
        loadingIndicator.startAnimating()
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
        return alert
        
    }
    
    func stopLoader(loader : UIAlertController) {
        DispatchQueue.main.async {
            loader.dismiss(animated: true, completion: nil)
        }
    }
  
  
    // a fetching function
    func fetch(query: String){
        let networkModule = NetworkModule()
        networkModule.fetchData(word: query, pagination: false, pageNo: pageNumber) { data, error in
            if let responseData = data {
                self.parse(json: responseData)
            }
        }
    }
   
    
    //function to reset page
    func resetPageNumber() {
        pageNumber = 1
    }
   
    
    func searchPhotos(query: String) {
        fetch(query: query)
    }
    

//     searchbar function
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
            guard let query = searchBar.text, !query.isEmpty else {
                return
            }
        photoss = []
        searchPhotos(query: query)
        tableView.reloadData()

    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        resetPageNumber()       // Perform search with updated search text and page number
    }
    
    
    
      // LIFECYCLE
    
    override func viewDidAppear(_ animated: Bool) {
        let loader =   self.loader()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.stopLoader(loader: loader)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Images"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 310
        searchBar.delegate = self

    }
    
}
