//
//  LogInView.swift
//  LeanCloudTest
//
//  Created by YES on 2021/1/29.
//

import SwiftUI

struct LogInView: View {
    @StateObject var userVM = UserViewModel()
    
    
    // UserDefault数据
    @AppStorage("UD_username") var UD_username = ""
    @AppStorage("UD_userPassword") var UD_userPassword = ""
    @AppStorage("UD_userSession") var UD_userSession = ""
    @AppStorage("UD_isUsingBioID") var UD_isUsingBioID = true
    
    //本地校验
    @AppStorage("UD_isLogged") var UD_isLogged = false
    
    
    @State var useremail_input = ""
    @State var password_input = ""
    
    @State var startAnimate = false
    
    @State var test = ""
    @State var alertTest = false
    
    @State var isSignUpView = false
    
    var body: some View {
        ZStack{
            VStack{
                VStack(spacing:0) {
                    Image("login")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 300, height: 200, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .padding(.vertical)
                    
                    HStack{
                        VStack(alignment: .leading, spacing: 12, content: {
                            
                            Text(isSignUpView ? "注册" :"登录")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Color(.systemBlue))
                            
                            Text(isSignUpView ? "注册新账号" : "登录账号以同步学习记录")
                                .foregroundColor(Color(.systemBlue).opacity(0.8))
                        })
                        
                        Spacer(minLength: 0)
                    }
                    .padding([.top,.bottom],10)
                    .padding(.leading,30)
                }
                
                VStack{
                    HStack{
                        Image(systemName: "envelope")
                            .font(.title2)
                            .foregroundColor(Color(.systemGray))
                            .frame(width: 35)
                        TextField(isSignUpView ? "未注册的邮箱" :"邮箱", text: $useremail_input)
//                        TextField(isSignUpView ? "未注册的邮箱" :"邮箱", text: $userVM.userEmail)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                    }
                    .padding()
                    //.background(Color.white)
                    .background(Color.white.opacity(userVM.userEmail == "" ? 0.7 : 1))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    HStack{
                        Image(systemName: "lock")
                            .font(.title2)
                            .foregroundColor(Color(.systemGray))
                            .frame(width: 35)
                        SecureField(isSignUpView ? "登录密码" :"密码", text: $password_input)
//                        SecureField(isSignUpView ? "登录密码" :"密码", text: $userVM.userPassword)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                    }
                    .padding()
                    .background(Color.white.opacity(userVM.userPassword == "" ? 0.7 : 1))
                    .cornerRadius(15)
                    .padding(.horizontal)
                }
                .alert(isPresented: $userVM.bioUsingAlert, content: {
                    Alert(title: Text("启用生物识别"), message: Text("是否使用TouchID/FaceID来登录"), primaryButton: .cancel(Text("使用"), action: {
                        UD_isUsingBioID = true
//                        print(UD_isUsingBioID)
                        withAnimation{
                            print("准备进入主页面")
                            self.UD_isLogged = true
                            print("本地验证结果: \(self.UD_isLogged)")
                            self.userVM.vertifyLocalSession()
                        }
                    }), secondaryButton: .destructive(Text("不使用"), action: {
                        withAnimation{
                            print("准备进入主页面")
                            self.UD_isLogged = true
                            print("本地验证结果: \(self.UD_isLogged)")
                            self.userVM.vertifyLocalSession()
                        }
                    }))
                })
                
                if !isSignUpView{
                    HStack(spacing: 15){
                        Button(action:
                                {
                                    userVM.userEmail = useremail_input
                                    userVM.userPassword = password_input
                                    self.userVM.userLogIn()
                                }, label: {
                                    Text("登 录")
                                        .fontWeight(.heavy)
                                        .foregroundColor(.white)
                                        .padding(.vertical)
                                        .frame(width: UIScreen.main.bounds.width - 150)
                                        .background(Color("loginColor"))
                                        .clipShape(Capsule())
                                })
                            .opacity(useremail_input != "" && password_input != "" ? 1 : 0.5)
                            .disabled(useremail_input != "" && password_input != "" ? false : true)
                            .alert(isPresented: $userVM.logInAlert, content: {
                                Alert(title: Text("用户登录错误"), message: Text(userVM.logInAlertMsg), dismissButton: .destructive(Text("重试")))
                            })
                        
                        Button(action: {
                            self.userVM.authenticateUser()
                        }
                        , label: {
                            Image(systemName: "faceid")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color("loginColor"))
                                .clipShape(Circle())
                        })
                        .opacity(UD_username != "" && UD_userPassword != "" && userVM.getBioMetricStatus() && UD_isUsingBioID ? 1 : 0.5)
                        .disabled(UD_username != "" && UD_userPassword != "" && UD_isUsingBioID ? false : true)
                        .onAppear(perform: {
                            print("生物识别状态: \(UD_isUsingBioID)")
                        })
                        
                        
                        
                    }
                    .padding(.top)
                }
                else{
                    HStack(spacing: 15){
                        Button(action:
                                {
                                    userVM.userEmail = useremail_input
                                    userVM.userPassword = password_input
                                    self.userVM.userSignUp()}, label: {
                                    Text("注 册")
                                        .fontWeight(.heavy)
                                        .foregroundColor(.white)
                                        .padding(.vertical)
                                        .frame(width: UIScreen.main.bounds.width - 80)
                                        .background(Color("loginColor"))
                                        .clipShape(Capsule())
                                })
                            .opacity(useremail_input != "" && password_input != "" ? 1 : 0.5)
                            .disabled(useremail_input != "" && password_input != "" ? false : true)
                            .alert(isPresented: $userVM.signUpAlert, content: {
                                Alert(title: Text("用户注册错误"), message: Text(userVM.signUpAlertMsg), dismissButton: .destructive(Text("关闭")))
                            })
                        
                    }
                    .padding(.top)
                }
                
                if !isSignUpView{
                    Button(action: {}, label: {
                        Text("忘记密码？")
                            .foregroundColor(Color("loginColor"))
                    })
                    .padding()
                    
                }else{
                    Button(action: {}, label: {Text("用户云存储由LeanCloud驱动").foregroundColor(Color(.systemGray))})
                        .padding()
                }
                
                Spacer()
                
                if !isSignUpView{
                    HStack(spacing: 5){
                        Text("还没有账号？")
                            .foregroundColor(Color(.systemTeal))
                        
                        Button(action: {
                            withAnimation{isSignUpView.toggle()}
                        }, label: {
                            Text("注册新账号")
                                .fontWeight(.heavy)
                                .foregroundColor(Color("loginColor"))
                        })
                    }
                    .padding(.vertical)
                }else{
                    HStack(spacing: 5){
                        Text("已有账号")
                            .foregroundColor(Color(.systemTeal))
                        Button(action: {
                            withAnimation{isSignUpView.toggle()}
                        }, label: {
                            Text("前往登录")
                                .fontWeight(.heavy)
                                .foregroundColor(Color("loginColor"))
                        })
                    }
                    .padding(.vertical)
                }
            }
            .background(Color(.systemGray6).ignoresSafeArea(.all, edges: .all))
            
            
            
            
            if userVM.isLoading{
                LoadingView()
            }
        }
    }
}

struct LogInView_Previews: PreviewProvider {
    static var previews: some View {
        LogInView()
    }
}
