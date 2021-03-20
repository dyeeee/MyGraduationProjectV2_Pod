//
//  PieChartView.swift
//  ChartView
//
//  Created by András Samu on 2019. 06. 12..
//  Copyright © 2019. András Samu. All rights reserved.
//

import SwiftUI

public struct PieChartView : View {
    public var data: [Double]
    public var title: String
    public var legend: String?
    public var style: ChartStyle
    public var formSize:CGSize
    public var dropShadow: Bool
    public var valueSpecifier:String
    @State var screenWidth = UIScreen.main.bounds.width
    @State var stateData: [Double] = [0,0,0]
    @State private var showValue = false
    @State private var currentValue: Double = 0 {
        didSet{
            if(oldValue != self.currentValue && self.showValue) {
                HapticFeedback.playSelection()
            }
        }
    }
    @State var legendList = ["未学习","已掌握","学习中"]
    
    public init(data: [Double], title: String, legend: String? = nil, style: ChartStyle = Styles.pieChartStyleOne, form: CGSize? = ChartForm.medium, dropShadow: Bool? = true, valueSpecifier: String? = "%.f"){
        self.data = data
        //print("饼图的数据: \(self.data)")
        self.title = title
        self.legend = legend
        self.style = style
        self.formSize = form!
        if self.formSize == ChartForm.large {
            self.formSize = ChartForm.extraLarge
        }
        self.dropShadow = dropShadow!
        self.valueSpecifier = valueSpecifier!
        self.stateData = data
    }
    
    public var body: some View {
        ZStack{
//            Rectangle()
//                .fill(Color("systemInsetContent"))
//                .cornerRadius(5)
                //.shadow(color: self.style.dropShadowColor, radius: self.dropShadow ? 2 : 0)
            
//            RoundedRectangle(cornerRadius: 20, style: .continuous)
////                .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.backgroundColor : self.style.backgroundColor)
//                .frame(width: .infinity, height: 280, alignment: .center)
//                .shadow(radius: 2)
//                //.offset(x: 0, y:-20)
            
            VStack(alignment: .leading,spacing:-55){
                VStack(alignment:.trailing,spacing:0) {
                    HStack{
                        if(!showValue){
                            VStack {
                                Text("\(self.title)")
                            }.font(.headline)
                            .foregroundColor(Color("systemBlack"))
                            
                                
                        }else{
                            VStack(alignment:.trailing) {
                                HStack {
                                    Text(getLegend(currentValue: self.currentValue))
                                    Text("\(self.currentValue, specifier: self.valueSpecifier)")
                                }
  
                            }.font(.headline)
                            .foregroundColor(Color("systemBlack"))
                        }
                        Spacer()
                        Image(systemName: "chart.pie.fill")
                            .imageScale(.large)
                            .foregroundColor(Color(.systemGray))
                    }
                    
                    VStack {
                        HStack(spacing:2){
                            Image(systemName: "hexagon.fill")
                                .foregroundColor(Color("loginColor"))
                            Text("学习中")
                                .foregroundColor(Color(.systemGray))
                        }
                        HStack(spacing:2){
                            Image(systemName: "hexagon.fill")
                                .foregroundColor(Color("WordLevelsColor"))
                            Text("未学习")
                                .foregroundColor(Color(.systemGray))
                        }
                        HStack(spacing:2){
                            Image(systemName: "hexagon.fill")
                                .foregroundColor(Color("CalendarOnColor"))
                            Text("已掌握")
                                .foregroundColor(Color(.systemGray))
                        }
                    }.font(.caption2)
                }
                HStack {
                    Spacer()
                    PieChartRow(data: data, backgroundColor: self.style.backgroundColor, accentColor: self.style.accentColor, showValue: $showValue, currentValue: $currentValue)
                        .foregroundColor(self.style.accentColor)
                        .frame(width: screenWidth - 150, height: self.formSize.height)
                    Spacer()
                }
//                    .offset(y:self.legend != nil ? 0 : -10)
//                if(self.legend != nil) {
//                    Text(self.legend!)
//                        .font(.headline)
//                        .foregroundColor(self.style.legendTextColor)
//                }
                
            }
        }
        .onReceive(NotificationCenter.Publisher(center: .default, name: UIDevice.orientationDidChangeNotification)) { _ in
            if UIDevice.current.orientation != UIDeviceOrientation(rawValue: 5){
                self.screenWidth = UIScreen.main.bounds.width
            }
          }
    }
    
    func getLegend(currentValue:Double) -> String {
        let index = self.data.firstIndex(of: currentValue) ?? 0
        return legendList[index]
    }
}

#if DEBUG
struct PieChartView_Previews : PreviewProvider {
    static var previews: some View {
        PieChartView(data:[56,78,53], title: "Title", legend: "Legend",form: ChartForm.custom)
    }
}
#endif
