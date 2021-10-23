//
//  ListViewController.swift
//  CoreData_StoreFavourites
//
//  Created by Adsum MAC 1 on 21/10/21.
//

import UIKit
import Alamofire
import CoreData

var favouriteDrinks = [String]()
var drinksData = [NSDictionary]()
class ListViewController: UIViewController {

    
    @IBOutlet weak var CocktailTable: UITableView!
    @IBOutlet weak var nodataAvailable: UILabel!
    
   
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        tableSetup()
        
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        getFavourites()
    }

    @IBAction func favBTNCLicked(_ sender: UIButton) {
        
        let favVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FavsViewController") as! FavsViewController
        
        self.navigationController?.pushViewController(favVC, animated: true)
    }
    

}

// MARK: getCocktaildata
extension ListViewController{
    func getCocktaildata(){
        AF.request("https://www.thecocktaildb.com/api/json/v1/1/search.php?s=all").responseJSON { response in
            switch response.result{
                case .success(_):
                    print("Success")
                    print(response.result)
                    let success = response.value as? NSDictionary
                    drinksData = (success?["drinks"] as? [NSDictionary]) ?? []
                    
                    if drinksData.count == 0{
                        self.nodataAvailable.isHidden = false
                    }else{
                        self.nodataAvailable.isHidden = true
                    }
                    self.CocktailTable.reloadData()
                    
                case .failure( _):
                    self.popup(msg: response.error?.localizedDescription ?? "Something went wrong")
            }
        }
    }
}

extension ListViewController:UITableViewDelegate,UITableViewDataSource{
    func tableSetup(){
        CocktailTable.delegate = self
        CocktailTable.dataSource = self
        CocktailTable.register(UINib(nibName: "CocktailCell", bundle: nil), forCellReuseIdentifier: "CocktailCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return drinksData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CocktailCell") as! CocktailCell
        
        let drink = drinksData[indexPath.row]
        let id = (drink["idDrink"] as? String) ?? ""
        print(id as Any)
        
        cell.name.text = drink["strDrink"] as? String
        cell.category.text = drink["strCategory"] as? String
        cell.descriptionOfProduct.text = drink["strInstructions"] as? String
        
        var usedstr = "used "
        for i in 1...10 {
            let str = (drink["strIngredient\(i)"] as? String) ?? ""
            if i != 1 && str != ""{
                usedstr.append(", \(str)")
            }else{
                usedstr.append(str)
            }
        }
        usedstr.append(" in this drink")
        cell.userMaterial.text = usedstr
       
        DispatchQueue.main.async {
            let imgstr = (drink["strDrinkThumb"] as? String) ?? ""
            if let url = URL(string: imgstr){
                do {
                    let imgData = try Data(contentsOf: url)
                    cell.img.image = UIImage(data: imgData)
                } catch {
                    print("Image not found")
                    cell.img.image = UIImage(systemName: "questionmark.diamond")
                }
            }else{
                cell.img.image = UIImage(systemName: "questionmark.diamond")
            }
        }
        
        if favouriteDrinks.contains(id){
            cell.favBTN.superview?.tag = 1
            cell.favBTN.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        }else{
            cell.favBTN.superview?.tag = 0
            cell.favBTN.setImage(UIImage(systemName: "heart"), for: .normal)
        }
        
        cell.favBTN.tag = indexPath.row
        cell.favBTN.addTarget(self, action: #selector(favBTNClicked(sender:)), for: .touchUpInside)
        return cell
    }
    
    
    // MARK: favourite button action
    @objc func favBTNClicked(sender:UIButton){
        let drink = drinksData[sender.tag]
        if let id = drink["idDrink"] as? String{
            addToFav(id: id, isFav: sender.superview?.tag ?? 0)
        }else{
            popup(msg: "Something went wrong, so can't add to favourite")
        }
      
    }
}


extension ListViewController{
    
    // MARK: get favourite ids
    func getFavourites(){
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appdelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserData")
        
        do {
           let data = try managedContext.fetch(fetchRequest)
            let favsData = data as! [NSManagedObject]
            
            let idStr = (favsData.first?.value(forKey: "fav_ids") as? String) ?? ""
            let idsArray = idStr.components(separatedBy: ",")
            
            favouriteDrinks = []
            for favId in idsArray{
                favouriteDrinks.append(favId)
            }
            getCocktaildata()
            
        } catch{
            popup(msg: "Something went wrong")
        }
    }
    
    
    // MARK: add id to favourite
    func addToFav(id:String,isFav:Int) {
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appdelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserData")
        
        do {
            let object = try managedContext.fetch(fetchRequest)
            let updateIds = object.first as? NSManagedObject
            var Ids = updateIds?.value(forKey: "fav_ids") as? String
            
            if isFav == 0{
                if Ids == nil{
                    Ids = ""
                }
                if Ids != ""{
                    Ids?.append(",\(id)")
                }else{
                    Ids?.append("\(id)")
                }
                favouriteDrinks.append(id)
            }else{
                var idsArray = Ids?.components(separatedBy: ",")
                if let removeid = (idsArray?.firstIndex(of: id)){
                    idsArray?.remove(at: removeid)
                }
                favouriteDrinks = idsArray ?? []
                Ids = ""
                for i in idsArray ?? []{
                    if idsArray?.first == i{
                        Ids?.append(i)
                    }else{
                        Ids?.append(",\(i)")
                    }
                }
            }
            
            updateIds?.setValue(Ids, forKey: "fav_ids")
            
            do {
                try managedContext.save()
              
                CocktailTable.reloadData()
               
            } catch {
                popup(msg: "Something went wrong")
            }
        } catch {
            popup(msg: "Something went wrong")
        }
    }
}
