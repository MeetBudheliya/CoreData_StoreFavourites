//
//  FavsViewController.swift
//  CoreData_StoreFavourites
//
//  Created by Adsum MAC 1 on 22/10/21.
//

import UIKit
import CoreData

class FavsViewController: UIViewController {

    @IBOutlet weak var favList: UITableView!
    @IBOutlet weak var nodataLBL: UILabel!
    var favListData = [NSDictionary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
tableSetup()
   
    }
    
    override func viewDidAppear(_ animated: Bool) {
      favListData = []
        for i in drinksData {
            let id = (i["idDrink"] as? String) ?? ""
            print(id as Any)
            if favouriteDrinks.contains(id){
                favListData.append(i)
            }
        }
        if favListData.count == 0{
            nodataLBL.isHidden = false
        }else{
            nodataLBL.isHidden = true
        }
        favList.reloadData()
        
    }
    @IBAction func homebtnClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension FavsViewController:UITableViewDelegate,UITableViewDataSource{
 
    func tableSetup(){
        favList.delegate = self
        favList.dataSource = self
        favList.register(UINib(nibName: "CocktailCell", bundle: nil), forCellReuseIdentifier: "CocktailCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favListData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CocktailCell") as! CocktailCell
        let drink = favListData[indexPath.row]
        
        let id = (drink["idDrink"] as? String) ?? ""
        print(id as Any)
        cell.name.text = drink["strDrink"] as? String
        cell.category.text = drink["strCategory"] as? String
        cell.descriptionOfProduct.text = drink["strInstructions"] as? String
        
        var usedstr = "used "
        for i in 1...10 {
            let str = (drink["strIngredient\(i)"] as? String) ?? ""
            if i != 1 && str != ""{
                usedstr.append(",\(str)")
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
        let drink = favListData[sender.tag]
        if let id = drink["idDrink"] as? String{
            addToFav(id: id, isFav: sender.superview?.tag ?? 0)
        }else{
            popup(msg: "Something went wrong, so can't add to favourite")
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
              
                self.viewDidAppear(true)
               
            } catch {
                popup(msg: "Something went wrong")
            }
        } catch {
            popup(msg: "Something went wrong")
        }
    }
    
}
