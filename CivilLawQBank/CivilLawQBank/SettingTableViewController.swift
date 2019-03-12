//
//  SettingTableViewController.swift
//  CivilLawQBank
//
//  Created by Mac on 2017. 4. 12..
//  Copyright © 2017년 5712ya. All rights reserved.
//

// TODO: 탭하여 정답보기
// TODO: 스와이프로 다음문제
// TODO: 세로화면 고정

import UIKit

class SettingTableViewController: UITableViewController {

    @IBOutlet weak var questionRandomSwitch: UISwitch! // 문제 섞기
    @IBOutlet weak var answerRandomSwitch: UISwitch!   // 정답 섞기
    @IBOutlet weak var answerShowSwitch: UISwitch!     // 정답 보기
    @IBOutlet weak var questionContinueSwitch: UISwitch! // 이어 보기
    @IBOutlet weak var wrongAnswerRegSwitch: UISwitch! //오답 자동등록
    
    @IBOutlet weak var screenRotationSwitch: UISwitch! // 세로화면 고정
    @IBOutlet weak var swipeMoveSwitch: UISwitch!      // 스와이프로 문제이동
    @IBOutlet weak var fontSizeSegment: UISegmentedControl! //문제 글자크기
    @IBOutlet weak var wrongAnswerVibrateSwitch: UISwitch! //오답 진동알림
    
    @IBOutlet weak var bundleShortVersionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bundleShortVersionLabel.text = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        
        questionRandomSwitch.setOn(userDefautSwitchQuestionRandom, animated: false)
        answerRandomSwitch.setOn(userDefautSwitchAnswerRandom , animated: false)
        answerShowSwitch.setOn(userDefautSwitchAnswerShow, animated: false)
        questionContinueSwitch.setOn(userDefautSwitchQuestionContinue, animated: false)
        wrongAnswerRegSwitch.setOn(userDefautSwitchWrongAnswerReg, animated: false)

        screenRotationSwitch.setOn(userDefautSwitchScreenRotation, animated: false)
        swipeMoveSwitch.setOn(userDefautSwitchSwipeMove, animated: false)
        fontSizeSegment.selectedSegmentIndex = userDefautFontSize
        wrongAnswerVibrateSwitch.setOn(userDefautSwitchWrongAnswerVibrate, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func switchQuestionRandomAction(_ sender: UISwitch) { // 문제 섞기
        userDefautSwitchQuestionRandom = questionRandomSwitch.isOn
        UserDefaults.standard.set(userDefautSwitchQuestionRandom, forKey: questionRandom)
    }
    
    @IBAction func SwitchAnswerRandomAction(_ sender: UISwitch) { // 정답 섞기
        userDefautSwitchAnswerRandom = answerRandomSwitch.isOn
        UserDefaults.standard.set(userDefautSwitchAnswerRandom, forKey: answerRandom)
    }
    
    @IBAction func SwitchAnswerShowAction(_ sender: UISwitch) { // 정답 보기
        userDefautSwitchAnswerShow = answerShowSwitch.isOn
        UserDefaults.standard.set(userDefautSwitchAnswerShow, forKey: answerShow)
    }
    
    @IBAction func switchqQestionContinueAction(_ sender: Any) { // 이어 보기
        userDefautSwitchQuestionContinue = questionContinueSwitch.isOn
        UserDefaults.standard.set(userDefautSwitchQuestionContinue, forKey: questionContinue)
    }
    @IBAction func switchWrongAnswerRegAction(_ sender: Any) { // 오답 자동등록
        userDefautSwitchWrongAnswerReg = wrongAnswerRegSwitch.isOn
        UserDefaults.standard.set(userDefautSwitchWrongAnswerReg, forKey: wrongAnswerReg)
    }
    
    @IBAction func SwitchScreenRotationAction(_ sender: UISwitch) { // 세로화면 고정
        userDefautSwitchScreenRotation = screenRotationSwitch.isOn
        UserDefaults.standard.set(userDefautSwitchScreenRotation, forKey: screenRotation)
        
        if userDefautSwitchScreenRotation { //세로화면 고정의 경우
            AppDelegate.AppUtility.lockOrientation(.portrait) //가로모드 금지
        } else {
            AppDelegate.AppUtility.lockOrientation(.all) //화면회전 허용
        }
    }
    
    @IBAction func SwitchSwipeMoveSwitchAction(_ sender: UISwitch) { // 스와이프로 문제이동
        userDefautSwitchSwipeMove = swipeMoveSwitch.isOn
        UserDefaults.standard.set(userDefautSwitchSwipeMove, forKey: swipeMove)
    }
    
    @IBAction func fontSizeSegmentAction(_ sender: Any) { //문제 글자크기
        userDefautFontSize = fontSizeSegment.selectedSegmentIndex
        UserDefaults.standard.set(userDefautFontSize, forKey: fontSize)
    }
    
    @IBAction func switchWrongAnswerVibrateAction(_ sender: Any) { //오답 진동알림
        userDefautSwitchWrongAnswerVibrate = wrongAnswerVibrateSwitch.isOn
        UserDefaults.standard.set(userDefautSwitchWrongAnswerVibrate, forKey: wrongAnswerVibrate)
    }
    
    @IBAction func clearFavoriteAction(_ sender: UIButton) {
        let ac = UIAlertController(title: "오답 노트 문제가 모두 삭제됩니다. 삭제하시겠습니까?", message: "", preferredStyle: .alert)
        var cancelAction = UIAlertAction()
        cancelAction = UIAlertAction(title: "취소", style: .default, handler: nil )
        ac.addAction(cancelAction)
        var clearAction = UIAlertAction()
        clearAction = UIAlertAction(title: "삭제", style: .destructive, handler: { (ACTION) -> Void in
            guard let dbFavorite = FMDatabase(path: favoritePath) else {
                print("5712 DB Favirote Not Found")
                return
            }
//            print("favoritePath=\(favoritePath)")
            if dbFavorite.open() != true {
                print("5712 DB Open Failed")
                return
            }
            let deleteSQL = "DELETE FROM questionlist"
            guard dbFavorite.executeUpdate(deleteSQL, withArgumentsIn: nil) else {
                print("5712 Error: \(String(describing: dbFavorite.lastErrorMessage()))")
                return
            }
            let acConfirm = UIAlertController(title: "삭제 완료", message: "오답 노트가 초기화 되었습니다.", preferredStyle: .alert)
            acConfirm.addAction(UIAlertAction(title: "확인", style: .default,handler: nil))
            self.present(acConfirm, animated: false, completion: nil)

            dbFavorite.close()
        }
        )
        ac.addAction(clearAction)
        
        self.present(ac, animated: true, completion: nil)
    }
    
    @IBAction func clearProgressAction(_ sender: Any) {
        let ac = UIAlertController(title: "문제풀기 진도가 모두 삭제됩니다. 삭제하시겠습니까?", message: "", preferredStyle: .alert)
        var cancelAction = UIAlertAction()
        cancelAction = UIAlertAction(title: "취소", style: .default, handler: nil )
        ac.addAction(cancelAction)
        var clearAction = UIAlertAction()
        clearAction = UIAlertAction(title: "삭제", style: .destructive, handler: { (ACTION) -> Void in
            
            userDefautQuestionProgress = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
            UserDefaults.standard.set(userDefautQuestionProgress, forKey: questionProgress)

            let acConfirm = UIAlertController(title: "삭제 완료", message: "진도가 초기화 되었습니다.", preferredStyle: .alert)
            acConfirm.addAction(UIAlertAction(title: "확인", style: .default,handler: nil))
            self.present(acConfirm, animated: false, completion: nil)
        }
        )
        ac.addAction(clearAction)
        
        self.present(ac, animated: true, completion: nil)
    }

    @IBAction func writeReviewAction(_ sender: Any) {
        
        if let url = URL(string: "itms-apps://itunes.apple.com/app/id1241179190?action=write-review") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                // Fallback on earlier versions
            }
        }
        
//        if let url = URL(string: "https://itunes.apple.com/us/app/itunes-u/id1241179190?action=write-review") {
//            if #available(iOS 10.0, *) {
//                UIApplication.shared.open(url)
//            } else {
//                // Fallback on earlier versions
//            }
//        }
        
    }
    
}
