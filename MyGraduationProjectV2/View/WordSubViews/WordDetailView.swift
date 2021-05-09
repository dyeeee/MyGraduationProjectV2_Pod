//
//  WordDetailView.swift
//  MyVocabularyBook
//
//  Created by YES on 2020/11/24.
//

import SwiftUI
import MobileCoreServices

//一个单词的详情页面
//关键在于，如何让每个不同地方的点进来的时候都是更新好的页面
//之前用一个全局controller实现的，用viewmodel的话不同页面有不同的模型？
//每次onAppear的时候都刷新一次？详情页面的Viewmodel之前没写过类似的
//List页面用一个model，
struct WordDetailView: View {
    @StateObject var wordItem:WordItem
    @StateObject var wordVM: WordViewModel
    @State var orientation = UIDevice.current.orientation
    
    @State var wordNote:String = ""
    
    @State var showNotePlaceholder = true
    
    @State var showTrans = true
    @State var showExchange = true
    @State var showExampleSentences = true
    @State var showNote = true
    @State var showNoteSaveButton = false
    @AppStorage("UD_autoSync") var UD_autoSync = false
    //延时查询优化性能表现
    @State var timeRemaining = 10
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    //@State var searching = false
    
    var body: some View {
        ScrollViewReader { reader in
            List {
                VStack(alignment:.leading) {
                    HStack {
                        Menu{
                            Button(action: {
                                UIPasteboard.general.string = wordItem.wordContent ?? "null"
                            }) {
                                Text("Copy to clipboard")
                                Image(systemName: "doc.on.doc")
                            }
                        }label: {
                            WordContentView(wordContent:wordItem.wordContent ?? "null")
                        }
                        
                        Button(action: {
                            if(wordItem.starLevel>0) {
                                // 本来>0的，点击后取消
                                wordItem.starLevel = 0
                                wordItem.isSynced = false
                                //改为延迟保存
                                //wordVM.saveToPersistentStoreAndRefresh(.notebook)
                            }else{
                                // 本来=0的，点击后星级至少为1
                                wordItem.starLevel = 1
                                wordItem.isSynced = false
                                //wordVM.saveToPersistentStoreAndRefresh(.notebook)
                            }
                            //启动计时器
                            timeRemaining = 1
                            startTimer()
                        }, label: {
                            Image(systemName: wordItem.starLevel>0 ? "bookmark.fill":"bookmark")
                                .font(.headline)
                                .foregroundColor(wordItem.starLevel>0 ? Color("BookMarkColor"):.gray)
                        }).buttonStyle(PlainButtonStyle())
                        .padding(-5)
                        
                        
                        Spacer()
                        //Text("StarLevel "+String(wordItem.starLevel))
                        //                        StarLevelView(starLevel:Int(wordItem.starLevel))
                        if(wordItem.starLevel>0) {
                            HStack(spacing:-2.5) {
                                ForEach(1..<5 + 1) {
                                    number in
                                    Image(systemName: "star.fill")
                                        .font(.body)
                                        .foregroundColor(number > wordItem.starLevel ? Color.gray : Color("StarColor"))
                                        .onTapGesture {
                                            //每次单击都调整星级
                                            wordItem.starLevel = Int16(number)
                                            //wordVM.saveToPersistentStoreAndRefresh(.notebook)
                                            //启动计时器来延迟保存
                                            wordItem.isSynced = false
                                            timeRemaining = 1
                                            startTimer()
                                        }
                                }
                            }.padding(-5)
                        }
                        
                        
                    }
                    //                    Menu{
                    //                        VStack{
                    //                            Text("gk: 高考")
                    //                            Text("cet4/6: 四六级单词")
                    //                            Text("ky: 考研单词")
                    //                            Text("toefl: 托福单词")
                    //                            Text("ielts: 雅思单词")
                    //                            Text("gre: GRE单词")
                    //                        }.font(.caption2)
                    //                    }label: {
                    //                        Text(wordItem.wordTags ?? "null")
                    //                        .font(.subheadline)
                    //                        .foregroundColor(.black)
                    
                    WordPhoneticView(phonetic_EN: wordItem.phonetic_EN ?? "no phonetic_EN", phonetic_US: wordItem.phonetic_US ?? "no phonetic_US")
                    
                    WordTagsView(wordTags: wordItem.wordTags ?? "",bncLevel:Int(wordItem.bncLevel),frqLevel:Int(wordItem.frqLevel),oxfordLevel:Int(wordItem.oxfordLevel),collinsLevel:Int(wordItem.collinsLevel))
                    //                    }
                    
                    //                    HStack{
                    //                        Text(String(wordItem.collinsLevel))
                    //                        Text(String(wordItem.oxfordLevel))
                    //                        Text(String(wordItem.bncLevel))
                    //                        Text(String(wordItem.frqLevel))
                    //                    }.font(.subheadline)
                }.padding(.bottom,5)
                
                Section(header: ListHeader(img: "lightbulb.fill", text: "释义", showContent: $showTrans))
                {
                    if(showTrans) {
                        WordTranslationView(wordTranslastion: wordItem.translation ?? "no Trans", wordDefinition: wordItem.definition ?? "no Def")
                        
                        
                        //                    VStack(alignment: .leading, spacing: 10) {
                        //                        Text(dealBreak(wordItem.translation ?? "null"))
                        //
                        //                        Text(dealBreak(wordItem.definition ?? "null"))
                        //                    }
                        //                    .padding(.leading, 5)
                        //                    .padding(.trailing, 5)
                        //                    .contextMenu {
                        //                            Button(action: {
                        //                                UIPasteboard.general.string = dealBreak(wordItem.definition ?? "null")
                        //                            }) {
                        //                                Text("Copy to clipboard")
                        //                                Image(systemName: "doc.on.doc")
                        //                            }
                        //                         }
                    }
                }.animation(.default)
                
                if(wordItem.wordExchanges != "nullTag"){
                    Section(header: ListHeader(img: "doc.on.doc.fill", text: "词形变化", showContent: $showExchange))
                    {
                        if(showExchange) {
                            WordExchangesView(wordExchanges: wordItem.wordExchanges ?? "null")
                            
                            //                    VStack {
                            //                        SelectableTextView(dealExchanges(str: wordItem.wordExchanges ?? "null"))
                            //                            .frame(maxWidth: .infinity,  maxHeight: .infinity, alignment: .leading)
                            //
                            //                    }.padding(.leading, 5)
                        }
                    }.animation(.default)
                }
                
                if(wordItem.exampleSentences != "nullTag\""){
                    Section(header: HStack {
                        ListHeader(img:"scroll.fill",text:"例句", showContent: $showExampleSentences)
                    })
                    {
                        if(showExampleSentences) {
                            //                        VStack {
                            //                            SelectableTextView(dealExampleSentences(str: wordItem.exampleSentences ?? "null"),scrollEnable: true)
                            //                                .frame(maxWidth: .infinity, idealHeight: 400, maxHeight: .infinity, alignment: .leading)
                            //                        }.padding(.leading, 5)
                            WordExampleSentencesView(wordContent: wordItem.wordContent!, wordExampleSentences: wordItem.exampleSentences!)
                        }
                    }.animation(.easeInOut)
                    
                }
                
                Section(header:
                            HStack {
                                ListHeader(img: "note.text", text: "笔记", showContent: $showNote)
                                if(showNoteSaveButton){
                                    HStack {
                                        Button(action: {
                                            self.hideKeyboard()
                                            self.wordNote = wordItem.wordNote!
                                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.05) {
                                                self.showNoteSaveButton = false
                                                self.showNotePlaceholder = true
                                            }
                                            
                                        }, label: {
                                            VStack {
                                                Text("取消更改")
                                                    .font(.subheadline)
                                                    .padding(2)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 2.0)
                                                            .stroke())
                                            }.foregroundColor(Color(.systemGray))
                                            
                                        })
                                        Button(action: {
                                            self.hideKeyboard()
                                            wordItem.wordNote = self.wordNote
                                            
                                            if wordItem.starLevel == 0 && wordNote != "" {
                                                wordItem.starLevel = 1
                                                wordItem.isSynced = false
                                            }
                                            
                                            //延迟保存
                                            timeRemaining = 1
                                            startTimer()
                                            
                                            self.showNoteSaveButton = false
                                        }, label: {
                                            VStack {
                                                Text("保存")
                                                    .font(.subheadline)
                                                    .padding(2)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 2.0)
                                                            .stroke())
                                            }.foregroundColor(Color(.systemBlue))
                                            .padding(.trailing,10)
                                        })
                                    }
                                }
                            }
                ){
                    if(showNote){
                        VStack {
                            //                            TextField("test",text: .constant("test"))
                            ZStack {
                                if(wordNote == "" && showNotePlaceholder == true){
                                    HStack{
                                        Text("输入笔记")
                                            .font(.subheadline)
                                            .foregroundColor(Color(.systemGray2))
                                        Spacer()
                                    }
                                }
                                
                                //multiLineTextField(text:self.$wordNote)////可多行，但不能自动上滚
                                TextEditor(text: self.$wordNote) //可多行，但不能自动上滚
                                    //TextField("",text: self.$wordNote) //可自动上滚，不能多行
                                    .onChange(of: self.wordNote, perform: { value in
                                        self.showNoteSaveButton = true
                                        
                                    })
                                //这是为了自动扩充editor的高度
                                Text(self.wordNote).opacity(0).padding(.all, 8)
                            }
                            .onTapGesture(perform: {
                                self.showNotePlaceholder = false
                                self.showNoteSaveButton = true
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                                    //reader.scrollTo("noteSection")
                                    //滚动到笔记section
                                    withAnimation {
                                        reader.scrollTo("noteSection")
                                    }
                                } //延迟一会后滚动
                            })
                        }.id("noteSection")
                        
                    }
                    
                }
                
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) {
                    self.wordVM.saveToPersistentStore()
                    self.wordVM.getHistoryItems()
                }
            })
            .listStyle(InsetGroupedListStyle())
            //            .toolbar(content: {
            //                ToolbarItem(placement: .bottomBar) {
            //                    HStack {
            //                        Button(action: {
            //                            if(wordItem.starLevel>0) {
            //                                // 本来>0的，点击后取消
            //                                wordItem.starLevel = 0
            //                                wordListViewModel.saveToPersistentStoreAndRefresh(.notebook)
            //                            }else{
            //                                // 本来=0的，点击后星级至少为1
            //                                wordItem.starLevel = 1
            //                                wordListViewModel.saveToPersistentStoreAndRefresh(.notebook)
            //                            }
            //                        }, label: {
            //                            HStack(spacing:0) {
            //                                Image(systemName: wordItem.starLevel>0 ? "bookmark.fill":"bookmark")
            //                                    .font(.headline)
            //                                VStack {
            //                                    Text("添加到生词本")
            //                                        .font(.subheadline)
            //                                        .fontWeight(.semibold)
            //                                        .padding(1)
            //                                        .overlay(
            //                                            RoundedRectangle(cornerRadius: 2.0)
            //                                                .stroke())
            //                                }
            //                            }.font(.subheadline)
            //                    })
            //                        Text("")
            //                    }.foregroundColor(Color(.systemRed))
            //                }
            //                ToolbarItem(placement: .bottomBar) {
            //                    HStack {
            //                        Button(action: {
            //
            //                        }, label: {
            //                            HStack(spacing:0) {
            //                                Image(systemName: "doc.append")
            //                                    .font(.headline)
            //                                VStack {
            //                                    Text("单词卡")
            //                                        .font(.subheadline)
            //                                        .fontWeight(.semibold)
            //                                        .padding(1)
            //                                        .overlay(
            //                                            RoundedRectangle(cornerRadius: 2.0)
            //                                                .stroke())
            //                                }
            //                            }.font(.subheadline)
            //                    })
            //                        Text("")
            //                    }.foregroundColor(Color(.systemBlue))
            //                }
            //            })
            .navigationTitle(wordItem.wordContent ?? "null")
            .onReceive(timer) { _ in
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                }
                if self.timeRemaining == 0 {
                    //执行保存操作
                    wordVM.saveToPersistentStoreAndRefresh(.notebook)
                    stopTimer()
                    
                    if UD_autoSync{
                        print("自动同步中")
                        let tmpUSerVM = UserViewModel()
                        tmpUSerVM.vertifyLocalSession()
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3){
                            wordVM.uploadToCloud()
                            tmpUSerVM.uploadUserInfoCheck()
                        }
                    }
                }
            }
            .onAppear() {
                self.stopTimer()
            }
            .ifIs(Device.deviceType == .iPhone){
                //iPhone才隐藏状态栏
                $0.hiddenTabBar()
            }
            .ifIs(Device.deviceType == .iPad && (orientation.isPortrait)){
                //iPad竖屏状态隐藏
                $0.hiddenTabBar()
            }
            .ifIs(Device.deviceType == .iPad && orientation.isLandscape){
                $0.showTabBar()
            }
            //更改方向
            .onReceive(NotificationCenter.Publisher(center: .default, name: UIDevice.orientationDidChangeNotification)) { _ in
                if UIDevice.current.orientation != UIDeviceOrientation(rawValue: 5){
                    self.orientation = UIDevice.current.orientation
                }
            }
            .onAppear(perform: {
                if UIDevice.current.orientation != UIDeviceOrientation(rawValue: 0){
                    orientation = UIDevice.current.orientation
                }
                //print(orientation.rawValue)
            })
            
        }
        
    }
    
    func stopTimer() {
        self.timer.upstream.connect().cancel()
    }
    
    func startTimer() {
        self.timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    }
}

struct ListHeader: View {
    var img:String = "scroll.fill"
    var text:String = "header"
    @Binding var showContent:Bool
    
    var body: some View {
        HStack {
            Button(action: {showContent.toggle()}, label: {
                //Text("show")
                HStack(spacing:5) {
                    Image(systemName: img)
                    Text(text)
                    Image(systemName: self.showContent ? "minus.rectangle" :"plus.square")
                }.font(.subheadline)
                .animation(.default)
                
                
            })
            Spacer()
            
        }.foregroundColor(Color("ListHeaderColor"))
        .padding([.leading],5)
    }
}


struct WordDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let wordItem = WordItem(context: PersistenceController.preview.container.viewContext)
        wordItem.starLevel = 3
        wordItem.wordContent = "alleviate"
        wordItem.phonetic_EN = "ә'li:vieit"
        wordItem.phonetic_US = "[ə'livɪ'et]"
        wordItem.definition = "v provide physical relief, as from pain\nv make easier"
        wordItem.translation = "vt. 减轻, 使缓和"
        wordItem.collinsLevel = 1
        wordItem.wordTags = "cet6 ky toefl ielts gre"
        wordItem.bncLevel = 7706
        wordItem.frqLevel = 55
        wordItem.wordExchanges = "d:alleviated/i:alleviating/3:alleviates/p:alleviated"
        wordItem.exampleSentences = "Excuse me what eyedrop can be treated or to what eyedrop can be treated or alleviate myopic eyedrop ah?<br>请问一下有没有什么眼药水可以治疗或缓解近视的眼药水啊？<br>And ease the tension in the form of many, why not bring serious harm to the body of a factor to alleviate it?<br>而且缓解紧张情绪的形式很多，为什么非要拿一个严重危害身体的因素来缓解呢？<br>The reason that cats can alleviate negative moods is often attributed to attachment - the emotional bond between cat and owner.<br>猫能够改善人们负性情绪的原因往往都归于他们对人的依恋——猫与主人间的感情粘合剂。<br>'We'd like to see if diet after birth could alleviate this problem that was programmed before birth, ' he said.<br>“我们希望能看见出生后饮食方式的改变可以减轻这些出生前引起的问题，”他说。<br>Use in the database compress a technology, it is to solve (perhaps alleviate at least) place of this kind of pressure one of made effort.<br>在数据库中使用压缩技术，是为了解决（或者至少缓解）这种压力所做出的努力之一。<br>And if scientists can unravel what underlies these biological differences, they might be able to alleviate inborn disparities.<br>如果科学家们能够解决造成这种生物学差异的原因，也许就能缓解人们的先天差距。<br>North Korea said on Monday that it was ready to discuss humanitarian aid from the South to alleviate damage caused by flooding and typhoons.<br>周一，朝鲜表示已准备好就从韩国获取人道主义援助进行商讨，以缓解洪灾和台风造成的损失。<br>Goldman Sachs said the moves 'should help to . . . alleviate market stresses, but are incremental rather than transformational' .<br>高盛（GoldmanSachs）表示：“此举应有助于……减轻市场压力，但是是一种量变而非质变。”<br>Jesus' hunger, she said, is what 'you and I must find' and alleviate.<br>她说，“耶稣的饥渴，是你我必须要寻求且予以帮助的。”<br>One of the nurses asked if I would like some ice chips to help alleviate problem.<br>一位护士问我要不要含一些碎冰块来缓解一下。<br>"
        
        wordItem.wordNote = ""
        
        return
            
            NavigationView {
                WordDetailView(wordItem: wordItem, wordVM: WordViewModel(),wordNote:wordItem.wordNote ?? "").environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                    .navigationBarTitleDisplayMode(.inline)
            }
    }
}
