//
//  PieChartCell.swift
//  ChartView
//
//  Created by András Samu on 2019. 06. 12..
//  Copyright © 2019. András Samu. All rights reserved.
//

import SwiftUI

struct PieSlice: Identifiable {
    var id = UUID()
    var startDeg: Double
    var endDeg: Double
    var value: Double
    var normalizedValue: Double
}

public struct PieChartCell : View {
    @State private var show:Bool = false
    var rect: CGRect
    var radius: CGFloat {
        return min(rect.width, rect.height)/2
    }
    var startDeg: Double
    var endDeg: Double
    var path: Path {
        var path = Path()
        path.addArc(center:rect.mid , radius:self.radius, startAngle: Angle(degrees: self.startDeg), endAngle: Angle(degrees: self.endDeg), clockwise: false)
        path.addLine(to: rect.mid)
        path.closeSubpath()
        return path
    }
    var index: Int
    var backgroundColor:Color
    var accentColor:Color
    @State var showValue = true
    
    //直接把整个data数组传进来，所以没有更新到文字
    var data: [Double]
    var legendList = ["未学习","已掌握","学习中"]
    @State var legendIndex = 0
    
    public var body: some View {
        ZStack {
    
            
            path
                .fill()
                .foregroundColor(self.accentColor)
                .overlay(path.stroke(self.backgroundColor, lineWidth: 2))
                .scaleEffect(self.show ? 1 : 0)
                .animation(Animation.spring().delay(Double(self.index) * 0.04))
                .onAppear(){
                    self.show = true
            }
            
            if(showValue){
                VStack {
                    if(data[legendIndex] >= data.reduce(0,{$0 + $1}) * 0.05 ) {
                    Text("\(legendList[legendIndex])")
                        Text("\(Int(data[legendIndex]))")
                    }
                }.offset(x: textOffsetX(startDeg,endDeg), y: textOffsetY(startDeg,endDeg))
                .font(.callout)
                .foregroundColor(Color(.systemGray5))
                
            }
            
//            VStack {
//                HStack {
//                    Text("x:\(textOffsetX(startDeg,endDeg))")
//                    Text("y:\(textOffsetY(startDeg,endDeg))")
//                }
//                HStack {
//                    Text("s:\(test())")
//                    Text("d:\((startDeg + endDeg)/2)")
//                }
//            }.offset(x: 0, y: -200)
//            //.frame(width: 200, height: 100, alignment: .center)
//
            
        }
//        .onTapGesture(perform: {
//            self.showValue.toggle()
//        })
    }
    
    func textOffsetX(_ startDeg:Double,_ endDeg:Double) -> CGFloat {
        let degree:Angle = Angle(degrees:(startDeg + endDeg)/2)
        return CGFloat(cos(degree.radians)*60)
    }
    
    func textOffsetY(_ startDeg:Double,_ endDeg:Double) -> CGFloat {
        let degree:Angle = Angle(degrees:(startDeg + endDeg)/2)
        return CGFloat(sin(degree.radians)*60)
    }
    
    func test() -> Double {
        let degree:Angle = Angle(degrees: 50)
        return cos(degree.radians)
    }
}

extension CGRect {
    var mid: CGPoint {
        return CGPoint(x:self.midX, y: self.midY)
    }
}

#if DEBUG
struct PieChartCell_Previews : PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            PieChartCell(rect: geometry.frame(in: .local),startDeg: 0.0,endDeg: 180.0, index: 0, backgroundColor: Color(red: 252.0/255.0, green: 236.0/255.0, blue: 234.0/255.0), accentColor: Color(red: 225.0/255.0, green: 97.0/255.0, blue: 76.0/255.0), data: [0,0,0])
            }.frame(width:300, height:300)
        
    }
}
#endif
