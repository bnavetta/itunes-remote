//
//  TypeDecoders.swift
//  iTunesRemote
//
//  Created by Ben Navetta on 8/29/15.
//  Copyright © 2015 Ben Navetta. All rights reserved.
//

import Foundation

import Argo

extension UInt: Decodable {
    public static func decode(j: JSON) -> Decoded<UInt> {
        return Int.decode(j).map({ UInt($0) })
    }
}

// https://github.com/thoughtbot/Argo/blob/9d55345286f44c88a887083e18cef65627934fd6/Playgrounds/iTunes-Example.playground/Contents.swift

let iso8601DateFormatter: NSDateFormatter = {
   let dateFormatter = NSDateFormatter()
    dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
    dateFormatter.calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)
    dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
    return dateFormatter
}()

extension NSDate: Decodable {
    public static func decode(json: JSON) -> Decoded<NSDate> {
        return String.decode(json) >>- { .fromOptional(iso8601DateFormatter.dateFromString($0)) }
    }
}

extension NSURL: Decodable {
    public static func decode(json: JSON) -> Decoded<NSURL> {
        return String.decode(json) >>- { .fromOptional(NSURL(string: $0)) }
    }
}