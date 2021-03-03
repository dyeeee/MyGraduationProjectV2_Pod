//
//  NoteListView.swift
//  MyGraduationProjectV1
//
//  Created by YES on 2021/1/13.
//

import SwiftUI

struct NotebookListView: View {
    @StateObject var wordVM: WordViewModel
    @State private var searchText = ""
    
    @State var noteTypeIndex = 0
    
    @State var typeIndex = "5"
    
    @State var showStar5 = true
    
    let alphaList = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    
    let alphaListSub1 = ["A","B","C","D","E","F","G","H","I","J","K","L","M"]
    let alphaListSub2 = ["N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    
    @State var SyncingAnimate = false
    
    var body: some View {
        NavigationView{
            ScrollViewReader { reader in
                VStack(spacing:0) {
                    //                ScrollView {
                    Picker(selection: self.$noteTypeIndex, label: Text("Picker"), content:
                            {
                                Text("星级").tag(0)
                                Text("字母").tag(1)
                                Text("笔记").tag(2)
                            })
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(5)
                        .padding([.top,.bottom],5)
                        .background(Color(.systemGray6))
                    
                    
                    TabView(selection: self.$noteTypeIndex){
                        VStack {
                            //定位到对应id的星级按钮
                            HStack {
                                Image(systemName: "scroll.fill")
                                Button(action: {
                                    withAnimation{
                                        reader.scrollTo(5)
                                    }
                                }, label: {
                                    FilterStar(num:5)
                                })
                                
                                Button(action: {
                                    withAnimation{
                                        reader.scrollTo(4)
                                    }
                                }, label: {
                                    FilterStar(num:4)
                                })
                                
                                Button(action: {
                                    withAnimation{
                                        reader.scrollTo(3)
                                    }
                                }, label: {
                                    FilterStar(num:3)
                                })
                                
                                Button(action: {
                                    withAnimation{
                                        reader.scrollTo(2)
                                    }
                                }, label: {
                                    FilterStar(num:2)
                                })
                                
                                Button(action: {
                                    withAnimation{
                                        reader.scrollTo(1)
                                    }
                                }, label: {
                                    FilterStar(num:1)
                                })
                                Spacer()
                            }
                            .padding(.leading,10)
                            .foregroundColor(Color("WordLevelsColor"))
                            
                            //Text("test")
                            
                            List { //双重列表，先分好组再传进来，section[0]为该组的第一个单词
                                ForEach(self.wordVM.groupedStarLevelList, id: \.self) { //每个section都是同一组的item
                                    (section: [WordItem]) in
                                    Section(header:
                                                HStack(spacing:0) {
                                                    ForEach(0..<Int(section[0].starLevel)){_ in
                                                        Image(systemName: "star.fill")
                                                    }
                                                }.font(.footnote)
                                                .foregroundColor(Color("StarColor"))
                                                .animation(.default)
                                                .padding([.leading],5)
                                            
                                    ) {
                                        ForEach(section, id: \.self) {
                                            item in
                                            NavigationLink(
                                                destination: WordDetailView(wordItem:item,wordVM:wordVM,wordNote: item.wordNote ?? "nullTag")){
                                                VStack(alignment:.leading){
                                                    Text(item.wordContent ?? "noContent")
                                                        .font(.title3)
                                                    
                                                    Text(dealTrans(item.translation ?? "noTranslation").replacingOccurrences(of: "\n", with: "; "))
                                                        .font(.footnote)
                                                        .foregroundColor(Color(.systemGray))
                                                        .lineLimit(1)
                                                }
                                                //.frame(height: 30)
                                                .padding([.leading],-5)
                                            }
                                        }.id(Int(section[0].starLevel))
                                    }
                                }
                            }
                            .listStyle(InsetGroupedListStyle())
                            //.environment(\.horizontalSizeClass, .regular)
                            //.environment(\.defaultMinListRowHeight, 20)
                        }
                        .tag(0)
                        
                        VStack {
                            //定位到对应id的字母按钮
                            HStack {
                                Image(systemName: "scroll.fill")
                                VStack(spacing:2.5) {
                                    HStack(spacing:5){
                                        
                                        ForEach(self.alphaListSub1,id:\.self){
                                            char in
                                            Button(action: {
                                                withAnimation{
                                                    reader.scrollTo(char.uppercased())
                                                }
                                            }, label: {
                                                FilterLabel(text:char)
                                            })
                                            
                                        }
                                        
                                        Spacer()
                                    }
                                    HStack(spacing:5){
                                        
                                        ForEach(self.alphaListSub2,id:\.self){
                                            char in
                                            Button(action: {
                                                withAnimation{
                                                    reader.scrollTo(char.uppercased())
                                                }
                                            }, label: {
                                                FilterLabel(text:char)
                                            })
                                            
                                        }
                                        
                                        Spacer()
                                    }
                                }
                            }
                            .padding(.leading,10)
                            .foregroundColor(Color("WordLevelsColor"))
                            .padding(.bottom,-5)
                            .padding(.top,2)
                            //Text("test")
                            
                            
                            List { //双重列表，先分好组再传进来，section[0]为该组的第一个单词
                                ForEach(self.wordVM.groupedABCList, id: \.self) { //每个section都是同一组的item
                                    (section: [WordItem]) in
                                    Section(header:
                                                HStack(spacing:0) {
                                                    Image(systemName: "\(section[0].wordContent!.prefix(1).lowercased()).square")
                                                }.font(.callout)
                                                .foregroundColor(Color(.systemBlue))
                                                .animation(.default)
                                                .padding([.leading],5)
                                    )
                                    {
                                        ForEach(section, id: \.self) {
                                            item in
                                            NavigationLink(
                                                destination: WordDetailView(wordItem:item,wordVM:wordVM,wordNote: item.wordNote ?? "nullTag")){
                                                VStack(alignment:.leading){
                                                    Text(item.wordContent ?? "noContent")
                                                        .font(.title3)
                                                    
                                                    Text(dealTrans(item.translation ?? "noTranslation").replacingOccurrences(of: "\n", with: "; "))
                                                        .font(.footnote)
                                                        .foregroundColor(Color(.systemGray))
                                                        .lineLimit(1)
                                                }
                                                //.frame(height: 30)
                                                .padding([.leading],-5)
                                            }
                                        }
                                        //.id((section[0].wordContent!.uppercased()))
                                        .id((section[0].wordContent!.prefix(1).uppercased()))
                                    }
                                }
                            }
                            .listStyle(InsetGroupedListStyle())
                            //.environment(\.defaultMinListRowHeight, 20)
                            //.environment(\.horizontalSizeClass, .compact)
                            
                        }.tag(1)
                        
                        
                        
                        Text("Test Page")
                            .tag(2)
                    }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                }
                .navigationTitle("生词本")
                .navigationBarColor(.systemGroupedBackground)
                //.tabBarColor(.systemGroupedBackground)
                
                .background(Color(.systemGray6))
                .navigationBarTitleDisplayMode(.inline)
                .showTabBar()
                //                .onAppear() {
                //                        UITabBar.appearance().barTintColor = .systemGroupedBackground
                //                    }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) { // <3>
                        Button {
                            self.wordVM.downloadFromCloud()
                        } label: {
                            Image(systemName:"icloud.and.arrow.down")
                        }
                        
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) { // <3>
                        HStack {
                            Image(systemName:!self.wordVM.isSyncing ? "checkmark.icloud" : "exclamationmark.icloud")
                                
                        }
                        .foregroundColor(Color(.systemGray))
                        .font(.title2)

                    }
                }
            }
        }
        
    }
    
}

struct FilterLabel: View {
    @State var text:String = "A"
    
    var body: some View {
        VStack {
            Text("\(text)")
                .font(.callout)
                .fontWeight(.semibold)
        }
        .frame(width:18,height: 18)
        .overlay(
            RoundedRectangle(cornerRadius: 2.0)
                .stroke())
    }
}

struct FilterStar: View {
    @State var num:Int = 1
    
    var body: some View {
        HStack(spacing:-5) {
            ForEach(0..<num){_ in
                Image(systemName: "star.fill")
                    .buttonStyle(PlainButtonStyle())
            }
        }.font(.callout)
        .overlay(
            RoundedRectangle(cornerRadius: 2.0)
                .stroke())
        
    }
}


struct NotebookListView_Previews: PreviewProvider {
    static var previews: some View {
        
        for _ in 0..<10 {
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
            wordItem.exampleSentences = "Excuse me what eyedrop can be treated or to what eyedrop can be treated or alleviate myopic eyedrop ah?<br>请问一下有没有什么眼药水可以治疗或缓解近视的眼药水啊？<br>And ease the tension in the form of many, why not bring serious harm to the body of a factor to alleviate it?"
            wordItem.wordNote = ""
        }
        
        return NotebookListView(wordVM: WordViewModel())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
