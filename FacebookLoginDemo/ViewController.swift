//
//  ViewController.swift
//  FacebookLoginDemo
//
//  Created by 海祥陈 on 2018/7/30.
//  Copyright © 2018年 海祥陈. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin

class ViewController: UIViewController, LoginButtonDelegate {
    
    var myLoginButton:UIButton!
    var uidLabel:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if let accessToken = AccessToken.current {
            // User is logged in, use 'accessToken' here.
            print(accessToken.userId!)
            print(accessToken.authenticationToken)
            print(accessToken.grantedPermissions!)
        } else {
            // Add a custom login button to your app
            
            myLoginButton = UIButton(type: .custom)
            myLoginButton.backgroundColor = UIColor.brown
            myLoginButton.frame = CGRect(x: 0, y: 0, width: self.view.frame.width-40, height: 40)
            myLoginButton.center = view.center;
            myLoginButton.setTitle("Facebook custom login", for: .normal)
            myLoginButton.addTarget(self, action: #selector(self.loginButtonClicked), for: .touchUpInside)
            view.addSubview(myLoginButton)
            
            uidLabel = UILabel()
            uidLabel.text = "user id info"
            uidLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.width-40, height: 40)
            uidLabel.center.y = view.center.y - 50
            uidLabel.center.x = view.center.x
            view.addSubview(uidLabel)

        }
    }

    /*!
     Uses FB API's GraphRequest to request user info
     @return Returns String of user's name
     */
    func fetchProfile() {
        let params = ["fields" : "email, picture.type(large), id, name"]
        let graphRequest = GraphRequest(graphPath: "me", parameters: params)
        graphRequest.start {
            (urlResponse, requestResult) in
            
            switch requestResult{
            case .failed(let error):
                print("error in graph request:", error)
                break
            case .success(let graphResponse):
                if let responseDictionary = graphResponse.dictionaryValue {
                    print("Response Dictionary: ", responseDictionary)

                    print("NAME: ", responseDictionary["name"]!)
                    print("EMAIL: ", responseDictionary["email"]!)
                    print("ID: ", responseDictionary["id"]!)
                    
                    self.uidLabel.text = responseDictionary["id"] as? String
                    
                    // Safely unwrapping picture url.
                    if let picture = responseDictionary["picture"] as? Dictionary<String,Any>, let data = picture["data"] as? Dictionary<String,Any>, let url = data["url"] as? String {
                        print("URL: ", url)
                    }
                }
                break
            }
        }
    }
    
    // Function needed for ViewController to be a LoginButtonDelegate
    @objc func loginButtonClicked() {
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [ReadPermission.publicProfile, ReadPermission.email], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                self.myLoginButton.setTitle("Already Logined in", for: .normal);
                self.myLoginButton.isEnabled = false
                print("\nLogged in SUCCESSFULLY!")
                print("\nToken: \(accessToken.authenticationToken)")
                print("\ngrantedPermissions: \(grantedPermissions)")
                print("\ndeclinedPermissions: \(declinedPermissions)")
                self.fetchProfile()
            }
        }
        
    }
    
    // Function needed for ViewController to be a LoginButtonDelegate
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult){
        print("Logged In")
        print("Fetching Profile...")
        fetchProfile()
    }
    
    // Function needed for ViewController to be a LoginButtonDelegate
    func loginButtonDidLogOut(_ loginButton: LoginButton){
        print("Logged Out")
    }
    
    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

