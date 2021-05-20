//
//  LoginViewModel.swift
//  Login_Face_ID
//
//  Created by Balaji on 07/10/20.
//

import SwiftUI
import LocalAuthentication
import LeanCloud
import Foundation

//存放用户的设置信息
struct UserInfo:Codable{
    var username: String
    
    var userSession: String
    
    var learningBook: String
    
    //背了多少单词，同步这个的时候单词书也要同步一次
    var wordStatusList:[Int16]
    
    //近七日的学习进度
    var learnStats_7days:[Double]
    
}


class UserViewModel : ObservableObject{
    @Published var userEmail = ""
    @Published var userPassword = ""
    
    @Published var userPhoneNum = ""
    @Published var username = ""
    
    
    // UserDefault数据
    @AppStorage("UD_username") var UD_username = ""
    @AppStorage("UD_userPassword") var UD_userPassword = ""
    @AppStorage("UD_userSession") var UD_userSession = ""
    @AppStorage("UD_isUsingBioID") var UD_isUsingBioID = false
    @AppStorage("UD_learningBook") var UD_learningBook = ""
    @AppStorage("UD_searchHistoryCount") var UD_searchHistoryCount = 0
    @AppStorage("UD_isLastLearnDone") var UD_isLastLearnDone = false
    @AppStorage("UD_learnDayCount") var UD_learnDayCount = 0

    @AppStorage("UD_Cloud_learningBook") var UD_Cloud_learningBook = ""
    
    @AppStorage("UD_noteWordNum") var UD_noteWordNum = 0
    @AppStorage("UD_todoNum") var UD_todoNum = 0
    
    @AppStorage("UD_allWordNum") var UD_allWordNum = 0 //单词总量，存在UD里
    @AppStorage("UD_unlearnedWordNum") var UD_unlearnedWordNum = 0 //未学习的总量，存在UD里
    @AppStorage("UD_learningWordNum") var UD_learningWordNum = 0 //学习中的总量，存在UD里
    @AppStorage("UD_knownWordNum") var UD_knownWordNum = 0 //已掌握的总量，存在UD里
    
    //本地校验
    @AppStorage("UD_isLogged") var UD_isLogged = false
    @AppStorage("UD_newData") var UD_newData = false
    
    //云端校验
    @Published var isLocalSessionVertified:Bool = false
    
    @Published var Cloud_learningBook = ""
    @Published var Cloud_allWordNum = 0
    @Published var Cloud_unlearnedWordNum = 0
    @Published var Cloud_learningWordNum = 0
    @Published var Cloud_knownWordNum = 0
    
    @Published var Cloud_noteBookNum = 0
    @Published var Cloud_todoNum = 0
    @Published var Cloud_searchHistoryCount = 0
    
    
    // Loading Screen...
    @Published var isLoading = false
    
    //用户提示
    @Published var signUpAlert = false
    @Published var signUpAlertMsg = ""
    
    @Published var logInAlert = false
    @Published var logInAlertMsg = ""
    
    @Published var bioUsingAlert = false
    
    // 判断设备是否有Bio识别
    func getBioMetricStatus()->Bool{
        let bioContext = LAContext()
        var error:NSError?
        let result = bioContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        return result
    }
    
    //生物识别
    func authenticateUser(){
        let context = LAContext()
        context.localizedFallbackTitle = "其它方式"
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "使用生物识别解锁\(userEmail)") { (success, err) in
            if success {
                DispatchQueue.main.async {
                    //表示验证成功
                    self.userEmail = self.UD_username
                    self.userPassword = self.UD_userPassword  //验证通过就用存在本地的密码去登录
                    self.userLogIn()
                }
            }
            if err != nil{
                print(err!.localizedDescription)
                return
            }
            
        }
    }
    
    //用户注册
    func userSignUp() {
        isLoading = true
        
        // 创建实例
        let user = LCUser()
        
        // 等同于 user.set("username", value: "Tom")
        user.username = LCString("\(self.userEmail)")
        user.password = LCString("\(self.userPassword)")
        
        // 可选
        user.email = LCString("\(self.userEmail)")
        //user.mobilePhoneNumber = LCString("+8618200008888")
        
        _ = user.signUp { [self] (result) in
            self.isLoading = false
            switch result {
            case .success:
                self.UD_isLogged = true
                self.userLogIn()
                break
            case .failure(error: let error):
                switch error.code {
                case 203:
                    self.signUpAlertMsg = "此电子邮箱已被注册\n请前往登录或使用未被注册的邮箱"
                default:
                    self.signUpAlertMsg = error.localizedDescription
                }
                self.signUpAlert.toggle()
                print(error)
                print(self.signUpAlert)
                return
            }
        }
    }
    
    // 用户登录
    func userLogIn(){
        //开启动画
        isLoading = true
        
        _ = LCUser.logIn(email: userEmail, password: userPassword) { [self] result in
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2){
                self.isLoading = false //关闭动画
            }
            switch result {
            case .success(object: let user):
                self.UD_userSession = LCApplication.default.currentUser?.sessionToken?.value ?? "noSession"
                self.UD_username = self.userEmail
                self.UD_userPassword = self.userPassword
                
                print("\(user)登录成功")
                
                //如果没有开启生物识别则询问是否要启用
                if !self.UD_isUsingBioID{
                    self.bioUsingAlert = true
                    //这里注意要在alert中处理登录逻辑
                    return
                }else{
                //进入主页面
                withAnimation{
                    print("准备进入主页面")
                    self.UD_isLogged = true
                    print("本地验证结果: \(self.UD_isLogged)")
                    self.vertifyLocalSession()
                }
                }
                
 
            case .failure(error: let error):
                print(error)
                switch error.code {
                case 210:
                    self.logInAlertMsg = "用户名或密码错误"
                default:
                    self.logInAlertMsg = error.localizedDescription
                }
                self.logInAlert.toggle()
                return
            }
        }
    }
    
    func userLogOut() {
        LCUser.logOut()
//        UD_storedUser = ""
//        UD_storedPassword = ""
        UD_userSession = ""
        userPassword = ""
        //添加一个询问要不要清除faceID记录
        if UD_isUsingBioID != true{
            UD_isUsingBioID = false
            print("已关闭生物识别")
        }
        
        withAnimation{
            UD_isLogged = false
        }
//        print("本地记录已被清除")
    }
    
    //    func setUserInfo() {
    //        _ = LCUser.logIn(email: "\(self.email)", password: "\(self.UD_storedPassword)") { result in
    //            switch result {
    //            case .success(object: let user):
    //                // 试图修改用户名
    //                try! user.set("username", value: "\(self.username)")
    //                // 可以执行，因为用户已鉴权
    //                user.save()
    //            case .failure(error: let error):
    //                print(error)
    //            }
    //        }
    //    }
    
//    func uploadUserInfo(learningBook:String,wordStatusList:[Int],noteBookNum:Int,todoNum:Int,searchHistoryCount:Int) {
    func uploadUserInfo() {
        if isLocalSessionVertified {
            let user = LCApplication.default.currentUser?.username?.stringValue ?? "Anonymous"
            let query = LCQuery(className: "UserInfo")
            query.whereKey("user", .equalTo("\(user)"))

            
            //查询得到的话则更新，一个用户保留一条数据
            if  query.count().intValue != 0 {
                print("尝试更新用户的Leancloud信息")
                _ = query.getFirst { [self] result in
                    switch result {
                    case .success(object: let userInfo):
                        print("已有该用户数据在云端")
                        //更新
                        do {
//                            let updateItem = LCObject(className: "UserInfo", objectId: "\(userInfo.objectId?.value ?? "0")")
                            
                            // 为属性赋值
                            try userInfo.set("learningBook", value: LCString(self.UD_learningBook))
                            //print(learningBook)
                            let wordStatusList = [UD_allWordNum,UD_knownWordNum,UD_learningWordNum,UD_unlearnedWordNum]
                            try userInfo.set("wordStatusList", value: LCArray(wordStatusList))
                            try userInfo.set("learnStats_7days", value: LCArray([0.5,1.8,1.9,2.6,3.0,3.6,3.7]))
                            try userInfo.set("isLastLearnDone", value: LCBool(self.UD_isLastLearnDone))
                            try userInfo.set("learnDayCount", value: LCNumber(integerLiteral: Int(self.UD_learnDayCount)))
                            
                            try userInfo.set("searchHistoryCount", value: LCNumber(integerLiteral: Int(self.UD_searchHistoryCount)) )
                            try userInfo.set("noteBookNum", value: LCNumber(integerLiteral: Int(self.UD_noteWordNum)) )
                            try userInfo.set("todoNum", value: LCNumber(integerLiteral: Int(self.UD_todoNum)) )
                            
                            // 数据更新标记
                            if Device.deviceType == .Mac{
                                try userInfo.set("newData", value: LCBool(true))
                                try userInfo.set("newData_iPad", value: LCBool(true))
                            }
                            if Device.deviceType == .iPad {
                                try userInfo.set("newData", value: LCBool(true))
                                try userInfo.set("newData_Mac", value: LCBool(true))
                            }
                            if Device.deviceType == .iPhone {
                                try userInfo.set("newData_iPad", value: LCBool(true))
                                try userInfo.set("newData_Mac", value: LCBool(true))
                            }
                            
                            
                            
                            
                            
                            userInfo.save() { (result) in
                                switch result {
                                case .success:
                                    break
                                case .failure(error: let error):
                                    print(error)
                                }
                            }

                        }
                        catch {
                            print(error)
                        }
                    case .failure(error: let error):
                        print("未有该用户的数据在云端: \(error)")
                    }
                }
            }
            
            else{
            do {
                // 构建对象
                let userInfo = LCObject(className: "UserInfo")

                // 为属性赋值
                try userInfo.set("user", value: LCString(user))
                try userInfo.set("learningBook", value: LCString(self.UD_learningBook))
                let wordStatusList = [UD_allWordNum,UD_knownWordNum,UD_learningWordNum,UD_unlearnedWordNum]
                try userInfo.set("wordStatusList", value: LCArray(wordStatusList))
                try userInfo.set("learnStats_7days", value: LCArray([0.5,1.8,1.9,2.6,3.0,3.6,3.7]))
                try userInfo.set("isLastLearnDone", value: LCBool(UD_isLastLearnDone))
                try userInfo.set("learnDayCount", value: LCNumber(integerLiteral: Int(self.UD_learnDayCount)))
                
                try userInfo.set("searchHistoryCount", value: LCNumber(integerLiteral: Int(self.UD_searchHistoryCount)) )
                try userInfo.set("noteBookNum", value: LCNumber(integerLiteral: Int(self.UD_noteWordNum)) )
                try userInfo.set("todoNum", value: LCNumber(integerLiteral: Int(self.UD_todoNum)) )
                
                // 数据更新标记
                try userInfo.set("newData", value: LCBool(true))
                try userInfo.set("newData_iPad", value: LCBool(true))
                try userInfo.set("newData_Mac", value: LCBool(true))
                
                // 将对象保存到云端
                _ = userInfo.save { result in
                    switch result {
                    case .success:
                        // 成功保存之后，执行其他逻辑
                        break
                    case .failure(error: let error):
                        // 异常处理
                        print(error)
                    }
                }
            } catch {
                print(error)
            }
            }
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3){ [self] in
                self.showCurrentUserInfo()}
        }

    }
    
    func uploadUserInfoCheck() {
        print("尝试更新数据标记位")
        if isLocalSessionVertified {
            print("尝试成功")
            let user = LCApplication.default.currentUser?.username?.stringValue ?? "Anonymous"
            let query = LCQuery(className: "UserInfo")
            query.whereKey("user", .equalTo("\(user)"))

            
            //查询得到的话则更新，一个用户保留一条数据
            if  query.count().intValue != 0 {
                print("尝试更新用户的Leancloud信息")
                _ = query.getFirst { result in
                    switch result {
                    case .success(object: let userInfo):
                        print("已有该用户数据在云端")
                        //更新
                        do {
                            // 数据更新标记
                            try userInfo.set("newData", value: LCBool(true))
                            try userInfo.set("newData_iPad", value: LCBool(true))
                            try userInfo.set("newData_Mac", value: LCBool(true))
                            
                            
                            userInfo.save() { (result) in
                                switch result {
                                case .success:
                                    break
                                case .failure(error: let error):
                                    print(error)
                                }
                            }
                        }
                        catch {
                            print(error)
                        }
                    case .failure(error: let error):
                        print("未有该用户的数据在云端: \(error)")
                    }
                }
            }
            
            else{
            do {
                // 构建对象
                let userInfo = LCObject(className: "UserInfo")

                // 为属性赋值
                try userInfo.set("user", value: LCString(user))
                
                // 数据更新标记
                try userInfo.set("newData", value: LCBool(true))
                try userInfo.set("newData_iPad", value: LCBool(true))
                try userInfo.set("newData_Mac", value: LCBool(true))
                
                // 将对象保存到云端
                _ = userInfo.save { result in
                    switch result {
                    case .success:
                        // 成功保存之后，执行其他逻辑
                        break
                    case .failure(error: let error):
                        // 异常处理
                        print(error)
                    }
                }
            } catch {
                print(error)
            }
            }
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3){ [self] in
                self.showCurrentUserInfo()}
        }

    }
    
    //从云端同步数据
    func downloadFromCloud() {
        if isLocalSessionVertified {
            let user = LCApplication.default.currentUser?.username?.stringValue ?? "Anonymous"
            let query = LCQuery(className: "UserInfo")
            query.whereKey("user", .equalTo("\(user)"))
            
            //查询得到的话则更新，一个用户保留一条数据
            if  query.count().intValue != 0 {
                _ = query.getFirst { result in
                    switch result {
                    case .success(object: let userInfo):
                        print("已有该用户数据在云端")
                        //更新
                        do {
                            
                            print("Sync Test")
                            self.UD_learningBook = userInfo.get("learningBook")?.stringValue ?? "无课本"
                            self.UD_searchHistoryCount = userInfo.get("searchHistoryCount")?.intValue ?? 0
                            let tmpLastLearnDone =  userInfo.get("isLastLearnDone")?.boolValue ?? false
                            self.UD_isLastLearnDone = tmpLastLearnDone
                            self.UD_learnDayCount = userInfo.get("learnDayCount")?.intValue ?? 1
                            
                            //更新新数据标签
                            if Device.deviceType == .iPad{
                                try userInfo.set("newData_iPad", value: LCBool(false))
                            }else if Device.deviceType == .Mac{
                                try userInfo.set("newData_Mac", value: LCBool(false))
                            }else{
                                try userInfo.set("newData", value: LCBool(false))
                            }

                            userInfo.save() { (result) in
                                switch result {
                                case .success:
                                    break
                                case .failure(error: let error):
                                    print(error)
                                }
                            }
                            self.UD_newData = false
                        }
                        catch {
                            print(error)
                        }
                    case .failure(error: let error):
                        print("未有该用户的数据在云端: \(error)")
                    }
                }
            }
            
        
    }
    }
    
    func currentUserInfo() -> String {
        if let user = LCApplication.default.currentUser {
            // 跳到首页
            //print("获取到当前用户")
            return user.email?.value ?? "获取邮箱失败"
        } else {
            // 显示注册或登录页面
            print("获取用户失败")
            return "获取用户失败"
        }
    }
    
    func checkNewDataFromCloud(){
        if isLocalSessionVertified {
            let user = LCApplication.default.currentUser?.username?.stringValue ?? "Anonymous"
            let query = LCQuery(className: "UserInfo")
            query.whereKey("user", .equalTo("\(user)"))
            if  query.count().intValue != 0 {
                _ = query.getFirst { result in
                    switch result {
                    case .success(object: let userInfo):
                        var tmpNewData:Bool = false
                        //更新新数据标签
                        if Device.deviceType == .iPad{
                            tmpNewData = userInfo.get("newData_iPad")?.boolValue ?? false
                        }else if Device.deviceType == .Mac{
                            tmpNewData = userInfo.get("newData_Mac")?.boolValue ?? false
                        }else{
                            tmpNewData = userInfo.get("newData")?.boolValue ?? false
                        }
                        self.UD_newData = tmpNewData
                        
                        print("是否有新的云端数据: \(self.UD_newData)")
                    case .failure(error: let error):
                        print("未有该用户的数据在云端: \(error)")
                    }
                }
            }
        }
    }
    
    //刷新界面显示的云端数据
    func showCurrentUserInfo() {
        if isLocalSessionVertified {
            let user = LCApplication.default.currentUser?.username?.stringValue ?? "Anonymous"
            let query = LCQuery(className: "UserInfo")
            query.whereKey("user", .equalTo("\(user)"))

            
            //查询得到的话则更新，一个用户保留一条数据
            if  query.count().intValue != 0 {
                _ = query.getFirst { result in
                    switch result {
                    case .success(object: let userInfo):
                        //print("已有该用户数据在云端")
                        //更新展示的数据
                        self.Cloud_learningBook = userInfo.get("learningBook")?.stringValue ?? "无课本"
                        let Cloud_wordStatusList_LC = userInfo.get("wordStatusList") as? LCArray
                        let Cloud_wordStatusList = Cloud_wordStatusList_LC?.arrayValue
                        //print(Cloud_wordStatusList)
                        self.UD_Cloud_learningBook = self.Cloud_learningBook
                        self.Cloud_allWordNum = Int(Cloud_wordStatusList![0] as! Double)
                        self.Cloud_knownWordNum = Int(Cloud_wordStatusList![1] as! Double)
                        self.Cloud_learningWordNum = Int(Cloud_wordStatusList![2] as! Double)
                        self.Cloud_unlearnedWordNum = Int(Cloud_wordStatusList![3] as! Double)
                        
                        self.Cloud_noteBookNum = userInfo.get("noteBookNum")?.intValue ?? 0
                        self.Cloud_todoNum = userInfo.get("todoNum")?.intValue ?? 0
                        self.Cloud_searchHistoryCount = userInfo.get("searchHistoryCount")?.intValue ?? 0
                        
                        
                    case .failure(error: let error):
                        print("未有该用户的数据在云端: \(error)")
                    }
                }
            }
            
        
    }
    }
    
    func vertifyLocalSession() {
        //判断本地的session是否能登录成功
        let UD_userSession = UserDefaults.standard.string(forKey: "UD_userSession")
        
        _ = LCUser.logIn(sessionToken: "\(UD_userSession ?? "noSession")") { (result) in
            switch result {
            case .success(object: let user):
                // 登录成功
                print("Session云端验证成功: \(user)")
                self.isLocalSessionVertified = true
                
            case .failure(error: let error):
                // session token 无效
                print("Session云端验证失败: \(error)")
                self.isLocalSessionVertified = false
            }
        }
    }
    
    
    
    
    //初始化设置
    class func LeanCloudSet() {
        //LCApplication.logLevel = .verbose
        do {
            try LCApplication.default.set(
                id: "7VqW9WIS3vtxkGGVq2SBPwsw-gzGzoHsz",
                key: "IiLymQt8v9qOzzU41K48CwxC",
                serverURL: "https://7vqw9wis.lc-cn-n1-shared.com")
        } catch {
            print(error)
        }
    }
    
    //网络连通性测试
    class func LeanCloudTest() {
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
}
