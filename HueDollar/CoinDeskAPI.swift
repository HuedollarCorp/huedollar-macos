//
//  CoinDeskAPI.swift
//  HueDollar
//
//  Created by Alan Sikora on 17/04/17.
//  Copyright © 2017 br.com.hue. All rights reserved.
//

import Foundation

class CoinDeskAPI {
    let BASE_URL = "https://api.coindesk.com/v1"
    
    func fetchCurrency(_ currencyCode: String, success: @escaping (Currency) -> Void) {
        let session = URLSession.shared
        let url = URL(string: "\(BASE_URL)/bpi/currentprice.json")
        let task = session.dataTask(with: url!) { data, response, err in
            // first check for a hard error
            if let error = err {
                NSLog("Bitcoin API error: \(error)")
            }
            
            // then check the response code
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200: // all good!
                    if let currency = self.currencyFromJSONData(data!, currencyCode) {
                        success(currency)
                    }
                case 401: // unauthorized
                    NSLog("CoinDesk API returned an 'unauthorized' response. Did you set your API key?")
                default:
                    NSLog("CoinDesk API returned response: %d %@", httpResponse.statusCode, HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))
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
        
        var bpiDict = json["bpi"] as! JSONDict
        var usdDict = bpiDict["USD"] as! JSONDict
        
        var timeDict = json["time"] as! JSONDict
  
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let localDate : Date = dateFormatter.date(from: timeDict["updatedISO"] as! String)!
        
        dateFormatter.locale = Locale(identifier: "pt_BR")
        dateFormatter.timeStyle = DateFormatter.Style.short
        dateFormatter.dateStyle = DateFormatter.Style.short
        let localDateString = dateFormatter.string(from: localDate)
        
        let currency = Currency(
            currency: currencyCode,
            symbol: "฿",
            quote: usdDict["rate_float"] as! Float,
            when: localDateString
        )
        
        return currency
    }
}

