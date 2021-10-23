//
//  ViewController.swift
//  CoreData_StoreFavourites
//
//  Created by Adsum MAC 1 on 21/10/21.
//

import UIKit
import Foundation
import CoreData

class ViewController: UIViewController {
    @IBOutlet weak var nameTXT: UITextField!
    @IBOutlet weak var emailTXT: UITextField!
    @IBOutlet weak var passwordTXT: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        retriveData()
    }

    @IBAction func loginClicked(_ sender: UIButton) {
        guard nameTXT.text != nil && nameTXT.text != "" else {
            popup(msg: "enter user name")
            return
        }
        guard emailTXT.text != nil && emailTXT.text != "" else {
            popup(msg: "enter user email")
            return
        }
        guard passwordTXT.text != nil && passwordTXT.text != "" else {
            popup(msg: "enter password")
            return
        }
        

        createCoreData()
        
    }
}

// MARK: createCoreData & retriveData
extension ViewController{
    
    func createCoreData(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let userEntity = NSEntityDescription.entity(forEntityName: "UserData", in: managedContext)!
        
        let user = NSManagedObject(entity: userEntity, insertInto: managedContext)
        user.setValue(nameTXT.text, forKey: "name")
        user.setValue(emailTXT.text, forKey: "email")
        user.setValue(passwordTXT.text, forKey: "password")
        user.setValue(true, forKey: "isLogin")
        
        do {
            try managedContext.save()
            let ListViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ListViewController") as! ListViewController
            self.navigationController?.pushViewController(ListViewController, animated: true)
        } catch _ {
            popup(msg: "something went wrong")
        }
    }
    
    func retriveData(){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserData")
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                print(data.value(forKey: "name") as? String as Any)
                print(data.value(forKey: "email") as? String as Any)
                print(data.value(forKey: "password") as? String as Any)
                nameTXT.text = data.value(forKey: "name") as? String
                emailTXT.text = data.value(forKey: "email") as? String
                passwordTXT.text = data.value(forKey: "password") as? String
                
                let isLogin = (data.value(forKey: "isLogin") as? Bool) ?? false
                if isLogin{
                    let ListViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ListViewController") as! ListViewController
                    self.navigationController?.pushViewController(ListViewController, animated: true)
                }
            }
        } catch _ {
            popup(msg: "something went wrong")
        }
    }
    

}

extension UIViewController{
    func popup(msg:String){
        let alertpopup = UIAlertController(title: "", message: msg, preferredStyle: .alert)
        Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(dismissAlert(timer:)), userInfo: nil, repeats: false)
        self.present(alertpopup, animated: true, completion: nil)
    }
    
    @objc func dismissAlert(timer:Timer){
        self.dismiss(animated: true, completion: nil)
        timer.invalidate()
    }
    
}
