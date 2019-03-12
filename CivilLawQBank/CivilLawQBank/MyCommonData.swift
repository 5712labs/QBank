//
//  MyCommonData.swift
//  CivilLawQBank
//
//  Created by Mac on 2017. 4. 2..
//  Copyright © 2017년 5712ya. All rights reserved.
//

import UIKit

var favoritePath = String() // 북마크 문제 파일경로
var questionPath = String() // 학습용 문제 파일경로
var chapterList: ChapterList = ChapterList()  //
var qnumberMaxTotal: Int = 0 //총 문제수

let questionRandom: String = "questionRandom"
let answerRandom: String = "answerRandom"
let answerShow: String = "answerShow"
let questionContinue: String = "questionContinue"
let wrongAnswerReg: String = "wrongAnswerReg"

let screenRotation: String = "screenRotation"
let swipeMove: String = "swipeMove"
let fontSize: String = "fontSize"
let wrongAnswerVibrate: String = "wrongAnswerVibrate"

let questionProgress: String = "questionProgress"

var userDefautSwitchQuestionRandom: Bool = false  // 문제 섞기
var userDefautSwitchAnswerRandom: Bool = false    // 정답 섞기
var userDefautSwitchAnswerShow: Bool = false      // 정답 보기
var userDefautSwitchQuestionContinue: Bool = true // 이어 보기
var userDefautSwitchWrongAnswerReg: Bool = true // 오답 자동등록

var userDefautSwitchScreenRotation: Bool = false    // 세로화면 고정
var userDefautSwitchSwipeMove: Bool = true          // 스와이프로 문제이동
var userDefautFontSize: Int = 1                     // 문제 글자크기
var userDefautSwitchWrongAnswerVibrate: Bool = false // 오답 진동알림

var userDefautQuestionProgress: [Float] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] // 문제 진도

//navigation color = 1995ce
//let main_Color: String = "#E96E35" //#colorLiteral(red: 0.9137254902, green: 0.431372549, blue: 0.2078431373, alpha: 1)
//let text_Color: String = "#89714C" //#colorLiteral(red: 0.537254902, green: 0.4431372549, blue: 0.2980392157, alpha: 1)
//let back_Color: String = "#F5F4F1" //#colorLiteral(red: 0.9607843137, green: 0.9568627451, blue: 0.9450980392, alpha: 1)
////let back_Webview_Color: String = "#F0EDE6" //#colorLiteral(red: 0.9607843137, green: 0.9568627451, blue: 0.9450980392, alpha: 1)
//let mark_Color: String = "#EEA01B" //#colorLiteral(red: 0.9333333333, green: 0.6274509804, blue: 0.1058823529, alpha: 1)
//let gray_Color: String = "#808080" //#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
//let white_Color: String = "FFFFFF"

class ChapterItems {
    var examtype: String = ""
    var subject: String = ""
    var chapter: String = ""
    var chapterText: String = ""
    var qnumberMax: Int = 0
}

class ChapterList {
    var chapterItems = [ChapterItems]()
}

var myQuestionList: MyQuestionList = MyQuestionList()

class MyQuestionItems {
    var examtype: String = ""
    var subject: String = ""
    var chapter: Int = 0
    var qnumber: Int = 0
}

class MyQuestionList {
    var myQuestionItems = [MyQuestionItems]()
}
