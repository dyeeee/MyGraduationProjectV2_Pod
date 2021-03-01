//
//  MyGraduationProjectV2App.swift
//  MyGraduationProjectV2
//
//  Created by YES on 2021/2/1.
//

import SwiftUI
import LeanCloud

@main
struct MyGraduationProjectV2App: App {
    let persistenceController = PersistenceController.shared
    @AppStorage("UD_isFirstLaunch") var UD_isFirstLaunch = true

    init() {
        //云服务初始化
        LeanCloudInit()
        
        //设置全局bar颜色
        //UINavigationBar.appearance().barTintColor = UIColor.orange
        
        if UD_isFirstLaunch {
            // do sth
            UD_isFirstLaunch = false
        }
        
        //设置今天是学习的第几天
        setLearnDay()
    }
    
    var body: some Scene {
        WindowGroup {
            HomeTabView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                
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
