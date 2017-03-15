//
//  AppDelegate.swift
//  Spotify-Swift
//
//  Created by Matthew S. Hill on 3/14/17.
//  Copyright © 2017 Matthew S. Hill. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, SPTAudioStreamingDelegate {

    var window: UIWindow?
    
    let kClientID = "519bb2b3799a4067adc66e618385681f"
    let kCallbackURL = "spotify-login://callback"
    let kTokenSwapURL = "http://localhost:1234/swap"
    let kTokenRefreshURL = "http://localhost:1234/refresh"
    
    var player: SPTAudioStreamingController?
    let spotifyAuthenticator = SPTAuth.defaultInstance()
    var session : SPTSession?
  

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        SPTAuth.defaultInstance().clientID = kClientID
        SPTAuth.defaultInstance().redirectURL = NSURL(string: kCallbackURL) as URL!
        SPTAuth.defaultInstance().requestedScopes = [SPTAuthStreamingScope as AnyObject] as [AnyObject]
        let loginUrl = SPTAuth.loginURL(forClientId: kClientID, withRedirectURL: NSURL(string: kCallbackURL) as URL!, scopes: nil, responseType: nil)
        application.openURL(loginUrl!)
        
        return true
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        if SPTAuth.defaultInstance().canHandle(url as URL!) {
            SPTAuth.defaultInstance().handleAuthCallback(withTriggeredAuthURL: url as URL!, callback: { error, session in
                if error != nil {
                    print("*** Auth error: \(error)")
                }
                // Call the -loginUsingSession: method to login SDK
                self.loginUsingSession(session: session!)
            })
            return true
        }
        
        return false
    }
    
    func loginUsingSession(session: SPTSession) {
        // Get the player Instance
        player = SPTAudioStreamingController.sharedInstance()
        if let player = player {
            player.delegate = self
            // start the player (will start a thread)
            try! player.start(withClientId: kClientID)
            // Login SDK before we can start playback
            player.login(withAccessToken: session.accessToken)
        }
    }
    
    // MARK: SPTAudioStreamingDelegate.
    
    func audioStreamingDidLogin(audioStreaming: SPTAudioStreamingController!) {
        let urlStr = "spotify:track:6ZSvhLZRJredt15aJiBQqv" // track available in Japan
        player!.playSpotifyURI(urlStr, startingWith: 0, startingWithPosition: 0, callback: { error in
            if error != nil {
                print("*** failed to play: \(error)")
                return
            } else {
                print("play")
            }
        })
    }
}
