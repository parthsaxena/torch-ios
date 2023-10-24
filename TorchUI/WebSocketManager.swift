//
//  DataManager.swift
//  Torch
//
//  Created by Parth Saxena on 6/13/23.
//

import Foundation
import Starscream

struct SocketRequest {
    var route: String
    var data: [String: Any]
    var completion: (([String: Any]) -> ())?
}

class WebSocketManager {
    static let shared = WebSocketManager()
        
    private var socket: WebSocket?
    private var isConnected: Bool = false
    var jsonData: Any?
    var sharableInfo: Any?
    
    private var requests: [String: SocketRequest] = [:]

    private let ID_LENGTH = 15
    private let SOCKET_URL = "wss://hdca468gyi.execute-api.us-west-2.amazonaws.com/dev/"
    
    private init() {
        self.connect()
    }
    
    func generateRequestID() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0 ..< ID_LENGTH).map{ _ in letters.randomElement()! })
    }

    func connect() {
        var request = URLRequest(url: URL(string: SOCKET_URL)!)
        request.timeoutInterval = 5 // sets the timeout for the connection
        socket = WebSocket(request: request)
        socket?.delegate = self
        socket?.connect()
    }

    func sendData(socketRequest: SocketRequest) {
        let requestID = generateRequestID()
        requests[requestID] = socketRequest
        
        if (!isConnected) {
            // print("[WebSocketManager] Tried to send data but disconnected")
            return
        }
        
        let route = socketRequest.route
        let data = socketRequest.data
                
        var json: [String: Any] = ["action": route]
        data.forEach { key, value in
            json[key] = value
            json["request_id"] = requestID
        }
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []), let jsonString = String(data: jsonData, encoding: .utf8) else { return }
        // print("[WebSocketManager] Sending JSON: \(jsonString)")
        socket?.write(string: jsonString)
    }
    
}


extension WebSocketManager: WebSocketDelegate {
    private func handleError(_ error: Error?) {
        // handle the error, for example by logging it or showing an alert to the user
        // print("[WebSocketManager] WebSocket error: \(error?.localizedDescription ?? "unknown")")
        self.connect()
    }
    
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
            
        case .connected(let headers):
            isConnected = true
            // print("[WebSocketManager] websocket is connected: \(headers)")
            
            // print("[WebSocketManager] Reconnected, requests looks like: \(self.requests)")
            
            for (id, request) in requests {
                self.requests.removeValue(forKey: id)
                sendData(socketRequest: request)
            }                        
            
        case .disconnected(let reason, let code):
            isConnected = false
            // print("[WebSocketManager] websocket is disconnected: \(reason) with code: \(code)")
            // print("[WebSocketManager] Attempting to reconnect...")
            self.connect()
            
        case .text(let string):
//            // print("[WebSocketManager] Received text: \(string)")
            let data = string.data(using: .utf8)!
            
            if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) {
                let jsonDict = jsonObject as! [String: Any]
                
                guard let requestID = jsonDict["request_id"] as? String else {
                    return
                }
                
//                // print("[WebSocketManager] Received text for id: \(requestID), requests looks like: \(self.requests)")

                if self.requests.keys.contains(requestID) {
                    guard let completion = self.requests[requestID]?.completion! else {
                        return
                    }
                    
                    self.requests.removeValue(forKey: requestID)
                    
//                    // print("[WebSocketManager] Fulfilled request with id: \(requestID), requests looks like: \(self.requests)")
                    
                    completion(jsonDict)
                }
            }
        case .binary(let data):
             print("[WebSocketManager] Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            isConnected = false
        case .error(let error):
            isConnected = false
            handleError(error)
        }
    }
}

