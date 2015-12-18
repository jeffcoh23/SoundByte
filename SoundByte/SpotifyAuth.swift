////
////  SpotifyAuth.swift
////  SoundByte
////
////  Created by Jeff Cohen on 12/18/15.
////  Copyright (c) 2015 Jeff Cohen. All rights reserved.
////
//
//import Foundation
////import KeychainAccess
////import Keys
//import Spotify
//
//private let kClientID = "cf5b0855e8f440719ad3a1811e704fe3"
//private let kCallbackURL = "soundbyte://return-after-login"
////let kTokenSwapURL = "http://localhost:1234/swap"
////let kTokenRefreshURL = "http://localhost:1234/refresh"
//
//
//public class SpotifyAuth {
//    private var auth: SPTAuth {
//        let auth = SPTAuth.defaultInstance()
//        auth.clientID = kClientId
//        auth.redirectURL = NSURL(string: kCallbackURL)
//        auth.requestedScopes = [SPTAuthUserReadPrivateScope, SPTAuthUserLibraryReadScope, SPTAuthStreamingScope]
//        auth.tokenRefreshURL = NSURL(string: kTokenRefreshURL)
//        auth.tokenSwapURL = NSURL(string: kTokenSwapURL)
//        return auth
//    }
//    private let keychain = Keychain(service: kClientId)
//    
//    public var clientID: String { return auth.clientID }
//    public var log: (String) -> Void = { (_) in return }
//    public var session: SPTSession!
//    public var startPlayback: () -> Void = { }
//    
//    public func start() {
//        if let data = keychain.getData(kSessionUserDefaultsKey), session = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? SPTSession {
//            auth.session = session
//            
//            if session.isValid() {
//                self.session = session
//                startPlayback()
//            } else {
//                auth.sessionUserDefaultsKey = "spotifySession"
//                auth.renewSession(session) { (error, session) in
//                    if let error = error {
//                        self.log(String(format: "Token refresh error: %@", error))
//                        return
//                    }
//                    
//                    if let session = session {
//                        self.session = session
//                        self.startPlayback()
//                    }
//                }
//            }
//        } else {
//            var loginURL = auth.loginURL
//            
//            var delayInSeconds = 0.1
//            var popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
//            dispatch_after(popTime, dispatch_get_main_queue(), {
//                UIApplication.sharedApplication().openURL(loginURL)
//                return
//            })
//        }
//}