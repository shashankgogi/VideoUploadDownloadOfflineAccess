//
//  AppDelegate.swift
//  iOSVideoPlug
//
//  Created by Rahul Panzade on 29/03/19.
//  Copyright © 2019 Omni-Bridge. All rights reserved.
//

import UIKit
import AVKit
import IQKeyboardManagerSwift
import CoreData
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        ConnectionManager.sharedInstance.observeReachability()
        if UserDefaults.standard.value(forKey: "StartURLFromServer") == nil{
            self.callToSetConfigeUrl()
        }else{
            self.loadInitialViewController()
        }
        IQKeyboardManager.shared.enable = true
        turnOnSoundModeWhenInSilenceMode()
        return true
    }
    
    func turnOnSoundModeWhenInSilenceMode(){
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        }catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        Generals.pausedlAllDownloading()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        saveContext()
    }
    
    
    // MARK:- Core Data
    
    lazy var persistentContainer : NSPersistentContainer  = {
        let container = NSPersistentContainer(name: "OfflineModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // Core Data Saving support
    func saveContext(){
        let context = persistentContainer.viewContext
        if context.hasChanges{
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK:- Confige URL
    
    /// Uset to set confige url from server
    private func callToSetConfigeUrl(){
        if Generals.isConnectedToNetwork(){
            if GetApiConfig.execute(){
                self.loadInitialViewController()
            } else {
                if (UserDefaults.standard.value(forKey: "StartURLFromServer") as! NSString?) == nil{
                    showErrorAlert(message: SOMETHING_WENT_WRONG_MSG)
                }else{
                    self.loadInitialViewController()
                }
            }
        }else{
            if (UserDefaults.standard.value(forKey: "StartURLFromServer") as! NSString?) == nil{
                self.showErrorAlert(message: NOINTERNET_MESSAGE)
            }else{
                self.loadInitialViewController()
            }
        }
    }
    
    /// Used to load initial view controller
    private func loadInitialViewController(){
        let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController : UINavigationController = mainStoryboard.instantiateViewController(withIdentifier: "HomeNavigationController") as! UINavigationController
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
    }
    
    /// Used to show Error alert
    func showErrorAlert(message : String){
        let alertVC = UIAlertController(title: "Oops" , message: message, preferredStyle: UIAlertController.Style.alert)
        let tryAgain = UIAlertAction(title: "Try again", style: .default) { (_) -> Void in
            self.callToSetConfigeUrl()
        }
        
        alertVC.addAction(tryAgain)
        DispatchQueue.main.async {
            let alertWindow = UIWindow(frame: UIScreen.main.bounds)
            alertWindow.rootViewController = UIViewController()
            alertWindow.windowLevel = UIWindow.Level.alert + 1;
            alertWindow.makeKeyAndVisible()
            alertWindow.rootViewController?.present(alertVC, animated: true, completion: nil)
        }
    }
    
}

