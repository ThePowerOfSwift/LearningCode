// Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"

//可变和不可变变量
var myVar = 42
myVar = 50
let constant = 42

//类型
let fl:CGFloat = 4;

//强制装换String
let label = "The width is "
let width = 94
let widthLabel = label + String(width)

//字符串中包含数字
let apples = 3
let bananas = 5
let appleSummary = "I have \(apples) apples"
let fruitSummary = "I have \(bananas + apples) fruit"

//数组、字典
var shoppingList = ["catfish","water","tulips","blue paint"]
shoppingList[1] = "salt"

var dict = ["mengxiangjian" : 26 , "guozhenyan" : 25]
dict["mengxiangjian"] = 25
println(dict)

let emptyArr = String[]()
let emptyDict = Dictionary<String,NSInteger>()

//控制流
//for in
var teamScore = 0;
let individualScores = [75,43,103,87,12]
for score in individualScores{
    if score > 50{
        teamScore += 3
    }else{
        teamScore += 1
    }
}
teamScore

//optional value
var optionalString :String? = "mengxiangjian"
optionalString == nil

var greeting = "hello!"
if let name = optionalString{
    greeting = "Hello,\(name)"
}else{
    greeting
}

// swith (不仅仅只能switch int型，支持任何类型。case后不用写break，因为自动break)
let vegetable = "red pepper"
switch vegetable{
    case "celery":
        let vegetableComment = "ok"
    
    case "cucumber","watercress":
        let vegetableComment = "so so"
    
    case let x where x.hasSuffix("pepper"):
        let vegetableComment = "good"
    
    default:
        let vegetableComment = "no"
}

// for in 
let numArr = [34,54,64,23,66,88]
var largest = 0
for num in numArr{
    if largest < num{
        largest = num
    }
}
largest

let numDict = [
    "my" : [23,63,31,3,5,31],
    "your" : [903,394,32,32],
    "her" : [3,53,23,66,45],
]

for (key,value) in numDict{
    for num in value{
        if largest < num{
            largest = num
        }
    }
}
largest



