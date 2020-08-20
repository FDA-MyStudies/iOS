//
//  DateHelper.swift
/*
License Agreement for FDA My Studies
Copyright © 2017-2019 Harvard Pilgrim Health Care Institute (HPHCI) and its Contributors. Permission is
hereby granted, free of charge, to any person obtaining a copy of this software and associated
documentation files (the &quot;Software&quot;), to deal in the Software without restriction, including without
limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
Software, and to permit persons to whom the Software is furnished to do so, subject to the following
conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial
portions of the Software.
Funding Source: Food and Drug Administration (“Funding Agency”) effective 18 September 2014 as
Contract no. HHSF22320140030I/HHSF22301006T (the “Prime Contract”).
THE SOFTWARE IS PROVIDED &quot;AS IS&quot;, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT
OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
*/

import Foundation

extension Date {

    func secondsTo(date: Date) -> Int? {
        return Calendar.current.dateComponents([.second], from: self, to: date).second
    }

    func minutesTo(date: Date) -> Int? {
        return Calendar.current.dateComponents([.minute], from: self, to: date).minute
    }

}

enum DateHelper {

    // Ref: 2019-07-17T06:26:05+0000

    static private let dateFormat = "dd/MM/yyyy"  // 17/07/2019
    static private let completeFormat = "dd/MM/yyyy HH:mm"  // 17/07/2019 06:26
    static private let hourFormat = "HH : mm : ss"  // 06 : 26 : 05
    static private let fullDayHourFormat = "HH:mm:ss" // 15:25:25
    static private let shortHourFormat = "hh:mm a z"  // 06:26 AM GMT
    static private let stringDateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"  // 2019-07-17T06:26:05Z
    static private let stringDateRepeatFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"  // 2019-07-17T06:26:05.000+0000
    static private let alertStringDateFormat = "yyyy-MM-dd'T'HH:mm:ss.zzZZ"  // 2019-07-17T06:26:05.GMT+0000
    static private let dateFormatWithDay = "E MMM dd h:mm a"  // Wed Jul 17 06:26 AM
    static private let dateDayFormat = "E MMM dd"  // Wed Jul 17
    static private let monthDateFormat = "MM/dd/yyyy"  // 07/17/2019
    static private let timeFormat = "h:mm a"  // 6:26 AM
    static private let leaveShortDateFormat = "MMM d"  // Jul 17
    static private let yearFormat = "yyyy"  // 2019
    static private let monthNameDateFormat = "dd MMM, yyyy"
    static private let shortDateFormat = "yyyy-MM-dd"
    static private let newLeaveFormat = "MM/dd/yyyy hh:mm a"
    static private let runDateFormat = "yyyy-MM-dd HH:mm:ss Z"
    
    enum DateType { case date, time }

    static var iso8601DateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        let locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = locale
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter
    }

    static func stringFromDate(date: Date, format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let dateString = dateFormatter.string(from: date)

        return dateString
    }

    static func dateFromString(date: String, format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let date = dateFormatter.date(from: date)

        return date
    }
    
    static func formattedRunDateFromString(date: String) -> Date? {
          return dateFromString(date: date, format: runDateFormat)
    }
    
    static func formattedDateRepeatFromString(date: String) -> Date {
        return dateFromString(date: date, format: stringDateRepeatFormat)!
    }
    
    static func formattedLongHourDateFromString(date: String) -> Date {
        return dateFromString(date: date, format: fullDayHourFormat)!
    }

    static func formattedDateFromString(date: String) -> Date {
        return dateFromString(date: date, format: stringDateFormat)!
    }

    static func formattedAlertDateFromString(date: String) -> Date {
        return dateFromString(date: date, format: alertStringDateFormat)!
    }

    static func formattedDateStringFromDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let dateString = dateFormatter.string(from: date)

        return dateString
    }
    
    static func formattedTimerStringFromDate(date: Date) -> String {
        return stringFromDate(date: date, format: alertStringDateFormat)
    }

    static func formattedTimerDateFromString(date: String) -> Date {
        return dateFromString(date: date, format: alertStringDateFormat)!
    }

    static func formattedStringFromDate(date: Date) -> String {
        return stringFromDate(date: date, format: dateFormat)
    }

    static func formattedCompleteStringFromDate(date: Date) -> String {
        return stringFromDate(date: date, format: completeFormat)
    }

    static func formattedDayStringFromDate(date: Date) -> String {
        return stringFromDate(date: date, format: dateFormatWithDay)
    }

    static func formattedDayDateStringFromDate(date: Date) -> String {
        return stringFromDate(date: date, format: dateDayFormat)
    }

    static func formattedStringHourFromDate(date: Date) -> String {
        return stringFromDate(date: date, format: hourFormat)
    }

    static func formattedServiceStringFromDate(date: Date) -> String {
        return stringFromDate(date: date, format: stringDateFormat)
    }

    static func formattedStringShortHourFromDate(date: Date) -> String {
        return stringFromDate(date: date, format: shortHourFormat)
    }

    static func formattedDateStringLeaveFrom(date: Date) -> String {
        return stringFromDate(date: date, format: leaveShortDateFormat)
    }

    static func formattedFullLeaveStringFrom(date: Date) -> String {
        return stringFromDate(date: date, format: newLeaveFormat)
    }

    static func formattedLeaveDateFrom(date: String) -> Date? {
        return dateFromString(date: date, format: newLeaveFormat)
    }

    static func formattedYearStringFrom(date: Date) -> String {
        return stringFromDate(date: date, format: yearFormat)
    }

    static func formattedShortTimeStringFrom(date: Date) -> String {
        return stringFromDate(date: date, format: timeFormat)
    }

    static func formattedShortTimeDateFrom(date: String) -> Date? {
        return dateFromString(date: date, format: timeFormat)
    }

    static func formattedStringFromLeaveDate(date: Date, dateType: DateType) -> String {
        if dateType == .date { return stringFromDate(date: date, format: monthDateFormat) } else {
            return stringFromDate(date: date, format: timeFormat)
        }
    }

    static func formattedStringFromActiveReqDate(date: Date, dateType: DateType) -> String {
        if dateType == .date { return stringFromDate(date: date, format: monthNameDateFormat) } else
        { return stringFromDate(date: date, format: timeFormat) }
    }

    static func formattedDateFromLeaveString(date: String) -> Date? {
        return dateFromString(date: date, format: monthDateFormat)
    }

    static func formattedLeaveDate(date: Date, time: Date) -> Date? {
        let dateStr = stringFromDate(date: date, format: monthDateFormat)
        let timeStr = stringFromDate(date: time, format: shortHourFormat)
        let newDateStr = dateStr + " " + timeStr
        let newDate = self.dateFromString(
            date: newDateStr,
            format: monthDateFormat + " " + shortHourFormat
        )
        return newDate
    }

    static func getTimerDuration(date: Date) -> Int? {

        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents(
            [Calendar.Component.hour, Calendar.Component.minute],
            from: date
        )

        guard let hour = dateComponents.hour, let minute = dateComponents.minute else { return nil }

        let hours = hour * 3600
        let minutes = minute * 60

        let totseconds = hours+minutes

        return totseconds
    }

    static func countdownFormatted(totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        let hours: Int = totalSeconds / 3600
        return String(format: "%02d : %02d : %02d", hours, minutes, seconds)
    }

    static func addCountdownToCurrentDate(countDown: Int) -> Date? {

        var components = DateComponents()
        components.setValue(countDown, for: Calendar.Component.second)

        let date = Date()

        let expirationDate = Calendar.current.date(byAdding: components, to: date)

        return expirationDate
    }

    static func addCountdownToDate(date: Date, countDown: Int) -> Date? {

        var components: DateComponents = DateComponents()
        components.setValue(countDown, for: Calendar.Component.second)
        let expirationDate = Calendar.current.date(byAdding: components, to: date)

        return expirationDate
    }

    static func substractMinutesToDate(date: Date, minutes: Int) -> Date? {

        var components = DateComponents()
        components.setValue(minutes, for: Calendar.Component.minute)
        let expirationDate = Calendar.current.date(byAdding: components, to: date)

        return expirationDate
    }

    static func getQuickTagDuration(date: Date) -> String? {

        let calendar = Calendar.current
        let comp = calendar.dateComponents(
            [Calendar.Component.hour, Calendar.Component.minute, Calendar.Component.second,],
            from: date
        )

        guard let hour = comp.hour, let minute = comp.minute, let sec = comp.second else {
            return nil
        }

        return String(
            format: "%02d hours, %02d minutes, and %02d seconds.",
            arguments: [hour, minute, sec]
        )
    }

    static func updateTime(of firstDate: Date, with secondDate: Date) -> Date? {
        let calendar = Calendar.current
        
        let firstComp = calendar.dateComponents(
            [Calendar.Component.year, Calendar.Component.month, Calendar.Component.day,],
            from: firstDate
        )
        
        let secondComp = calendar.dateComponents(
            [Calendar.Component.hour, Calendar.Component.minute, Calendar.Component.second,],
            from: secondDate
        )

        guard let hour = secondComp.hour, let minute = secondComp.minute,
            let sec = secondComp.second, let year = firstComp.year, let month = firstComp.month,
            let day = firstComp.day else {
            return nil
        }
        return createDate(year: year, month: month, day: day, hour: hour, min: minute, sec: sec)
    }
    
    static func updateTime(of firstDate: Date?, with timeString: String = "00:00:00") -> Date? {
        let calendar = Calendar.current
        
        guard let timeStringDate = dateFromString(date: timeString, format: fullDayHourFormat),
            let firstDate = firstDate else {
            return nil
        }
        
        let firstComp = calendar.dateComponents(
            [Calendar.Component.year, Calendar.Component.month, Calendar.Component.day,],
            from: firstDate
        )
        
        let secondComp = calendar.dateComponents(
            [Calendar.Component.hour, Calendar.Component.minute, Calendar.Component.second,],
            from: timeStringDate
        )

        guard let hour = secondComp.hour, let minute = secondComp.minute,
            let sec = secondComp.second, let year = firstComp.year, let month = firstComp.month,
            let day = firstComp.day else {
            return nil
        }
        return createDate(year: year, month: month, day: day, hour: hour, min: minute, sec: sec)
    }
    
    
    static func getFormattedQuickTagDuration(date: Date) -> String? {

        let calendar = Calendar.current
        let comp = calendar.dateComponents(
            [Calendar.Component.hour, Calendar.Component.minute, Calendar.Component.second,],
            from: date
        )

        guard let hour = comp.hour, let minute = comp.minute, let sec = comp.second else {
            return nil
        }

        return String(format: "%02d : %02d : %02d", arguments: [hour, minute, sec])
    }

    static func createDate(year: Int, month: Int, day: Int, hour: Int = 0, min: Int = 0, sec: Int = 0) -> Date? {
        var c = DateComponents()
        c.year = year
        c.month = month
        c.day = day
        c.hour = hour
        c.minute = min
        c.second = sec
        c.timeZone = TimeZone.current

        return Calendar.current.date(from: c)
    }

    static func secondsToHoursMinutesSeconds(seconds: Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }

    static func secondsdiff(from: Date, to: Date) -> Int? {
        let calendar = Calendar.current
        let component = calendar.dateComponents([.second], from: from, to: to)
        return component.second
    }

    static func daysdiff(from: Date, to: Date) -> String {

        let calendar = Calendar.current
        let interval = calendar.dateComponents([.day, .hour, .minute], from: from, to: to)

        var dateStr = ""

        if let day = interval.day, day > 0 {
            dateStr += day == 1 ? "\(day)" + " " + "day " : "\(day)" + " " + "days "
        }
        if let hour = interval.hour, hour > 0 {
            dateStr += hour == 1 ? "\(hour)" + " " + "hour " : "\(hour)" + " " + "hours "
        }
        if let minute = interval.minute, minute > 0 {
            if dateStr.isEmpty {
                dateStr += minute == 1 ? "\(minute)" + " " + "minute " : "\(minute)" + " "
                    + "minutes "
            }
        }
        return dateStr
    }

    static func formattedRequestString(from: Date) -> String {
        let calendar = Calendar.current

        var dateStr = ""

        if calendar.isDateInToday(from) {
            dateStr = "Today "
        } else if calendar.isDateInTomorrow(from) { dateStr = "Tomorrow " }

        if dateStr.isEmpty { dateStr = formattedDayStringFromDate(date: from) } else {
            dateStr += "\(formattedStringFromLeaveDate(date: from,dateType: .time))"
        }

        return dateStr

    }

}

extension Date {
    public func setTime(hour: Int, min: Int, sec: Int, timeZoneAbbrev: String = "UTC") -> Date? {
        let x: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        let cal = Calendar.current
        var components = cal.dateComponents(x, from: self)

        //components.timeZone = TimeZone(abbreviation: timeZoneAbbrev)
        components.hour = hour
        components.minute = min
        components.second = sec

        return cal.date(from: components)
    }
}
