//
//  CurrencyLayer.swift
//  HueDollar
//
//  Created by Alan Sikora on 17/04/17.
//  Copyright © 2017 br.com.hue. All rights reserved.
//

import Foundation

class DollarAPI {
    let BASE_URL = "http://api.promasters.net.br/cotacao/v1/valores"
    
    func fetchCurrency(_ currencyCode: String, success: @escaping (Currency) -> Void) {
        let session = URLSession.shared
        let url = URL(string: "\(BASE_URL)?alt=json&moedas=\(currencyCode)")
        let task = session.dataTask(with: url!) { data, response, err in
            // first check for a hard error
            if let error = err {
                NSLog("Currency API error: \(error)")
            }
            
            // then check the response code
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200: // all good!
                    if let currency = self.currencyFromJSONData(data!, currencyCode) {
                        success(currency)
                    }
                case 401: // unauthorized
                    NSLog("Currency API returned an 'unauthorized' response. Did you set your API key?")
                default:
                    NSLog("Currency API returned response: %d %@", httpResponse.statusCode, HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))
                }
            }
        }
        task.resume()
    }
    
    func currencyFromJSONData(_ data: Data,_ currencyCode: String) -> Currency? {
        typealias JSONDict = [String:AnyObject]
        let json : JSONDict
        
        do {
            json = try JSONSerialization.jsonObject(with: data, options: []) as! JSONDict
        } catch {
            NSLog("JSON parsing failed: \(error)")
            return nil
        }
        
        var valuesDict = json["valores"] as! JSONDict
        var currencyDict = valuesDict[currencyCode] as! JSONDict
        
        let timestamp = NSDate(timeIntervalSince1970: currencyDict["ultima_consulta"] as! Double)
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "pt_BR")
        dateFormatter.timeStyle = DateFormatter.Style.short
        dateFormatter.dateStyle = DateFormatter.Style.short
        let localDate = dateFormatter.string(from: timestamp as Date)
        
        let currency = Currency(
            currency: currencyCode,
            symbol: "$",
            quote: currencyDict["valor"] as! Float,
            when: localDate
        )
        
        return currency
    }
}
