//
//  UserDefaultTools.swift
//  MyGraduationProjectV1
//
//  Created by YES on 2021/1/27.
//

import SwiftUI
import Foundation

//判断是否到了新的一天
public func isNewDay() -> Bool {
    let today = Date().dateToString(format: "yyyyMMdd")
    let lastLogIn = UserDefaults.standard.string(forKey: "UD_lastLogInDateString")
    if today == lastLogIn {
        return false
    }else{
        return true
    }
}

//如果上一次没有学习就不会更新学习天数
public func setLearnDay() {
    if (UserDefaults.standard.bool(forKey: "UD_isLastLearnDone") && isNewDay()) {
        let userVMtmp = UserViewModel()
        userVMtmp.uploadUserInfo()
        UserDefaults.standard.setValue(UserDefaults.standard.integer(forKey: "UD_learnDayCount")+1, forKey: "UD_learnDayCount")
        UserDefaults.standard.setValue(false, forKey: "UD_isLastLearnDone")
    }
    
    
    
    //判断完成后设置最后启动日期
    UserDefaults.standard.setValue(Date().dateToString(format: "yyyyMMdd"), forKey: "UD_lastLogInDateString")
}


//用于测试，点击时模拟完成今日学习并进入下一天的学习
public func setLearnDayTest() {
        UserDefaults.standard.setValue(UserDefaults.standard.integer(forKey: "UD_learnDayCount")+1, forKey: "UD_learnDayCount")
        UserDefaults.standard.setValue(false, forKey: "UD_isLastLearnDone")
}
