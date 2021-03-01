//
//  CSVTool.swift
//  MyVocabularyBook
//
//  Created by YES on 2020/11/24.
//

import Foundation

class CSVTools {
    func csv(data: String) -> [[String]] {
        var result: [[String]] = []
        let rows = data.components(separatedBy: "\n")
        for row in rows {
            let columns = row.components(separatedBy: "\",\"")
            result.append(columns)
        }
        return result
    }
    
    
    func readDataFromCSV(fileName:String, fileType: String)-> String!{
        guard let filepath = Bundle.main.path(forResource: fileName, ofType: fileType)
            else {
                return nil
        }
        do {
            var contents = try String(contentsOfFile: filepath, encoding: .utf8)
            contents = cleanRows(file: contents)
            return contents
        } catch {
            print("File Read Error for file \(filepath)")
            return nil
        }
    }

    func cleanRows(file:String)->String{
        var cleanFile = file

        //初始化正则工具类
//        let pattern = "\"(.*?)(,)(.*?)\""
//        var regex = try! Regex(pattern)
//        regex = try! Regex(pattern)
        //解析的两个引号内含有逗号（多个）
        
        cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
        //cleanFile = regex.replacingMatches(in: cleanFile, with: "$1$2$3")
        return cleanFile
    }

}
