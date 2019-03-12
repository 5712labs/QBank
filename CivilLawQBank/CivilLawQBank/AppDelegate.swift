//
//  AppDelegate.swift
//  CivilLawQBank
//
//  Created by Mac on 2017. 3. 30..
//  Copyright © 2017년 5712ya. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
        if UserDefaults.standard.value(forKey: questionRandom) != nil { //문제 섞기
            userDefautSwitchQuestionRandom = UserDefaults.standard.bool(forKey: questionRandom)
        }
        
        if UserDefaults.standard.value(forKey: answerRandom) != nil { // 정답 섞기
            userDefautSwitchAnswerRandom = UserDefaults.standard.bool(forKey: answerRandom)
        }
        
        if UserDefaults.standard.value(forKey: answerShow) != nil { //정답 보기
            userDefautSwitchAnswerShow = UserDefaults.standard.bool(forKey: answerShow)
        }

        if UserDefaults.standard.value(forKey: questionContinue) != nil { // 이어 보기
            userDefautSwitchQuestionContinue = UserDefaults.standard.bool(forKey: questionContinue)
        }
        
        if UserDefaults.standard.value(forKey: wrongAnswerReg) != nil { // 오답 자동등록
            userDefautSwitchWrongAnswerReg = UserDefaults.standard.bool(forKey: wrongAnswerReg)
        }
        
        if UserDefaults.standard.value(forKey: screenRotation) != nil { //세로화면 고정
            userDefautSwitchScreenRotation = UserDefaults.standard.bool(forKey: screenRotation)
        }
        
        if UserDefaults.standard.value(forKey: swipeMove) != nil { //스와이프로 문제이동
            userDefautSwitchSwipeMove = UserDefaults.standard.bool(forKey: swipeMove)
        }

        if UserDefaults.standard.value(forKey: fontSize) != nil { //문제 글자크기
            userDefautFontSize = UserDefaults.standard.integer(forKey: fontSize)
        }

        if UserDefaults.standard.value(forKey: wrongAnswerVibrate) != nil { // 오답 진동알림
            userDefautSwitchWrongAnswerVibrate = UserDefaults.standard.bool(forKey: wrongAnswerVibrate)
        }

        if UserDefaults.standard.value(forKey: questionProgress) != nil { //문제 진도
            userDefautQuestionProgress = UserDefaults.standard.object(forKey: questionProgress) as? [Float] ?? [Float]()
        }

        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: - 가로모드 고정 설정
    var orientationLock = UIInterfaceOrientationMask.all //가로모드 고정을 위한 변수
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }
    
    struct AppUtility {
        static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
            if let delegate = UIApplication.shared.delegate as? AppDelegate {
                delegate.orientationLock = orientation
            }
        }
        
        static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
            self.lockOrientation(orientation)
            UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        }
    }
    
}

