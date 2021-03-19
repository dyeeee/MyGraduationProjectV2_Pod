//
//  PersonalView.swift
//  MyGraduationProjectV2
//
//  Created by YES on 2021/2/1.
//

import SwiftUI

struct PersonalView: View {
    @StateObject var userVM:UserViewModel
    @StateObject var wordVM:WordViewModel
    @AppStorage("UD_isLogged") var UD_isLogged = false
//    @AppStorage("UD_isUsingBioID") var UD_isUsingBioID = false
    
    var body: some View {
        //本地UD在已登录状态，本地存的session验证通过则显示用户信息和用户操作
        if (UD_isLogged && self.userVM.isLocalSessionVertified) {
            UserInfoView(userVM: self.userVM, wordVM: self.wordVM)
        }else if(UD_isLogged){
            ZStack {
                LogInView(userVM:self.userVM)//.navigationBarHidden(true)
                    .navigationBarTitle("登录/注册")
                    .navigationBarTitleDisplayMode(.inline)
                
                ZStack {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.2)
                            .frame(width: 100, height: 100)
                            .background(RoundedRectangle(cornerRadius: 10, style: .continuous).foregroundColor(Color(.systemGray5)))
                            //.offset(x: 0, y: -70)
                            .zIndex(1)
                        
                        Text("登录中...")
                    }
                     //这样可以，效果待优化
                }
            }
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
        PersonalView(userVM: UserViewModel(), wordVM: WordViewModel())
    }
}
