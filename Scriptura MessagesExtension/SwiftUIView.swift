//
//  SwiftUIView.swift
//  Scriptura MessagesExtension
//
//  Created by Xcode Developer on 2/8/24.
//

import SwiftUI
import CryptoKit
import SwiftData
import Messages

@MainActor class ChatData : ObservableObject {
    @Published var assistant_id: String                = String()
    @Published var thread_id: String                   = String()
    @Published var run_id: String                      = String()
    @Published var messages: [Message]                 = [Message]()
    
    var promptCount: Int = Int()
    
    struct Message: Identifiable, Equatable, Hashable, Codable {
        let id: String
        var prompt: String
        var response: String
        
        init(prompt: String, response: String) {
            self.id = {
                let hash = SHA256.hash(data: String(Date().timeIntervalSince1970).data(using: .utf8)!).compactMap { String(format: "%02x", $0) }.joined()
                return hash
            }()
            self.prompt = prompt
            self.response = response
        }
    }
    
    func assistant() {
        self.messages.removeAll()
        
        self.messages.append(Message.init(prompt: "prompt", response: "response"))
        
        
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
            "instructions": "Act as an assistant to a participant in a text-messaging conversation. You will be provided with statements either in English or Spanish (or a mix thereof) that the user intends to send via a text message. Your task is to convert or translate the statements provided by the user to standard English only. You will then propose or suggest up to 3 variations of the user's statements in both English and Spanish. Each statement variation should be proceeded by a bullet, followed by the English version and, on a new line, indent the Spanish version (but do not use a dash or a bullet — just white space).",
            "name": "Bilingual Contextual Enhancement and Inquiry Generator (BCEIG).",
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
                                defer { self.thread() }
                                return assistant_response["id"] as? String
                            }() ?? {
                                let err = ((assistant_response)["error"] as? [String: Any])!["message"] as? String
                                self.messages.append(Message.init(prompt: "Error getting assistant", response: err!))
                                return err!
                            }()
                        }
                    } catch {
                        self.messages.append(Message.init(prompt: "Error getting assistant", response: error.localizedDescription))
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
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            if error == nil && data != nil {
                DispatchQueue.main.async {
                    do {
                        if let thread_response = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                            self.thread_id = {
                                return thread_response["id"] as? String
                            }() ?? {
                                let err = (thread_response)["error"] as? [String: Any]
                                let err_msg = err!["message"] as? String
                                self.messages.append(Message.init(prompt: "Error getting thread", response: err_msg!))
                                return err_msg!
                            }()
                            self.messages.append(Message.init(prompt: self.assistant_id.trimmingCharacters(in: .whitespacesAndNewlines), response: self.thread_id.trimmingCharacters(in: .whitespacesAndNewlines)))
//                            self.loadChatData(remoteParticipantIdentifiers: ["asdf"])
                        }
                    } catch {
                        self.messages.append(Message.init(prompt: "Error getting thread", response: error.localizedDescription))
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
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            if error == nil && data != nil {
                DispatchQueue.main.async {
                    do {
                        if let message_response: [String: Any] = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                            print(message_response)
                            if let contentArray = message_response["content"] as? [[String: Any]] {
                                print(contentArray)
                                if let textArray = (contentArray.first)!["text"] as? [String: Any] {
                                    print(textArray)
                                    if let value = textArray["value"] as? String {
                                        print(value)
                                        let prompt = {
                                            defer { self.run() }
                                            //                                        self.messages.append(Message(id: sha256(), prompt: value, response: ""))
                                            return value.trimmingCharacters(in: .whitespacesAndNewlines)
                                        }() ?? {
                                            let err = (message_response)["error"] as? [String: Any]
                                            let err_msg = err!["message"] as? String
                                            //                                        self.messages.append(Message(id: sha256(), prompt: "Error adding message", response: err_msg!))
                                            return err_msg!
                                        }()
                                        self.messages.append(Message.init(prompt: prompt, response: String()))
                                    }
                                }
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
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            if error == nil && data != nil {
                DispatchQueue.main.async {
                    do {
                        if let run_response = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                            let id = run_response["id"] as? String
                            self.run_id = id ?? "No run ID"
                            self.retrieve()
                        }
                    } catch {
                        print("Error")
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
                            if (retrieve_response["status"] as? String) != "completed" {
                                self.messages[self.messages.count - 1].response = (retrieve_response["status"] as? String)!
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                                    self.messages[self.messages.count - 1].response = " "
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
        if (self.promptCount > 2) {
            self.promptCount = 0
        }
        let url = URL(string: "https://api.openai.com/v1/threads/" + self.thread_id + "/messages")!
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
                        if let list_response: [String: Any] = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                            if let dataArray = list_response["data"] as? [[String: Any]] {
                                if let contentArray = (dataArray.first)!["content"] as? [[String: Any]] {
                                    if let textArray = (contentArray.first)!["text"] as? [String: Any] {
                                        let value = textArray["value"] as! String
                                        self.messages[self.messages.count - 1].response = value
//                                        self.saveChatData(remoteParticipantIdentifiers: ["asdf"])
                                        //                                        DispatchQueue.concurrentPerform(iterations: 3) { i in
                                        //                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                                        //                                                self.addMessage(message: "Can you suggest an alternative?")
                                        //                                            })
                                        //                                        }
                                    }
                                }
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
    
    func save() {
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(self.messages)
            let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("messages.json")
            do {
                try jsonData.write(to: fileURL)
                print("File written to \(fileURL)")
            } catch {
                print("Error writing file: \(error)")
            }
            
        } catch {
            print("Error encoding messages: \(error)")
            return
        }
    }
    
    func load() {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("messages.json")
        
        let jsonData: Data
        do {
            jsonData = try Data(contentsOf: fileURL)
        } catch {
            print("Error reading file: \(error)")
            return
        }
        
        let decoder = JSONDecoder()
        do {
            messages = try decoder.decode([Message].self, from: jsonData)
        } catch {
            print("Error decoding items: \(error)")
            return
        }
        
        print(messages)
    }
    
    func saveChatData(remoteParticipantIdentifiers: [String]) {
        print("saveChatData")
        guard !remoteParticipantIdentifiers.isEmpty else {
            print("Remote Participant Identifiers array is empty.")
            return
        }
        
        let fileName = remoteParticipantIdentifiers.first! // Assuming the array is not empty.
        let chatInfo = [
            "thread_id": self.thread_id,
            "assistant_id": self.assistant_id,
            "messages": messages.map { ["id": $0.id, "prompt": $0.prompt, "response": $0.response] }
        ] as [String : Any]
        
        do {
            let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(fileName).json")
            let jsonData = try JSONSerialization.data(withJSONObject: chatInfo, options: .prettyPrinted)
            try jsonData.write(to: fileURL, options: .atomic)
            print("Chat data saved successfully to \(fileName).json")
        } catch {
            print("Error saving chat data: \(error)")
        }
    }
    
    func loadChatData(remoteParticipantIdentifiers: [String]) {
        print("loadChatData")
        
        guard !remoteParticipantIdentifiers.isEmpty else {
            print("Remote Participant Identifiers array is empty.")
            return
        }
        
        let fileName = remoteParticipantIdentifiers.first! // Assuming the array is not empty.
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(fileName).json")
        
        do {
            let jsonData = try Data(contentsOf: fileURL)
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
            
            guard let dictionary = jsonObject as? [String: Any],
                  let loadedThreadId = dictionary["thread_id"] as? String,
                  let loadedAssistantId = dictionary["assistant_id"] as? String,
                  let loadedMessages = dictionary["messages"] as? [[String: String]] else {
                print("Error: JSON structure doesn't match expected format")
                return
            }
            
            // Set the properties
            self.thread_id = loadedThreadId
            self.assistant_id = loadedAssistantId
            self.messages = loadedMessages.compactMap { dict in
                guard let id = dict["id"], let prompt = dict["prompt"], let response = dict["response"] else {
                    return Message(prompt: "nil", response: "nil")
                }
                return Message(prompt: prompt, response: response)
            }
            
            print("Chat data loaded successfully from \(fileName).json")
        } catch {
            print("Error loading chat data: \(error)")
        }
    }
    
    
}

struct SwiftUIView: View {
    @Environment(\.msConversation) var conversation: MSConversation?
    @StateObject var chatData: ChatData = ChatData()
    
    var body: some View {
        VStack(alignment: .center, spacing: 0.0, content: {
            ChatView(chatData: chatData)
                .task {
                    if chatData.assistant_id.isEmpty {
                        chatData.assistant()
                    }
                    let conversation = self.conversation!
                    let localID = conversation.localParticipantIdentifier.uuidString
                    
                    chatData.loadChatData(remoteParticipantIdentifiers: [String(localID)])
                    print("\n\n\(localID)\n\n")
                }
            
            MessageView(chatData: chatData)
                .background {
                    Capsule()
                        .strokeBorder(Color.init(uiColor: .gray).opacity(0.25), lineWidth: 1.0)
                        .fill(Color.init(uiColor: .gray).opacity(0.25))
                }
                .clipShape(Capsule())
                .safeAreaPadding(.bottom)
                .safeAreaPadding(.top)
                .shadow(color: .black, radius: 5.0)
            
        })
        .background {
            LinearGradient(gradient: .init(colors: [Color(hue: 0.5861111111, saturation: 0.55, brightness: 0.58), Color(hue: 0.5916666667, saturation: 1.0, brightness: 0.27)]), startPoint: .trailing, endPoint: .bottomLeading)
        }
    }
}
