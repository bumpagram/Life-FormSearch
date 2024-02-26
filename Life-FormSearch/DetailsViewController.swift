//  ViewController.swift
//  Life-FormSearch
//  Created by .b[u]mpagram on 21/2/24.
//

import UIKit
import SafariServices

class DetailsViewController: UIViewController {
    
    var lifeForm: LifeForm  // // в это свойство пробросится элемент при переходе из SearchTVC по IBSegueAction
    var pagesResponse: PagesResponse?  // это получим из Task сетевого запроса с вложенными свойствами
    var hierarchyResponse: HierarchyResponse?
    var correctItemInTaxonConcepts: TaxonConcepts?
    
    var currentRunningTasks: [String : Task<Void, Never>] = [:] {  // колесо-реестр Task-задач, чтобы показывать и скрывать UIActivityIndicator
        didSet {
            updateLoadingActivity()
        }
    }
    
    
    @IBOutlet var loadingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var licenseButton: UIButton!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var detailsNavigationItem: UINavigationItem!
    @IBOutlet var rightsHolderLabel: UILabel!
    @IBOutlet var nameAccordingToLabel: UILabel!
    @IBOutlet var scientificLabel: UILabel!
    @IBOutlet var kingdomLabel: UILabel!
    @IBOutlet var phylumLabel: UILabel!
    @IBOutlet var classLabel: UILabel!
    @IBOutlet var orderLabel: UILabel!
    @IBOutlet var familyLabel: UILabel!
    @IBOutlet var genusLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        updateUI()
        receiveData()
    }
    
    
    @IBAction func licenseButtonTapped(_ sender: UIButton) {
        if let url = URL(string: licenseButton.currentTitle!) {
            print(url)
            let safari = SFSafariViewController(url: url)
            present(safari, animated: true)
        }
    }
    
    func updateLoadingActivity() {
        if currentRunningTasks.isEmpty {
            loadingActivityIndicator.isHidden = true
        } else {
            loadingActivityIndicator.isHidden = false
        }
    }
    
    
    func updateUI() {
        updateLoadingActivity()
        detailsNavigationItem.title = lifeForm.commonName
        licenseButton.isEnabled = false

        if pagesResponse != nil {
            scientificLabel.text = pagesResponse?.details.scientificName
            
            licenseButton.isEnabled = true
            let buttonTitleLabel = pagesResponse?.details.dataObjects?.first?.license.formatted()  // форматировал URL в String для отображения в лейбле
            licenseButton.setTitle(buttonTitleLabel, for: .normal)
            
            nameAccordingToLabel.text = correctItemInTaxonConcepts?.nameAccordingTo
            if let existedRights = pagesResponse?.details.dataObjects?.first?.rightsHolder {
                rightsHolderLabel.text = existedRights
            } else {
                guard let fullname = pagesResponse?.details.dataObjects?.first?.agents.first?.fullName,
                      let role = pagesResponse?.details.dataObjects?.first?.agents.first?.role else {
                    rightsHolderLabel.text = "API unavailable"
                    return
                }
                rightsHolderLabel.text = "\(String(describing: fullname)), \(String(describing: role))"
            }
        } else {
            rightsHolderLabel.text = "API unavailable"
            nameAccordingToLabel.text = "API unavailable"
            licenseButton.isEnabled = false
            licenseButton.setTitle("API unavailable", for: .disabled)
            scientificLabel.text = lifeForm.scientificName
        }
        
        if hierarchyResponse != nil {
            kingdomLabel.text = "(No Data)"
            phylumLabel.text = "(No Data)"
            classLabel.text = "(No Data)"
            orderLabel.text = "(No Data)"
            familyLabel.text = "(No Data)"
            genusLabel.text = "(No Data)"
            
            hierarchyResponse!.ancestors.forEach({ ancestor in
                if ancestor.taxonRank?.lowercased() == "kingdom" { kingdomLabel.text = ancestor.scientificName }
                if ancestor.taxonRank?.lowercased() == "phylum" { phylumLabel.text = ancestor.scientificName }
                if ancestor.taxonRank?.lowercased() == "class" { classLabel.text = ancestor.scientificName }
                if ancestor.taxonRank?.lowercased() == "order" { orderLabel.text = ancestor.scientificName }
                if ancestor.taxonRank?.lowercased() == "family" { familyLabel.text = ancestor.scientificName }
                if ancestor.taxonRank?.lowercased() == "genus" { genusLabel.text = ancestor.scientificName }
            })
            
        } else {
            kingdomLabel.text = "API unavailable"
            phylumLabel.text = "API unavailable"
            classLabel.text = "API unavailable"
            orderLabel.text = "API unavailable"
            familyLabel.text = "API unavailable"
            genusLabel.text = "API unavailable"
        }
    }
    
    
    func receiveData() {
        
    currentRunningTasks["pagesAPI"] = Task { // положили таску в реестр, обновился через наблюдателя activityIndicator
            do {
              let somePagesResponse = try await NetworkClass.shared.fetchPagesAPI(for: lifeForm)
              self.pagesResponse = somePagesResponse
              print("Successfully fetched PagesAPI")
                
                currentRunningTasks["hierarchyAPI"] =  Task {
                    do {
                        guard let taxonConceptsArray = pagesResponse?.details.taxonConcepts else {return}
                        
                        currentRunningTasks["image"] = Task {
                            guard let existedPropertyPagesURL = pagesResponse?.details.dataObjects?.first?.pictureURL else {
                                currentRunningTasks["image"] = nil
                                return
                            }
                            if let fetchedImage = try? await NetworkClass.shared.fetchImage(from: existedPropertyPagesURL) {
                                print("Successfully fetched Image")
                                imageView.image = fetchedImage
                                updateUI()
                            }
                        currentRunningTasks["image"] = nil
                        }
                        
                        for item in taxonConceptsArray {
                            let someHierarchyResponse = try await NetworkClass.shared.fetchHierarchyAPI(for: item.identifier) // нужно передавать сюда identifier каждого элемента taxonConcepts. если проперти ancestors - не пустой массив, то стоп. и будем отображать его. если пустое- следующий элемент.
                            if !someHierarchyResponse.ancestors.isEmpty {
                                self.hierarchyResponse = someHierarchyResponse
                                self.correctItemInTaxonConcepts = item
                                print("Successfully fetched HierarchyAPI")
                                break
                            }
                        }
                        updateUI()
                        
                    } catch {  print("Error fetching HierarchyAPI: \(error)")  }
                currentRunningTasks["hierarchyAPI"] = nil
                }
                
            }
            catch {  print("Error fetching PagesAPI: \(error)")   }
    currentRunningTasks["pagesAPI"] = nil   // удалили таску из реестра, обновился через наблюдателя activityIndicator
        }
        
    }
    
    
    
    init?(coder: NSCoder, lifeForm: LifeForm) {
        self.lifeForm = lifeForm
        super.init(coder: coder)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

