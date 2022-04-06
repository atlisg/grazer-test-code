//
//  ViewController.swift
//  UserList
//
//  Created by Atli Saevar on 4.4.2022.
//

import UIKit

class ViewController: UIViewController {

    var isLoggedIn = false
    var token = ""
    var users: [User] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    fileprivate func updateUI() {
        if isLoggedIn {
            view.backgroundColor = .black
        } else {
            view.backgroundColor = .white
        }
    }

    struct AuthData: Decodable {
        let token: String
    }

    struct Auth: Decodable {
        let data: AuthData
    }

    struct LoginData: Decodable {
        let status: Int
        let status_desc: String
        let auth: Auth
    }

    struct User: Decodable {
        let name: String
        let date_of_birth: Int
        let profile_image: String
    }

    struct MetaData: Decodable {
        let item_count: Int
        let total_pages: Int
        let current_page: Int
    }

    struct UserData: Decodable {
        let users: [User]
        let meta: MetaData
    }

    struct UserResponse: Decodable {
        let status: Int
        let status_desc: String
        let data: UserData
    }

    fileprivate func getUsers() {
        var request = URLRequest(url: URL(string: "https://grazer-test.herokuapp.com/v1/users")!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            if let data = data {
                let encoded = String(data: data, encoding: .utf8)!
                print("encoded:")
                print(encoded)
                let jsonData = encoded.data(using: .utf8)
                let userResponse: UserResponse = try! JSONDecoder().decode(UserResponse.self, from: jsonData!)
                self.users = userResponse.data.users
                print("users:")
                print(self.users)
            } else if let error = error {
                print("HTTP Request Failed \(error)")
            }
        })

        task.resume()
    }

    fileprivate func logIn() {
        let params = ["email": "asd@asd.es",
                      "password": "1234"] as Dictionary<String, String>

        var request = URLRequest(url: URL(string: "https://grazer-test.herokuapp.com/v1/auth/login")!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            if let data = data {
                let encoded = String(data: data, encoding: .utf8)!
                print(encoded)
                let jsonData = encoded.data(using: .utf8)
                let loginData: LoginData = try! JSONDecoder().decode(LoginData.self, from: jsonData!)
                self.token = loginData.auth.data.token
                print("token:")
                print(self.token)
                self.getUsers()
            } else if let error = error {
                print("HTTP Request Failed \(error)")
            }
        })

        task.resume()

    }

    @IBAction func loginButtonPressed(_ sender: UIButton) {
        logIn()
        isLoggedIn.toggle()
        updateUI()
    }
}

