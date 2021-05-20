//
//  MyGraduationProjectV2App.swift
//  MyGraduationProjectV2
//
//  Created by YES on 2021/2/1.
//

import SwiftUI
import LeanCloud
import UIKit
import NotificationCenter

@main
struct MyGraduationProjectV2App: App {
    let persistenceController = PersistenceController.shared
    @AppStorage("UD_isFirstLaunch") var UD_isFirstLaunch = true
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        //云服务初始化
        LeanCloudInit()
        
        //设置全局bar颜色
        //UINavigationBar.appearance().barTintColor = UIColor.orange
        
        print(FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask))
        

        
        if UD_isFirstLaunch {
            // do sth
            // 获取通知权限
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (status, err) in
                if !status {
                        print("用户不同意授权通知权限")
                    return
                }
            }
            
            UD_isFirstLaunch = false
        }
        
        //设置今天是学习的第几天
        setLearnDay()
    }
    
    var body: some Scene {
        WindowGroup {
            HomeTabView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onReceive(NotificationCenter.default.publisher(for: UIScene.willConnectNotification)) { _ in
                  #if targetEnvironment(macCatalyst)
                  // prevent window in macOS from being resized down
                    UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.forEach { windowScene in
                      windowScene.sizeRestrictions?.minimumSize = CGSize(width: 1900, height: 1200)
                      //windowScene.sizeRestrictions?.maximumSize = CGSize(width: 1900, height: 1200)
                    }
                  #endif
                }
                
        }
    }
}


//初始化设置
private func LeanCloudInit() {
    //LCApplication.logLevel = .verbose
    do {
        try LCApplication.default.set(
            id: "V1ziOjNE0mJl5mPWlvQfGgBa-gzGzoHsz",
            key: "ymujb5rlN0LjKSIysqAf63LE",
            serverURL: "https://v1ziojne.lc-cn-n1-shared.com")
    } catch {
        print(error)
    }
}

func LeanCloudTest() {
    do {
        let testObject = LCObject(className: "TestObject")
        try testObject.set("words", value: "Hello world!")
        let result = testObject.save()
        if let error = result.error {
            print(error)
        }
    } catch {
        print(error)
    }
}


class AppDelegate:NSObject,UIApplicationDelegate{
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
//        if Device.deviceType == .Mac {
//            print("Mac运行中")
//                UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.forEach { windowScene in
//                    windowScene.sizeRestrictions?.minimumSize = CGSize(width: 800, height: 1100)
//                    windowScene.sizeRestrictions?.maximumSize = CGSize(width: 800, height: 1100)
//                }
//        }
        
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        //iPad支持旋转，别的设备不支持旋转使用
        return Device.deviceType == .iPad
              ? UIInterfaceOrientationMask.all
              : UIInterfaceOrientationMask.portrait
      }
}
