//
//  CVCalendarMonthFlowContentViewController.swift
//  CVCalendar Demo
//
//  Created by Eugene Mozharovsky on 2/23/16.
//  Copyright © 2016 GameApp. All rights reserved.
//

import UIKit

public protocol CVCalendarSizeCalculator {
    func calculatedSize() -> CGSize
}

public protocol CVCalendarMonthFlowContentViewControllerModel: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    var dates: [NSDate] { get set }
    var calculator: CVCalendarSizeCalculator? { get set }
}


public final class CVCalendarMonthFlowContentCell: UICollectionViewCell {
    public var monthView: CVCalendarMonthView!
}


public final class CVCalendarMonthFlowContentHeaderView: UICollectionReusableView {
    public var label: UILabel!
    
    
    public override func didMoveToSuperview() {
        removeAllSubviews()
        
        label = UILabel(frame: bounds)
        label.textAlignment = .Center
        addSubview(label)
        
        label
            .constraint(.Leading, relation: .Equal, toView: self, constant: 0)
            .constraint(.Trailing, relation: .Equal, toView: self, constant: 0)
            .constraint(.Bottom, relation: .Equal, toView: self, constant: 0)
            .constraint(.Top, relation: .Equal, toView: self, constant: 0)
    }
}

public final class CVCalendarMonthFlowContentFooterView: UICollectionReusableView {
    
}

public final class CVCalendarMonthFlowContentViewControllerDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    public weak var controller: CVCalendarMonthFlowContentViewController!
    
    public var count: Int {
        return self.dates.count
    }
    
    public var dates: [NSDate] = []
    public var monthViews: [NSIndexPath : CVCalendarMonthView] = [:]
    
    public func getMonth(date: NSDate) -> MonthView {
        let monthView = MonthView(calendarView: controller.calendarView, date: date)
        return monthView
    }
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return count
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! CVCalendarMonthFlowContentCell
        
        //print("MonthViews \(monthViews.count)")
        //print("Making a Cell, monthView \(cell.monthView)")
        
        
        
        if let monthView = cell.monthView {
            print("WITH A CELL")
            
            dispatch_async(dispatch_get_main_queue()) {
                let date = self.dates[indexPath.section]
                monthView.reloadWithDate(date)
            }
            
            

        } else {
            print("WITH OUT!!! A CELL")
            //print("IndexPath = \(indexPath.section)")
            
            let view: MonthView
            if let monthView = monthViews[indexPath] {
                view = monthView
            } else {
                view = getMonth(self.dates[indexPath.section])
            }
            
            
            view.userInteractionEnabled = true
            view.center = cell.bounds.mid
            view.frame = cell.bounds
            
            cell.monthView = view
            
            cell.addSubview(view)
            
                    view.translatesAutoresizingMaskIntoConstraints = false
                    view
                        .constraint(.Leading, relation: .Equal, toView: cell, constant: 0)
                        .constraint(.Trailing, relation: .Equal, toView: cell, constant: 0)
                        .constraint(.Bottom, relation: .Equal, toView: cell, constant: 0)
                        .constraint(.Top, relation: .Equal, toView: cell, constant: 0)
        }


//        let view: MonthView
//        if let monthView = monthViews[indexPath] {
//            view = monthView
//        } else {
//            fatalError("Yes")
//        }
//        
//        
//        view.userInteractionEnabled = true
//        view.center = cell.bounds.mid
//        view.frame = cell.bounds
//        
//        //
//        
//        //cell.addSubview(view)
//        
//        cell.monthView = view
//        cell.addSubview(view)
//
//        monthView.translatesAutoresizingMaskIntoConstraints = false
//        monthView
//            .constraint(.Leading, relation: .Equal, toView: cell, constant: 0)
//            .constraint(.Trailing, relation: .Equal, toView: cell, constant: 0)
//            .constraint(.Bottom, relation: .Equal, toView: cell, constant: 0)
//            .constraint(.Top, relation: .Equal, toView: cell, constant: 0)
//        
//        

        
        return cell
    }
    
    public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        guard indexPath.section < dates.count else {
            return .zero
        }
        
        //print("MonthView size = \(controller.calendarView.sizeManager.monthViewSize(dates[indexPath.section]))")

        return controller.calendarView.sizeManager.monthViewSize(dates[indexPath.section])
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    public func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        let header: UICollectionReusableView
        
        if kind == UICollectionElementKindSectionHeader {
            let _header = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView", forIndexPath: indexPath) as! CVCalendarMonthFlowContentHeaderView
            guard indexPath.section < dates.count else {
                return _header
            }
            
            _header.label.text = CVDate(date: dates[indexPath.section]).globalDescription
            _header.label.textColor = UIColor.whiteColor()
            header = _header
        } else {
            header = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionFooter, withReuseIdentifier: "FooterView", forIndexPath: indexPath) as! CVCalendarMonthFlowContentFooterView
            header.hidden = true
        }

        
        return header
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 30)
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 30)
    }
    
}

public final class CVCalendarMonthFlowContentViewControllerDelegate: NSObject, UICollectionViewDelegate {
    
}

public func >(lhs: CGSize, rhs: CGSize) -> Bool {
    return lhs.width > rhs.width && lhs.height > rhs.height
}

public final class CVCalendarMonthFlowContentViewController: CVCalendarContentViewControllerImpl<UICollectionView> {
    
    public var startDate: NSDate = NSDate().year == 2007
    public var endDate: NSDate = NSDate().year + 1
    
    private let dataSource = CVCalendarMonthFlowContentViewControllerDataSource()
    private let delegate = CVCalendarMonthFlowContentViewControllerDelegate()
    
    private var presentedMonthView: MonthView!
    
    public override init(calendarView: CVCalendarView, frame: CGRect) {
        super.init(calendarView: calendarView, frame: frame)
        
        presentedMonthView = MonthView(calendarView: calendarView, date: NSDate())
        presentedMonthView.updateAppearance(contentView.bounds)
        initialLoad(NSDate())
        
        setup()
        loadMonthData()
    }
    
    public init(calendarView: CalendarView, frame: CGRect, presentedDate: NSDate) {
        super.init(calendarView: calendarView, frame: frame)
        
        presentedMonthView = MonthView(calendarView: calendarView, date: presentedDate)
        presentedMonthView.updateAppearance(contentView.bounds)
        initialLoad(presentedDate)
        
        setup()
        loadMonthData()
    }
    
    public func maxSize() -> CGSize {
        var max: CGSize = .zero
        
        for monthView in dataSource.monthViews.values {
            monthView.mapDayViews { dayView in
                if let size = self.calendarView.delegate?.complementaryView?(onDayView: dayView).frame.size where size > max {
                    max = size
                }
            }
        }
        
        print("MAX = \(max)")
        
        return max
    }
    
    private func initialLoad(date: NSDate) {
        presentedMonthView.mapDayViews { dayView in
            if self.calendarView.shouldAutoSelectDayOnMonthChange && self.matchedDays(dayView.date, Date(date: date)) {
                self.calendarView.coordinator.flush()
                self.calendarView.touchController.receiveTouchOnDayView(dayView)
                dayView.selectionView?.removeFromSuperview()
            }
        }
        
        calendarView.presentedDate = CVDate(date: presentedMonthView.date)
    }
    
    private func loadMonthData() {
        let leftRange = (NSDate().year.value() - startDate.year.value())
        let leftCount = (leftRange == 0 ? 1 : leftRange) * 12
        
        let rightRange = endDate.year.value() - NSDate().year.value()
        let rightCount = (rightRange == 0 ? 1 : rightRange) * 12
        

        
        // Main data
        let today = NSDate()
        let dates = (1..<leftCount).map { self.startDate.month + $0 } + [today] + (1..<rightCount).map { today.month + $0 }
        dataSource.dates = dates
        
        
        
        // Prepare initially loaded MonthViews
        
        let todayIndex = NSIndexPath(forRow: 0, inSection: dataSource.count - rightCount)
        let prevIndex = NSIndexPath(forRow: 0, inSection: dataSource.count - rightCount - 1)
        let nextIndex = NSIndexPath(forRow: 0, inSection: dataSource.count - rightCount + 1)
        
    
        var i = 0
        for _ in 0..<dates.count {
            dataSource.monthViews[NSIndexPath(forRow: 0, inSection: i)] = MonthView(calendarView: calendarView, date: dates[i++])
        }
        
//        dataSource.monthViews = [
//            prevIndex : MonthView(calendarView: calendarView, date: NSDate().month - 1),
//            todayIndex : MonthView(calendarView: calendarView, date: NSDate()),
//            nextIndex : MonthView(calendarView: calendarView, date: NSDate().month + 1)
//        ]
        
        print("[Loaded] section = \(prevIndex.section)")
        print("[Loaded] section = \(todayIndex.section)")
        print("[Loaded] section = \(nextIndex.section)")
    }
    
    private func setup() {
        dataSource.controller = self
        
        //contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.userInteractionEnabled = true
        contentView.alwaysBounceVertical = true
        contentView.backgroundColor = UIColor.lightGrayColor()
        contentView.showsVerticalScrollIndicator = false
        contentView.dataSource = dataSource
        contentView.delegate = dataSource
        contentView.registerClass(CVCalendarMonthFlowContentCell.self, forCellWithReuseIdentifier: "Cell")
        contentView.registerClass(CVCalendarMonthFlowContentHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView")
        contentView.registerClass(CVCalendarMonthFlowContentFooterView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "FooterView")
        
        if #available(iOS 9.0, *) {
            (contentView.collectionViewLayout as! UICollectionViewFlowLayout).sectionHeadersPinToVisibleBounds = true
            (contentView.collectionViewLayout as! UICollectionViewFlowLayout).sectionFootersPinToVisibleBounds = true
        } else {
            // Fallback on earlier versions
        }
        
        if let superview = contentView.superview {
            addConstraints(superview)
        }
    }
    
    private func addConstraints(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false 
        view.addConstraints([
            NSLayoutConstraint(item: contentView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: contentView, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: contentView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: contentView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0)
        ])
    }
    
    public func updateFrames(rect: CGRect) {
        super.updateFrames(rect)
        print("Update frames")
        
//        for (_, monthView) in dataSource.monthViews {
//            monthView.updateAppearance(rect != .zero ? rect : contentView.bounds)
//        }
        
        let rightRange = endDate.year.value() - NSDate().year.value()
        let rightCount = (rightRange == 0 ? 1 : rightRange) * 12
        let todayIndex = NSIndexPath(forRow: 0, inSection: dataSource.count - rightCount)
        
        contentView.performBatchUpdates(
            {
                self.contentView.scrollToItemAtIndexPath(todayIndex, atScrollPosition: .Top, animated: false)
                self.contentView.reloadData()
            },
            
            completion: { _ in
                self.contentView.contentOffset.y -= 30
            }
        )

    }
    
}


// MARK: - Month management

extension CVCalendarMonthFlowContentViewController {
    public func getFollowingMonth(date: NSDate) -> MonthView {
        let newDate = (date.day == 1).month + 1
        let frame = contentView.bounds
        let monthView = MonthView(calendarView: calendarView, date: newDate)
        
        monthView.updateAppearance(frame)
        
        return monthView
    }
    
    public func getPreviousMonth(date: NSDate) -> MonthView {
        let newDate = (date.day == 1).month - 1
        let frame = contentView.bounds
        let monthView = MonthView(calendarView: calendarView, date: newDate)
        
        monthView.updateAppearance(frame)
        
        return monthView
    }
    
    public func getMonth(date: NSDate) -> MonthView {
        let frame = contentView.bounds
        let monthView = MonthView(calendarView: calendarView, date: date)
        
        monthView.updateAppearance(frame)
        
        return monthView
    }
}
