//
//  ViewController.swift
//  CoppelExam
//
//  Created by Victor Aguayo on 26/09/22.
//

import UIKit

class ViewController: UIViewController {
    let getTokenURL = "https://api.themoviedb.org/3/authentication/token/new?api_key=137b11a240f2116a7e7712d532aa0286"
    let validateLoginUrl = "https://api.themoviedb.org/3/authentication/token/validate_with_login?api_key=137b11a240f2116a7e7712d532aa0286"

    @IBOutlet weak var Response: UILabel!
    
    @IBOutlet weak var pass: UITextField!
    @IBOutlet weak var userName: UITextField!
    
    @IBAction func LoginRequest(_ sender: UIButton) {
        let userNameIsEmpty = (userName.text ?? "").isEmpty
        let passwordIsEmpty = (pass.text ?? "").isEmpty
        if(userNameIsEmpty || passwordIsEmpty){
            Response.text = "User and password neccesary"
            return
        }
        let userNameValue = userName.text ?? ""
        let passwordValue = pass.text ?? ""
        let url = URL(string: getTokenURL)!
        var request = URLRequest(url: url)
        var requestToken=""
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { [self] data, response, error in
            guard
                let data = data,
                let response = response as? HTTPURLResponse,
                error == nil
            else {                                                               // check for fundamental networking error
                print("error", error ?? URLError(.badServerResponse))
                return
            }
            
            guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    
                    print(json)
                    var isSuccess=0
                    
                    if ((json["success"] as? Int) != nil){
                        isSuccess = json["success"] as! Int
                    }
                    if(isSuccess==1){
                        print("entro")
                        if ((json["request_token"] as? String) != nil){
                            requestToken = json["request_token"] as! String
                            print (requestToken)
                            //si todo funciona correctamente procedemos a la autenticaciòn con post
                            login(token: requestToken, userName: userNameValue, password: passwordValue)
                            
                        }
                    }
                    else{
                        print("Datos Incorrectos")
                    }
                    
                }
            } catch {
                print(error) // parsing error
                
                if let responseString = String(data: data, encoding: .utf8) {
                    print("responseString = \(responseString)")
                } else {
                    print("unable to parse response as string")
                }
            }
        }
        task.resume()
    }
  
    
    func login(token: String, userName: String, password: String){
        print(token)
        
        let url = URL(string: validateLoginUrl)!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        request.httpMethod = "POST"
        
        let parameters: [String: Any] =
        [
            "username": userName,
            "password": password,
            "request_token":token
        ]
        
        do {
            // convert parameters to Data and assign dictionary to httpBody of request
            var jsonResult = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
                request.httpBody = jsonResult
            
            print(String(data: jsonResult, encoding: .utf8))
          } catch let error {
              print("Error al serializar")
            print(error.localizedDescription)
            return
          }
        
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            guard
                let data = data,
                let response = response as? HTTPURLResponse,
                error == nil
            else {
                print("error", error ?? URLError(.badServerResponse))
                return
            }
            
            guard (200 ... 299) ~= response.statusCode else {
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                
                let dataString = String(data: data, encoding: .utf8)
                print("dataString = \(dataString)")
                
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    
                    print(json)
                    var isSuccess=0
                    
                    if ((json["success"] as? Int) != nil){
                        isSuccess = json["success"] as! Int
                    }
                    if(isSuccess==1){
                        print("Loggeado")
                        //self.sendToMovies(token: token)
                        
                    }
                    else{
                        print("Datos Incorrectos")
                        let alert = UIAlertController(title: "Alert", message: "Usuario o contraseña Incorrectos", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Click", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                    
                }
            } catch {
                print(error)
                if let responseString = String(data: data, encoding: .utf8) {
                    print("responseString = \(responseString)")
                } else {
                    print("unable to parse response as string")
                }
            }
        }
        task.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //view.backgroundColor = .darkGray
    }
    func sendToMovies(token: String){
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "movies_view") as? MoviesViewController else {return}
        
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

}

