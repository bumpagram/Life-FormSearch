//  ViewController.swift
//  Life-FormSearch
//  Created by .b[u]mpagram on 21/2/24.
//

import UIKit

class DetailsViewController: UIViewController {
    
    var lifeForm: LifeForm  // // в это свойство пробросится элемент при переходе из SearchTVC по IBSegueAction
    var pagesResponse: PagesResponse?  // это получим из Task сетевого запроса с вложенными свойствами
    var hierarchyResponse: HierarchyResponse?
    var correctItemInTaxonConcepts: TaxonConcepts?
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var detailsNavigationItem: UINavigationItem!
    @IBOutlet var rightsHolderLabel: UILabel!
    @IBOutlet var licenseLabel: UILabel!
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
        //updateUI()
        
    }
    
    
    func updateUI() {
        detailsNavigationItem.title = lifeForm.commonName
        if pagesResponse != nil {
            scientificLabel.text = pagesResponse?.details.scientificName
            licenseLabel.text = pagesResponse?.details.dataObjects?.first?.license.formatted()  // форматировал URL в String для отображения в лейбле
            nameAccordingToLabel.text = correctItemInTaxonConcepts?.nameAccordingTo
            if let existedRights = pagesResponse?.details.dataObjects?.first?.rightsHolder {
                rightsHolderLabel.text = existedRights
            } else {
                let fullname = pagesResponse?.details.dataObjects?.first?.agents.first?.fullName
                let role = pagesResponse?.details.dataObjects?.first?.agents.first?.role
                rightsHolderLabel.text = "\(String(describing: fullname)), \(String(describing: role))"
            }
        } else {
            scientificLabel.text = lifeForm.scientificName
            licenseLabel.text = "API unavailable"
            nameAccordingToLabel.text = "API unavailable"
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
        Task {
            do {
              let somePagesResponse = try await NetworkClass.shared.fetchPagesAPI(for: lifeForm)
              self.pagesResponse = somePagesResponse
              print("Successfully fetched PagesAPI")
                
                Task {
                    do {
                        guard let taxonConceptsArray = pagesResponse?.details.taxonConcepts else {return}
                        
                        Task {
                            guard let existedPropertyPagesURL = pagesResponse?.details.dataObjects?.first?.pictureURL else {return}
                            if let fetchedImage = try? await NetworkClass.shared.fetchImage(from: existedPropertyPagesURL) {
                                print("Successfully fetched Image")
                                imageView.image = fetchedImage
                                updateUI()
                            }
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
                }
                
                
            }
            catch {  print("Error fetching PagesAPI: \(error)")   }
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

