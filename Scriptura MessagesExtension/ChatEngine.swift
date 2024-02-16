//
//  ChatEngine.swift
//  Scriptura
//
//  Created by Xcode Developer on 1/28/24.
//

import Foundation
import CryptoKit
import Combine
import UIKit

class ChatEngine : NSObject {
    var assistant_id: String = String()
    var thread_id: String = String()
    var run_id: String = String()
    var text_view: UITextView = UITextView()
    
    func assistant(text_view: UITextView) {
        self.text_view = text_view
        self.assistant_id = String()
        
        let url = URL(string: "https://api.openai.com/v1/assistants")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer ", forHTTPHeaderField: "Authorization")
        request.addValue("org-30HBRKuB7MPad1UstimL6G8o", forHTTPHeaderField: "OpenAI-Organization")
        request.addValue("assistants=v1", forHTTPHeaderField: "OpenAI-Beta")
        
        let type: [Dictionary] = [["type": "code_interpreter"]]
        let assistant_request: Dictionary =
        [
            "instructions": self.text_view.text!,
            "name": "Message Writing Assistant",
            "tools": type,
            "model": "gpt-4"
        ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: assistant_request, options: [])
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil && data != nil {
                DispatchQueue.main.async {
                    do {
                        if let assistant_response = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                            self.assistant_id = {
                                return assistant_response["id"] as? String
                            }() ?? {
                                let assistant_id_err = ((assistant_response)["error"] as? [String: Any])!.description
                                defer {
                                    print("Assistant ID (error) " + assistant_id_err)
                                    self.assistant(text_view: self.text_view)
                                }
                                return assistant_id_err
                            }()
                            print("Assistant ID " + self.assistant_id)
                        }
                    } catch {
                        print("Assistant ID (exception) " + error.localizedDescription)
                    }
                }
            }
        }
        task.resume()
    }
    

    func thread() {
        let url = URL(string: "https://api.openai.com/v1/threads")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer ", forHTTPHeaderField: "Authorization")
        request.addValue("org-30HBRKuB7MPad1UstimL6G8o", forHTTPHeaderField: "OpenAI-Organization")
        request.addValue("assistants=v1", forHTTPHeaderField: "OpenAI-Beta")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil && data != nil {
                DispatchQueue.main.async {
                    do {
                        if let thread_response = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                            self.thread_id = {
                                return thread_response["id"] as? String
                            }() ?? {
                                defer {
                                    print("Thread ID (error) " + error!.localizedDescription)
                                    self.thread()
                                }
                                return error!.localizedDescription
                            }()
                            print("Thread ID " + self.thread_id)
                        }
                    } catch {
                        print("Thread ID (exception) " + error.localizedDescription)
                    }
                }
            }
        }
        task.resume()
    }
    
    func addMessage(message: String) -> () {
        let message_dict: Dictionary = ["role": "user", "content": message] as [String : Any]
        let url = URL(string: "https://api.openai.com/v1/threads/" + self.thread_id + "/messages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let jsonData = try! JSONSerialization.data(withJSONObject: message_dict, options: [])
        request.httpBody = jsonData
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer ", forHTTPHeaderField: "Authorization")
        request.addValue("org-30HBRKuB7MPad1UstimL6G8o", forHTTPHeaderField: "OpenAI-Organization")
        request.addValue("assistants=v1", forHTTPHeaderField: "OpenAI-Beta")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil && data != nil {
                DispatchQueue.main.async {
                    do {
                        if let message_response: [String: Any] = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                            if let contentArray = message_response["content"] as? [[String: Any]] {
                                if let textArray = (contentArray.first)!["text"] as? [String: Any] {
                                    if let value = textArray["value"] as? String {
                                        let prompt = {
                                            defer { self.run() }
                                            return value.trimmingCharacters(in: .whitespacesAndNewlines)
                                        }() ?? {
                                            let err = (message_response)["error"] as? [String: Any]
                                            let err_msg = err!["message"] as? String
                                            return err_msg!
                                        }()
                                        print("Prompt " + prompt)
                                    }
                                }
                            }
                        }
                    } catch {
                        // Display error
                        print(error.localizedDescription)
                    }
                }
            }
        }
        task.resume()
    }
    
    func run() -> () {
        let run_request: Dictionary = ["assistant_id": self.assistant_id] as [String : Any]
        
        let url = URL(string: "https://api.openai.com/v1/threads/" + self.thread_id + "/runs")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer ", forHTTPHeaderField: "Authorization")
        request.addValue("org-30HBRKuB7MPad1UstimL6G8o", forHTTPHeaderField: "OpenAI-Organization")
        request.addValue("assistants=v1", forHTTPHeaderField: "OpenAI-Beta")
        
        let jsonData = try! JSONSerialization.data(withJSONObject: run_request, options: [])
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil && data != nil {
                DispatchQueue.main.async {
                    do {
                        if let run_response = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                            self.run_id = {
                                {
                                    defer {
                                        self.retrieve()
                                    }
                                    return run_response["id"] as? String
                                }() ?? {
                                    let run_response_err = (run_response["last_error"] as? String)!.description
                                    print("Run ID (error) " + run_response_err)
                                    defer {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                                            self.run()
                                        })
                                    }
                                    return run_response_err
                                }()
                            }()
                            print("Run ID " + self.run_id)
                        }
                    } catch {
                        // Display error
                        print(error.localizedDescription)
                    }
                }
            }
        }
        task.resume()
    }
    
    func retrieve() {
        let url = URL(string: "https://api.openai.com/v1/threads/" + self.thread_id + "/runs/" + self.run_id)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer ", forHTTPHeaderField: "Authorization")
        request.addValue("org-30HBRKuB7MPad1UstimL6G8o", forHTTPHeaderField: "OpenAI-Organization")
        request.addValue("assistants=v1", forHTTPHeaderField: "OpenAI-Beta")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            if error == nil && data != nil {
                DispatchQueue.main.async {
                    do {
                        if let retrieve_response = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                            print("\n\(retrieve_response)\n")
                            if (retrieve_response["status"] as? String) != "completed" {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                                    self.retrieve()
                                })
                            } else {
                                self.list()
                            }
                        }
                    } catch {
                        print("Error")
                    }
                }
            }
        }
        task.resume()
    }
    

    
    func list() {
        var list: String = String()
        let url = URL(string: "https://api.openai.com/v1/threads/" + self.thread_id + "/messages")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer ", forHTTPHeaderField: "Authorization")
        request.addValue("org-30HBRKuB7MPad1UstimL6G8o", forHTTPHeaderField: "OpenAI-Organization")
        request.addValue("assistants=v1", forHTTPHeaderField: "OpenAI-Beta")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil && data != nil {
                DispatchQueue.main.async {
                    do {
                        if let list_response: [String: Any] = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                            if let dataArray = list_response["data"] as? [[String: Any]] {
                                if let contentArray = (dataArray.first)!["content"] as? [[String: Any]] {
                                    if let textArray = (contentArray.first)!["text"] as? [String: Any] {
                                        list = textArray["value"] as! String
                                        self.text_view.text = list
//                                        print("------------------\nList " + list + "------------------\n")
                                    }
                                }
                            }
                        }
                    } catch {
                        // Display error
                        print(error.localizedDescription)
                    }
                }
            }
        }
        task.resume()
    }
}
