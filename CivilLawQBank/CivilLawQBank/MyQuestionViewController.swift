//
//  MyQuestionViewController.swift
//  CivilLawQBank
//
//  Created by Mac on 2017. 3. 31..
//  Copyright © 2017년 5712ya. All rights reserved.
//
//// TODO: - 투두
//// FIXME: 픽스미
//// MARK: - UI버튼 선언

import UIKit

class MyQuestionViewController: UIViewController, UIGestureRecognizerDelegate, UIWebViewDelegate {
    
    // MARK: - UI버튼 선언
    @IBOutlet weak var myWebView: UIWebView!
    @IBOutlet weak var myPreviousButton: UIButton!
    @IBOutlet weak var myNextButton: UIButton!
    @IBOutlet weak var myExplainButton: UIButton!
    @IBOutlet weak var myFavoriteButton: UIButton!
    @IBOutlet weak var CWMessageTextField: UITextField!
    
    // MARK: 내부 변수 선언
    var dbPath: String? //sqlite 파일 주소
    
    var examtype: String = ""    //시헝유형
    var subject: String = ""     //과목명
    var chapterNum: Int = 0      //단원
    var questionNum: Int = 0     //문제번호
    
    var chapterName: String = ""        //단원명
    var content: String = ""            //문제내용
    var explainContentHTML: String = "" //해설
    
    var qnumberArray = [String()] //문제번호 리스트
    
    var questionArray = Array<Int>()
    var questionArrays = Array<Array<Int>>()
    
    var answerArray = Array<String>()
    var answerArrays = Array<Array<String>>()
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let preDx = touches.first?.previousLocation(in: self.view).x else {
//            return
//        }
//        print("touchesBegan \(preDx)")
//    }
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//    }
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print("move")
//        return
//    }
    
    // MARK: - 최초 실행
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tap.delegate = self
        tap.numberOfTapsRequired = 2
        tap.numberOfTouchesRequired = 1
        myWebView.isUserInteractionEnabled = true
        myWebView.addGestureRecognizer(tap)
        
        // 웹뷰 좌우 스와이프로 이전/다음문제 보여주기
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
//        swipeRight.delaysTouchesBegan = true
        myWebView.addGestureRecognizer(swipeRight)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        myWebView.addGestureRecognizer(swipeLeft)
        
        setButtonDesign() // 하단 툴바 둥근 모양 버튼
        
        CWMessageTextField.layer.cornerRadius = 10 //메세지 출력 텍스트필드
        CWMessageTextField.alpha = 0
        
        getQuestionList() // 챕터별 문제번호 리스트 가져오기
        if questionArrays.count == 0 {
            CWMessageShow(text: "등록된 문제가 없습니다.")
        } else {
            loadData() // 문제 화면에 출력하기
        }
    }
    
    override func viewDidLayoutSubviews() {
        myWebView.reloadInputViews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: 문제 리스트 추출
    func getQuestionList() {
        guard let db = FMDatabase(path: dbPath) else {
            print("5712 DB Not Found")
            return
        }
        
        if db.open() {
            var selectSQL: String = ""
            selectSQL = "SELECT chapter, qnumber FROM questionlist WHERE examtype = '\(examtype)' AND subject = '\(subject)' AND chapter = \(chapterNum) AND anumber = 0"
            if chapterNum == 0 { //무작위 문제풀이 전체검색
                selectSQL = selectSQL.replacingOccurrences(of: "chapter = \(chapterNum) AND", with: "")
            }
            guard let resultChapter = db.executeQuery(selectSQL, withArgumentsIn: nil) else {
                print("5712 Error: \(String(describing: db.lastErrorMessage()))")
                return
            }
            
            questionArrays.removeAll()
            
            while resultChapter.next() {
                guard let chapterValue = resultChapter.string(forColumn: "chapter") else { return }
                questionArray.append(Int(chapterValue)!)
                guard let qnumberValue = resultChapter.string(forColumn: "qnumber") else { return }
                questionArray.append(Int(qnumberValue)!)
                questionArrays.append(questionArray)
                questionArray.removeAll()
            }
            
            if chapterNum == 0 || //무작위 문제풀이 배열랜덤 섞기
               userDefautSwitchQuestionRandom { //문제 섞기 모드 일 경우
                var questionArraysTemp = Array<Array<Int>>()
                questionArraysTemp.removeAll()
                var lineIndex = 0
                var randomIndex = 0
                
                let endIndex = questionArrays.count
                while lineIndex < endIndex {
                    randomIndex = Int(arc4random_uniform(UInt32(questionArrays.count)))
                    questionArraysTemp.append(questionArrays[randomIndex])
                    questionArrays.remove(at: randomIndex)
                    lineIndex += 1
                }
                questionArrays = questionArraysTemp
                questionArraysTemp.removeAll()
            }
        }
    }
    
    func loadData() {
        guard let db = FMDatabase(path: dbPath) else {
            print("5712 DB Not Found")
            return
        }
        
        if db.open() {
            
            var selectSQL: String = ""
            content = ""
            explainContentHTML = ""
            
            selectSQL = "SELECT * FROM questionlist WHERE examtype = '\(examtype)' AND subject = '\(subject)' AND chapter = \(questionArrays[questionNum][0]) AND qnumber = \(questionArrays[questionNum][1])"
            guard let result = db.executeQuery(selectSQL, withArgumentsIn: nil) else {
                print("5712 Error: \(String(describing: db.lastErrorMessage()))")
                return
            }
            
            var contentHTML: String = ""
            answerArrays.removeAll()
            while result.next() {
                answerArray.removeAll()
                guard let anumber = result.string(forColumn: "anumber") else { return }
                guard let correct = result.string(forColumn: "correct") else { return }
                let content = (result.string(forColumn: "content"))!
                
                if anumber == "" {
                    continue
                } else if anumber == "0" {
                    contentHTML = "<tr><td valign = 'top' width = '1'><b>Q.</b></td><td><b>\(String(describing: content))</b><br><br></td></tr>"
                } else if anumber == "1" || anumber == "2" || anumber == "3" || anumber == "4" || anumber == "5" {
//                    answerArray.append(String(correct)!)
//                    answerArray.append(String(content)!)
                    
                    // FIXME: 문법확인
                    answerArray.append(correct)
                    answerArray.append(content)
                    
                    answerArrays.append(answerArray)
                    answerArray.removeAll()
                } else {
                    explainContentHTML = explainContentHTML +
                    "<tr><td colspan = '2'><font color=red>\(String(describing: content))<br></b></td></tr>"
                }
            }
            
            if userDefautSwitchAnswerRandom { //정답 섞기 모드 일 경우
                var answerArraysTemp = Array<Array<String>>()
                answerArraysTemp.removeAll()
                var lineIndex = 0
                var randomIndex = 0
                
                let endIndex = answerArrays.count
                while lineIndex < endIndex {
                    randomIndex = Int(arc4random_uniform(UInt32(answerArrays.count)))
                    answerArraysTemp.append(answerArrays[randomIndex])
                    answerArrays.remove(at: randomIndex)
                    lineIndex += 1
                }
                answerArrays = answerArraysTemp
                answerArraysTemp.removeAll()
            }
            
            
            var answerNumberText: String = "①"
            for (index, answer) in answerArrays.enumerated() {
                
                contentHTML = contentHTML + "<tr><td valign = 'top'>"
                
                if answer[0] == "Y" {
                    if userDefautSwitchAnswerShow { //정답 보기 모드의 경우
                        contentHTML = contentHTML + "<font color=red>"
                    } else {
                        contentHTML = contentHTML + "<font color=>"
                    }
                }
                
                if index == 0 {
                    answerNumberText = "①</td><td>"
                } else if index == 1 {
                    answerNumberText = "②</td><td>"
                } else if index == 2 {
                    answerNumberText = "③</td><td>"
                } else if index == 3 {
                    answerNumberText = "④</td><td>"
                } else if index == 4 {
                    answerNumberText = "⑤</td><td>"
                }
                
                if answer[0] == "Y" {
                    if userDefautSwitchAnswerShow { //정답 보기 모드의 경우
                        answerNumberText = answerNumberText + "<font color=red>"
                    } else {
                        answerNumberText = answerNumberText + "<font color=>"
                    }
                }
                contentHTML = contentHTML + "\(answerNumberText) \(answer[1])</font><br>"
            }
            
            if userDefautSwitchAnswerShow { //정답 보기 모드의 경우
                contentHTML = contentHTML + "<br><br>" + explainContentHTML + "</font>"
            }
            
            var styleFontSize: String = "13pt"
            switch userDefautFontSize {
            case 0:
                styleFontSize = "11pt"
            case 1:
                styleFontSize = "13pt"
            case 2:
                styleFontSize = "15pt"
            default:
                return;
            }
            
            let headerHTML = "<html><body><br><table width = '100%' border = '0' align = 'center' style='font-size:\(styleFontSize); color:#5B4B33; letter-spacing:0px; line-height:160%;'>"
            let footerHTML = "</table><br><br></body></html>"
            content = headerHTML + contentHTML + footerHTML
            myWebView.loadHTMLString(content, baseURL: nil)
            
            myWebView.alpha = 0
            delay(delay: 0.2, closure: {
                UIView.animate(withDuration: 0.2, animations: {
                    self.myWebView.alpha = 1
                })
            })
            
            if chapterNum != 0 {
                navigationItem.title = "\(chapterName) (\(questionNum+1) / \(questionArrays.endIndex))"
            } else {
                navigationItem.title = "무작위 문제풀기 (\(questionNum+1) / \(questionArrays.endIndex))"
            }
            
            if questionNum == 0 {
//                myPreviousButton.setTitleColor(UIColor.gray, for: .normal)
//                myPreviousButton.layer.borderColor = UIColor.gray.cgColor
                myPreviousButton.alpha = 0.3
            } else {
//                myPreviousButton.setTitleColor(UIColor.white, for: .normal)
//                myPreviousButton.layer.borderColor = UIColor.white.cgColor
                myPreviousButton.alpha = 1
            }
            
            if questionNum+1 == questionArrays.endIndex {
//                myNextButton.setTitleColor(UIColor.gray, for: .normal)
//                myNextButton.layer.borderColor = UIColor.gray.cgColor
                myNextButton.alpha = 0.3
            } else {
//                myNextButton.setTitleColor(UIColor.white, for: .normal)
//                myNextButton.layer.borderColor = UIColor.white.cgColor
                myNextButton.alpha = 1
            }
            
            let checkRedCharacter = content.range(of: "<font color=red>")
            if checkRedCharacter != nil {
//                myExplainButton.setTitleColor(UIColor.gray, for: .normal)
//                myExplainButton.layer.borderColor = UIColor.gray.cgColor
                myExplainButton.alpha = 0.3
            } else {
//                myExplainButton.setTitleColor(UIColor.white, for: .normal)
//                myExplainButton.layer.borderColor = UIColor.white.cgColor
                myExplainButton.alpha = 1
            }
            
            _ = checkFavorite() //북마크 여부 확인 후 버튼 색상 설정
            
        }
    }
    
    //MARK: 북마크 여부 확인 후 버튼 색상 설정
    func checkFavorite() -> Bool { //북마크 여부 확인 후 버튼 색상 설정
        
        guard let dbFavorite = FMDatabase(path: favoritePath) else {
            print("5712 DB Favirote Not Found")
            return false
        }
        if dbFavorite.open() != true {
            print("5712 DB Favirote Open Failed")
            return false
        }
       
        let selectSQL = "SELECT DISTINCT 1 FROM questionlist WHERE examtype = '\(examtype)' AND subject = '\(subject)' AND chapter = \(questionArrays[questionNum][0]) AND qnumber = \(questionArrays[questionNum][1])"
        guard let result = dbFavorite.executeQuery(selectSQL, withArgumentsIn: nil) else {
            print("5712 Error: \(String(describing: dbFavorite.lastErrorMessage()))")
            return false
        }
        
        let boolean: Bool = result.next()
        if boolean {
            myFavoriteButton.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
//            myFavoriteButton.setTitleColor(UIColor.yellow, for: .normal)
            
        } else {
            myFavoriteButton.backgroundColor = #colorLiteral(red: 0.09949313849, green: 0.584387064, blue: 0.8090866208, alpha: 1)
//            myFavoriteButton.setTitleColor(UIColor.white, for: .normal)
            
        }
        dbFavorite.close()
        return boolean
    }
    
    // MARK: 버튼 디자인 및 기능 구현
    func setButtonDesign() {
        // 하단 툴바 둥근 모양 버튼
        myPreviousButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 2, right: 1)
        myPreviousButton.layer.cornerRadius = 18
        myPreviousButton.layer.borderWidth = 1
        myPreviousButton.layer.borderColor = UIColor.white.cgColor
        myPreviousButton.clipsToBounds = true
        
        myNextButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 1, bottom: 2, right: 0)
        myNextButton.layer.cornerRadius = 18
        myNextButton.layer.borderWidth = 1
        myNextButton.layer.borderColor = UIColor.white.cgColor
        myNextButton.clipsToBounds = true
        
        myFavoriteButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        myFavoriteButton.layer.cornerRadius = 18
        myFavoriteButton.layer.borderWidth = 1
        myFavoriteButton.layer.borderColor = UIColor.white.cgColor
        myFavoriteButton.clipsToBounds = true
        
        myExplainButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        myExplainButton.layer.cornerRadius = 5
        myExplainButton.layer.borderWidth = 1
        myExplainButton.layer.borderColor = UIColor.white.cgColor
        myExplainButton.clipsToBounds = true
        
    }
    
    //MARK: 탭하면 정답보여주기
    @objc func handleTap(sender: UITapGestureRecognizer) {
        explan()
    }
    
    func handleLongTap(sender: UILongPressGestureRecognizer) {
//        print("\(sender.state.rawValue)")
        
        if sender.state == .changed {
            return
        }
        
        print("5712 handleLongTap = \(sender.location(in: self.view))")
        
    }
    
    @objc func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool
    {
        return true
    }
    
    @IBAction func explanAction(_ sender: UIButton) {
        explan()
    }
    
    func explan() {

//        myExplainButton.setTitleColor(UIColor.gray, for: .normal)
//        myExplainButton.layer.borderColor = UIColor.gray.cgColor
        myExplainButton.alpha = 0.3
//        myExplainButton.layer.backgroundColor = #colorLiteral(red: 0.09803921569, green: 0.5843137255, blue: 0.8078431373, alpha: 1).cgColor
        
        let checkRedCharacter = content.range(of: "<font color=red>")
        if checkRedCharacter != nil {
            return
        }
        var explainContent = content.replacingOccurrences(of: "<font color=>", with: "<font color=red>")
        explainContent = explainContent.replacingOccurrences(of: "</table><br><br></body></html>", with: "")
        explainContent = explainContent + "<br><br>" + explainContentHTML + "</table><br><br></body></html>"
        content = explainContent
        
        myWebView.loadHTMLString(content, baseURL: nil)
    }

    //MARK: 좌우 스와이프로 이전/다음문제 이동하기
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {

        if userDefautSwitchSwipeMove == false { //스와이프로 문제이동이 아닐 경우
            return
        }
        
        if gesture.direction == UISwipeGestureRecognizerDirection.right {
            previousQuestion()
        }
        else if gesture.direction == UISwipeGestureRecognizerDirection.left {
            nextQuestion()
        }
        else if gesture.direction == UISwipeGestureRecognizerDirection.up {
//            print("Swipe Up")
        }
        else if gesture.direction == UISwipeGestureRecognizerDirection.down {
//            print("Swipe Down")
        }
    }

    @objc func gestureRecognizer(_: UISwipeGestureRecognizer, shouldRecognizeSimultaneouslyWith shouldRecognizeSimultaneouslyWithGestureRecognizer:UISwipeGestureRecognizer) -> Bool
    {
        return true
    }

    func previousQuestion() {
        if questionNum == questionArrays.startIndex {
            CWMessageShow(text: "처음 문제입니다.")
        } else {
            questionNum = questionNum - 1
            loadData()
        }
    }
    
    @IBAction func previousQuestionAction(_ sender: UIButton) {
        previousQuestion()
    }
    
    @IBAction func nextQuestionAction(_ sender: UIButton) {
        nextQuestion()
    }
    
    func nextQuestion() {
        
        if questionArrays.endIndex == 0 ||
           questionNum+1 == questionArrays.endIndex {
            CWMessageShow(text: "마지막 문제입니다.")
        } else {
            questionNum = questionNum + 1
            loadData()
        }
    }
    
    
    @IBAction func addToFavorite(_ sender: UIButton) {
        
        if checkFavorite() { //북마크 여부 확인 후 버튼 색상 설정
            guard let dbFavorite = FMDatabase(path: favoritePath) else {
                print("5712 DB Favirote Not Found")
                return
            }
            
            if dbFavorite.open() != true {
                print("5712 DB Open Failed")
                return
            }
            let deleteSQL = "DELETE FROM questionlist WHERE examtype = '\(examtype)' AND subject = '\(subject)' AND chapter = \(questionArrays[questionNum][0]) AND qnumber = \(questionArrays[questionNum][1])"
            guard dbFavorite.executeUpdate(deleteSQL, withArgumentsIn: nil) else {
                print("5712 Error: \(String(describing: dbFavorite.lastErrorMessage()))")
                return
            }
            _ = navigationController?.popViewController(animated: true)
            dbFavorite.close()
            
        } else {
            guard let db = FMDatabase(path: dbPath) else {
                print("5712 DB Not Found")
                return
            }
            
            if db.open() != true {
                print("5712 DB Open Failed")
                return
            }
            
            let selectSQL = "SELECT * FROM questionlist WHERE examtype = '\(examtype)' AND subject = '\(subject)' AND chapter = \(questionArrays[questionNum][0]) AND qnumber = \(questionArrays[questionNum][1])"
            guard let result = db.executeQuery(selectSQL, withArgumentsIn: nil) else {
                print("5712 Error: \(String(describing: db.lastErrorMessage()))")
                return
            }
            
            guard let dbFavorite = FMDatabase(path: favoritePath) else {
                print("5712 DB Favirote Not Found")
                return
            }
            if dbFavorite.open() != true {
                print("5712 DB Favirote Open Failed")
                return
            }
            
            while result.next() {
                guard let anumber = result.string(forColumn: "anumber") else { return }
                guard let correct = result.string(forColumn: "correct") else { return }
                guard let content = result.string(forColumn: "content") else { return }
                let contextConvert = content.replacingOccurrences(of: "'", with: "''") // ' 특수기호가 있을 경우 ''로 변경
                
                let insertQuery = "INSERT INTO questionlist (examtype, subject, chapter, qnumber, anumber, correct, content) VALUES ('\(examtype)', '\(subject)', \(questionArrays[questionNum][0]), \(questionArrays[questionNum][1]), \(anumber), '\(correct)', '\(contextConvert)')"
                let resultFavorite = dbFavorite.executeUpdate(insertQuery, withArgumentsIn: nil)
                if !resultFavorite {
                    print("Error: \(String(describing: dbFavorite.lastErrorMessage()))")
                }
            }
            CWMessageShow(text: "북마크에 추가되었습니다.")
            dbFavorite.close()
            db.close()
        }
        _ = checkFavorite()
    }
    
    //MARK: 각종 메세지 표시
    func CWMessageShow(text: String) -> Void {
        CWMessageTextField.alpha = 1
        CWMessageTextField.text = text
        delay(delay: 0.5, closure: {
            UIView.animate(withDuration: 0.5, animations: {
                self.CWMessageTextField.alpha = 0
            })
        })
    }
    
    func delay(delay: Double, closure: @escaping () ->()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            closure()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
            myWebView.loadHTMLString(content, baseURL: nil) // 가로모드 시 글자가 커지는 문제 해결
        } else {
            print("Portrait")
        }
    }
    
}
