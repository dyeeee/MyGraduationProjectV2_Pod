//
//  PersonalView.swift
//  MyGraduationProjectV2
//
//  Created by YES on 2021/2/1.
//

import SwiftUI

struct PersonalView: View {
    @StateObject var userVM:UserViewModel
    @AppStorage("UD_isLogged") var UD_isLogged = true
//    @AppStorage("UD_isUsingBioID") var UD_isUsingBioID = false
    
    var body: some View {
        //本地UD在已登录状态，本地存的session验证通过则显示用户信息和用户操作
        if (UD_isLogged && self.userVM.isLocalSessionVertified) {
            UserInfoView(userVM: self.userVM)
        }
        else{
            LogInView(userVM:self.userVM)//.navigationBarHidden(true)
                .navigationBarTitle("登录/注册")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct PersonalView_Previews: PreviewProvider {
    static var previews: some View {
        PersonalView(userVM: UserViewModel())
    }
}
