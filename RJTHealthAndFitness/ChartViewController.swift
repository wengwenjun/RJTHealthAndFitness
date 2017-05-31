//
//  ChartViewController.swift
//  RJTHealthAndFitness
//
//  Created by Wenjun Weng on 5/25/17.
//  Copyright © 2017 rjt.compquest. All rights reserved.
//

import UIKit
import CoreData
import SwiftCharts


class ChartViewController: BaseViewController {
    @IBOutlet weak var chartsView: UIView!
    @IBOutlet weak var weeklyLabel: UILabel!
    @IBOutlet weak var monthlyLabel: UILabel!
    fileprivate var monthlyChart: Chart? 
    fileprivate var weeklyChart: Chart?
    var weekResultArray = [Entity]()
    var monthResultArray = [Entity]()
    var currentDate = Date()
    var isCheckingMonths = false
    override func viewDidLoad() {
        super.viewDidLoad()
        monthlyLabel.text = currentDate.MonthDateFormatter()
        loadAllDataWithinMonth()
        loadAllDataWithinWeek()
        for fitness in self.weekResultArray{
            let date = fitness.date! as Date
            print("Fitness Data - \(date.MonthDayDateFormatter()) \(fitness.step ?? "0") \(fitness.calories ?? "0")")
        }
        for fitness in self.monthResultArray{
            let date = fitness.date! as Date
            print("Fitness Data - \(date.MonthDayDateFormatter()) \(fitness.step ?? "0") \(fitness.calories ?? "0")")
        }
        self.monthlyLabel.isHidden = true
        self.loadWeeklyChart()
        //addDummyDataForTheCurrentMonth()
        // Do any additional setup after loading the view.
    }
    @IBAction func lastBtnClicked(_ sender: Any) {
        if isCheckingMonths {
            self.currentDate = (Calendar.current as NSCalendar).date(byAdding: .month, value: -1, to: currentDate, options: [])!
            loadAllDataWithinMonth()
            loadMonthChart()
        }else  {
            self.currentDate = (Calendar.current as NSCalendar).date(byAdding: .day, value: -7, to: currentDate, options: [])!
            loadAllDataWithinWeek()
            loadWeeklyChart()
        }
    }
    @IBAction func nextBtnClicked(_ sender: Any) {
        if isCheckingMonths {
            self.currentDate = (Calendar.current as NSCalendar).date(byAdding: .month, value: 1, to: currentDate, options: [])!
            loadAllDataWithinMonth()
            loadMonthChart()
        }else  {
            self.currentDate = (Calendar.current as NSCalendar).date(byAdding: .day, value: 7, to: currentDate, options: [])!
            loadAllDataWithinWeek()
            loadWeeklyChart()
        }
    }
    @IBAction func segementControl(_ sender: UISegmentedControl) {
        self.currentDate = Date()
        
        if (sender.selectedSegmentIndex == 0) {
            loadWeeklyChart()
            self.monthlyLabel.isHidden = true
            self.weeklyLabel.isHidden = false
            isCheckingMonths = false
            
        }else {
            loadMonthChart()
            self.monthlyLabel.isHidden = false
            self.weeklyLabel.isHidden = true
            isCheckingMonths = true
        }
    }
    
    func loadAllDataWithinMonth() {
        print("Load Fitness Data Based on Month")
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext //scratch pad
        let currentFitnessDataFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Entity")
        
        // Get the current calendar with local time zone
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        
        // Get today's beginning & end
        let dateFrom = calendar.startOfDay(for: currentDate) // eg. 2016-10-10 00:00:00
        let components = calendar.dateComponents([.year, .month],from: dateFrom)
        //components.month! += 1
        let dateTo = calendar.date(from: components)! // eg. 2016-10-11 00:00:00
        // Note: Times are printed in UTC. Depending on where you live it won't print 00:00:00 but it will work with UTC times which can be converted to local time
        
        // Set predicate as date being today's date
        let datePredicate = NSPredicate(format: "(%@ >= date) AND (date > %@)", argumentArray: [dateFrom, dateTo])
        
        //Sort descriptors
        let sectionSortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        
        
        currentFitnessDataFetch.sortDescriptors = sortDescriptors
        currentFitnessDataFetch.predicate = datePredicate
        
        
        for fitness in self.monthResultArray {
            let date : Date = fitness.date! as Date
            print("Fitness Data - ", date.MonthDayDateFormatter(), fitness.step!, fitness.calories!)
        }
        do {
            print("Do Block")
            let fetchedFitnessData = try context.fetch(currentFitnessDataFetch) as! [Entity]
            self.monthResultArray = fetchedFitnessData
            
            
            for fitness in fetchedFitnessData {
                let date : Date = fitness.date! as Date
                print("Fitness Data - ", date.MonthDayDateFormatter(), fitness.step!, fitness.calories!)
            }
        } catch {
            fatalError("Failed to fetch current fitness data: \(error.localizedDescription)")
        }
    }

    func loadAllDataWithinWeek() {
        print("Load Fitness Data Based on Week")
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext //scratch pad
        let currentFitnessDataFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Entity")
        
        // Get the current calendar with local time zone
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        
        // Get today's beginning & end
        let calculatedDate = (Calendar.current as NSCalendar).date(byAdding: .day, value: 1, to: currentDate, options: [])!
        
        let dateFrom = calendar.startOfDay(for: calculatedDate) // eg. 2016-10-10 00:00:00
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute],from: dateFrom)
        components.day! += -7
        let dateTo = calendar.date(from: components)! // eg. 2016-10-11 00:00:00
        // Note: Times are printed in UTC. Depending on where you live it won't print 00:00:00 but it will work with UTC times which can be converted to local time
        
        // Set predicate as date being today's date
        let datePredicate = NSPredicate(format: "(%@ >= date) AND (date >= %@)", argumentArray: [dateFrom, dateTo])
        
        //Sort descriptors
        let sectionSortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        
        currentFitnessDataFetch.sortDescriptors = sortDescriptors
        currentFitnessDataFetch.predicate = datePredicate
        
        do {
            print("Do Block")
            let fetchedFitnessData = try context.fetch(currentFitnessDataFetch) as! [Entity]
            self.weekResultArray = fetchedFitnessData
            print(fetchedFitnessData)
        } catch {
            fatalError("Failed to fetch current fitness data: \(error.localizedDescription)")
        }
    }
    
    
    func loadWeeklyChart() {
        
        guard self.weekResultArray.count > 5 else {
            print("No data to load")
            return
        }
        
        //Set up label
        let firstDayOfTheWeekdate  = (self.weekResultArray.first!.date!) as Date
        let lastDayOfTheWeekdate = (self.weekResultArray.last!.date!) as Date
        
        
        self.weeklyLabel.text = "\(firstDayOfTheWeekdate.MonthDayDateFormatter()) - \(lastDayOfTheWeekdate.MonthDayDateFormatter())"
        
        
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont)
        
        //Map the last 7 days into Core Data
        let daysStrings : [String] = self.weekResultArray.map { (fitnessData) in
            let date = fitnessData.date! as Date
            return date.DayDateFormatter()
        }
        
        var dayArray = [Day]()
        for (index,day) in daysStrings.enumerated() {
            //print(self.weekResultArray[index].step!)
            if Int(self.weekResultArray[index].step!) != nil{
            dayArray.append(Day(name: day, quantity: StepsQuantity(number: Int(self.weekResultArray[index].step!)!)))
            }
        }
        
        //Weekly Chart Points
        let weeklyChartPoints: [ChartPoint] = dayArray.enumerated().map {index, item in
            let xLabelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont, rotation: 45, rotationKeep: .top)
            let x = ChartAxisValueString(item.name, order: index, labelSettings: xLabelSettings)
            let y = ChartAxisValueString(order: item.quantity.number, labelSettings: labelSettings)
            return ChartPoint(x: x, y: y)
        }
        
        let xValues = [ChartAxisValueString("", order: -1)] + weeklyChartPoints.map{$0.x} + [ChartAxisValueString("", order: 7)]
        
        //Monthly
        //let xValues = chartPoints.map{$0.x}
        
        let yValues = ChartAxisValuesStaticGenerator.generateYAxisValuesWithChartPoints(weeklyChartPoints, minSegmentCount: 10, maxSegmentCount: 10000, multiple: 1000, axisValueGenerator: {ChartAxisValueDouble($0, labelSettings: labelSettings)}, addPaddingSegmentIfEdge: false)
        
        let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: "Week Days", settings: labelSettings))
        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: "Steps Count", settings: labelSettings.defaultVertical()))
        
        //let chartFrame = ExamplesDefaults.chartFrame(view.bounds)
        let chartFrame = self.chartsView.frame
        let chartSettings = ExamplesDefaults.chartSettingsWithPanZoom
        
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        
        let (xAxisLayer, yAxisLayer, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)
        
        let lineModel = ChartLineModel(chartPoints: weeklyChartPoints, lineColor: UIColor.lightGray, lineWidth: 5, animDuration: 1, animDelay: 0)
        
        let chartPointsLineLayer = ChartPointsLineLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, lineModels: [lineModel], pathGenerator: CatmullPathGenerator()) // || CubicLinePathGenerator
        
        let settings = ChartGuideLinesDottedLayerSettings(linesColor: UIColor.black, linesWidth: ExamplesDefaults.guidelinesWidth)
        let guidelinesLayer = ChartGuideLinesDottedLayer(xAxisLayer: xAxisLayer, yAxisLayer: yAxisLayer, settings: settings)
        
        let chart = Chart(
            frame: chartFrame,
            innerFrame: innerFrame,
            settings: chartSettings,
            layers: [
                xAxisLayer,
                yAxisLayer,
                guidelinesLayer,
                chartPointsLineLayer
            ]
        )
        
        //Clear All Charts
        self.monthlyChart?.view.removeFromSuperview()
        self.weeklyChart?.view.removeFromSuperview()
        
        self.weeklyChart = chart
        
        //Safe to unrwapped since it's weeklyChart was just initialzied
        self.view.addSubview((self.weeklyChart?.view)!)
    }
    
    func loadMonthChart() {
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont)
        
        guard self.monthResultArray.count > 5 else {
            print("No Month data to load")
            return
        }
        
        let monthDate = (self.monthResultArray.first!.date!) as Date
        //Load month charts
        self.monthlyLabel.text = "\(monthDate.MonthDateFormatter())"
        
        var monthlyChartPoints : [(Int, Int)] = self.monthResultArray.enumerated().map { (index, fitnessData) in
            return (index, Int(fitnessData.step!)!)
        }
        
        monthlyChartPoints.insert((0,0), at: 0)
        
        //Monthly Chart Points
        let chartPoints = monthlyChartPoints.map{ChartPoint(x: ChartAxisValueInt($0.0, labelSettings: labelSettings), y: ChartAxisValueInt($0.1))}
        
        
        let xValues = chartPoints.map{$0.x}
        
        let yValues = ChartAxisValuesStaticGenerator.generateYAxisValuesWithChartPoints(chartPoints, minSegmentCount: 10, maxSegmentCount: 1000, multiple: 2000, axisValueGenerator: {ChartAxisValueDouble($0, labelSettings: labelSettings)}, addPaddingSegmentIfEdge: false)
        
        let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: "Month Day", settings: labelSettings))
        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: "Steps Count", settings: labelSettings.defaultVertical()))
        
        let chartFrame = self.chartsView.frame
        let chartSettings = ExamplesDefaults.chartSettingsWithPanZoom
        
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        
        let (xAxisLayer, yAxisLayer, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)
        
        let lineModel = ChartLineModel(chartPoints: chartPoints, lineColor: UIColor.lightGray, lineWidth: 5, animDuration: 1, animDelay: 0)
        
        let chartPointsLineLayer = ChartPointsLineLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, lineModels: [lineModel], pathGenerator: CatmullPathGenerator())
        
        let settings = ChartGuideLinesDottedLayerSettings(linesColor: UIColor.black, linesWidth: ExamplesDefaults.guidelinesWidth)
        let guidelinesLayer = ChartGuideLinesDottedLayer(xAxisLayer: xAxisLayer, yAxisLayer: yAxisLayer, settings: settings)
        
        let chart = Chart(
            frame: chartFrame,
            innerFrame: innerFrame,
            settings: chartSettings,
            layers: [
                xAxisLayer,
                yAxisLayer,
                guidelinesLayer,
                chartPointsLineLayer
            ]
        )
        
        
        //Clear all charts
        self.weeklyChart?.view.removeFromSuperview()
        self.monthlyChart?.view.removeFromSuperview()
        
        self.monthlyChart = chart
        
        //Month Chart was just initialize so it's safe to force unwrapped
        self.view.addSubview((self.monthlyChart?.view)!)
    }
    override func viewWillAppear(_ animated: Bool) {
        //addDummyDataForTheCurrentMonth()
        super .viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = false
    }
    func addDummyDataForTheCurrentMonth() {
        let currentDate = Date()
        for x in -30...30 {
            let calculatedDate = (Calendar.current as NSCalendar).date(byAdding: .day, value: x, to: currentDate, options: [])!
            initializeDummyFitnessData(dateToAdd: calculatedDate)
        }
    }
    func initializeDummyFitnessData(dateToAdd: Date) {
        
        //Access managedObjectContex
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Entity", in: context)!
        let fitnessData = Entity(entity: entity, insertInto: context)
        //Initialize with random numbers
        let randomSteps = Int(arc4random_uniform(UInt32(10000)))
        
        fitnessData.date = dateToAdd as NSDate
        let randomFitness = Int32(randomSteps)
        fitnessData.step = String(randomFitness)
        let randomCalories = Int32(Double(randomSteps) * 0.04)
        fitnessData.calories = String(randomCalories)
        let randomDistance = Int32(Double(randomSteps) * 0.0004)
        fitnessData.distance = String(randomDistance)
        //Add object to context
        context.insert(fitnessData)
        do {
            try context.save()
        } catch {
            print("Could not save fitness Data")
        }
    }
    private struct StepsQuantity {
        let number: Int
        
        init(number: Int) {
            self.number = number
        }
    }
    
    private struct Day{
        let name: String
        let quantity: StepsQuantity
        
        init(name: String, quantity: StepsQuantity) {
            self.name = name
            self.quantity = quantity
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
