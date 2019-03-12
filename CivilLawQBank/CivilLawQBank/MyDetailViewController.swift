//
//  MyDetailViewController.swift
//  CivilLawQBank
//
//  Created by Mac on 2017. 6. 27..
//  Copyright © 2017년 5712ya. All rights reserved.
//  실제 문제 푯

import UIKit
import AudioToolbox

class MyDetailViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - UI버튼 선언
    @IBOutlet weak var myScrollView: UIScrollView!
    @IBOutlet weak var viewInScroll: UIView!
    
    @IBOutlet weak var questionNumber: UIButton!
    @IBOutlet weak var questionButton: UIButton!
    @IBOutlet weak var answer1Number: UIButton!
    @IBOutlet weak var answer1Button: UIButton!
    @IBOutlet weak var answer2Number: UIButton!
    @IBOutlet weak var answer2Button: UIButton!
    @IBOutlet weak var answer3Number: UIButton!
    @IBOutlet weak var answer3Button: UIButton!
    @IBOutlet weak var answer4Number: UIButton!
    @IBOutlet weak var answer4Button: UIButton!
    @IBOutlet weak var answer5Number: UIButton!
    @IBOutlet weak var answer5Button: UIButton!
    @IBOutlet weak var explainButton: UIButton!
    
    @IBOutlet weak var Answer1ButtonTopLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var Answer2ButtonTopLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var Answer3ButtonTopLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var Answer4ButtonTopLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var Answer5ButtonTopLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var ExplainButtonTopLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var QuestionButtonHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var Answer1ButtonHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var Answer2ButtonHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var Answer3ButtonHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var Answer4ButtonHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var Answer5ButtonHeightLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var myPreviousButton: UIButton!
    @IBOutlet weak var myNextButton: UIButton!
    @IBOutlet weak var myExplainButton: UIButton!
    @IBOutlet weak var myFavoriteButton: UIButton!
    @IBOutlet weak var CWMessageTextField: UITextField!
    @IBOutlet weak var CWAnswerLabel: UILabel!
    
    // FIXME: UI버튼 정렬
//    var buttonHeight:CGFloat = 0
//    var questionConstraint: NSLayoutConstraint?
//    var answer1Constraint: NSLayoutConstraint?
//    var answer2Constraint: NSLayoutConstraint?
//    var answer3Constraint: NSLayoutConstraint?
//    var answer4Constraint: NSLayoutConstraint?
//    var answer5Constraint: NSLayoutConstraint?
//    var explainConstraint: NSLayoutConstraint?

    // MARK: 내부 변수 선언
    var dbPath: String? //sqlite 파일 주소
    
    var examtype: String = ""    //시헝유형
    var subject: String = ""     //과목명
    var chapterNum: Int = 0      //단원
    var questionNum: Int = 0     //문제번호
    
    var chapterName: String = ""    //단원명
    var content: String = ""        //문제내용
    var explainContent: String = "" //해설
    var qnumberArray = [String()]   //문제번호 리스트
    var correctAnswerNum:Int = 0    //정답
    
    var questionArray = Array<Int>()
    var questionArrays = Array<Array<Int>>()
    
    var answerArray = Array<String>()
    var answerArrays = Array<Array<String>>()
    
    // MARK: - 최초실행
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // 웹뷰 좌우 스와이프로 이전/다음문제 보여주기
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)

        setButtonDesign() // 하단 툴바 둥근 모양 버튼
        
        CWMessageTextField.layer.cornerRadius = 10 //메세지 출력 텍스트필드
        CWMessageTextField.alpha = 0
        CWAnswerLabel.alpha = 0
        
        getQuestionList() // 챕터별 문제번호 리스트 가져오기
        
        if questionArrays.count == 0 {
            CWMessageShow(text: "등록된 문제가 없습니다.")
            questionNumber.isHidden = true
            questionButton.isHidden = true
            answer1Number.isHidden = true
            answer1Button.isHidden = true
            answer2Number.isHidden = true
            answer2Button.isHidden = true
            answer3Number.isHidden = true
            answer3Button.isHidden = true
            answer4Number.isHidden = true
            answer4Button.isHidden = true
            answer5Number.isHidden = true
            answer5Button.isHidden = true
            explainButton.isHidden = true
            myExplainButton.alpha = 0.3
            myExplainButton.isEnabled = false
            myPreviousButton.alpha = 0.3
            myPreviousButton.isEnabled = false
            myNextButton.alpha = 0.3
            myNextButton.isEnabled = false
            myFavoriteButton.alpha = 0.3
            myFavoriteButton.isEnabled = false
        } else {
            loadData() // 문제 화면에 출력하기
        }
        
    }
    
    //MARK: - 문제 리스트 추출
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
        
        answer1Number.setTitleColor(questionButton.titleLabel?.textColor, for: .normal)
        answer1Button.setTitleColor(questionButton.titleLabel?.textColor, for: .normal)
        answer2Number.setTitleColor(questionButton.titleLabel?.textColor, for: .normal)
        answer2Button.setTitleColor(questionButton.titleLabel?.textColor, for: .normal)
        answer3Number.setTitleColor(questionButton.titleLabel?.textColor, for: .normal)
        answer3Button.setTitleColor(questionButton.titleLabel?.textColor, for: .normal)
        answer4Number.setTitleColor(questionButton.titleLabel?.textColor, for: .normal)
        answer4Button.setTitleColor(questionButton.titleLabel?.textColor, for: .normal)
        answer5Number.setTitleColor(questionButton.titleLabel?.textColor, for: .normal)
        answer5Button.setTitleColor(questionButton.titleLabel?.textColor, for: .normal)
        
        answer1Number.isEnabled = true
        answer1Button.isEnabled = true
        answer2Number.isEnabled = true
        answer2Button.isEnabled = true
        answer3Number.isEnabled = true
        answer3Button.isEnabled = true
        answer4Number.isEnabled = true
        answer4Button.isEnabled = true
        answer5Number.isEnabled = true
        answer5Button.isEnabled = true
        
        guard let db = FMDatabase(path: dbPath) else {
            print("5712 DB Not Found")
            return
        }
        
        if db.open() {
            
            var selectSQL: String = ""
            content = ""
            explainContent = ""

            if dbPath == questionPath &&  // 전체학습일 경우(북마크보기가 아닐때)
               chapterNum != 0 {  //무작위 문제풀이 배열랜덤 섞기
                userDefautQuestionProgress[chapterNum - 1] = Float(questionNum)
                UserDefaults.standard.set(userDefautQuestionProgress, forKey: questionProgress)
            }
            
            selectSQL = "SELECT * FROM questionlist WHERE examtype = '\(examtype)' AND subject = '\(subject)' AND chapter = \(questionArrays[questionNum][0]) AND qnumber = \(questionArrays[questionNum][1])"
            guard let result = db.executeQuery(selectSQL, withArgumentsIn: nil) else {
                print("5712 Error: \(String(describing: db.lastErrorMessage()))")
                return
            }
            
            answerArrays.removeAll()
            while result.next() {
                answerArray.removeAll()
                guard let anumber = result.string(forColumn: "anumber") else { return }
                guard let correct = result.string(forColumn: "correct") else { return }
                let content = (result.string(forColumn: "content"))!
            
                if anumber == "" {
                    continue
                } else if anumber == "0" {
                    questionButton.setTitle("\(String(describing: content))", for: .normal)
                    questionButton.titleLabel?.text = "\(String(describing: content))"
                } else if anumber == "1" || anumber == "2" || anumber == "3" || anumber == "4" || anumber == "5" {
//                    answerArray.append(String(correct)!)
//                    answerArray.append(String(content)!)
                    answerArray.append(correct)
                    answerArray.append(content)
                    answerArrays.append(answerArray)
                    answerArray.removeAll()
                } else {
                    explainContent = "\(explainContent)\(String(describing: content))\n"
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

            explainButton.setTitle(explainContent, for: .normal)
            explainButton.titleLabel?.text = explainContent
//            explainButton.setTitle(".", for: .normal)
//            explainButton.titleLabel?.text = "."
            explainButton.isHidden = true
            myExplainButton.alpha = 1
            
            for (index, answer) in answerArrays.enumerated() {
                if index == 0 {
                    answer1Button.setTitle(answer[1], for: .normal)
                    answer1Button.titleLabel?.text = answer[1]
                } else if index == 1 {
                    answer2Button.setTitle(answer[1], for: .normal)
                    answer2Button.titleLabel?.text = answer[1]
                } else if index == 2 {
                    answer3Button.setTitle(answer[1], for: .normal)
                    answer3Button.titleLabel?.text = answer[1]
                } else if index == 3 {
                    answer4Button.setTitle(answer[1], for: .normal)
                    answer4Button.titleLabel?.text = answer[1]
                } else if index == 4 {
                    answer5Button.setTitle(answer[1], for: .normal)
                    answer5Button.titleLabel?.text = answer[1]
                }
                
                if answer[0] == "Y" {
                    correctAnswerNum = index + 1 //정답 번호
                }
            }
            
            if userDefautSwitchAnswerShow { //정답 보기 모드의 경우
                explan()
            }
            
            viewInScroll.alpha = 0
            delay(delay: 0.2, closure: {
                UIView.animate(withDuration: 0.2, animations: {
                    self.viewInScroll.alpha = 1
                    self.viewInScroll.layoutIfNeeded()
                })
            })
            
            if chapterNum != 0 {
                navigationItem.title = "\(chapterName) (\(questionNum+1) / \(questionArrays.endIndex))"
            } else {
                navigationItem.title = "무작위 문제풀기 (\(questionNum+1) / \(questionArrays.endIndex))"
            }
            
            if questionNum == 0 {
                myPreviousButton.alpha = 0.3
            } else {
                myPreviousButton.alpha = 1
            }
            
            if questionNum+1 == questionArrays.endIndex {
                myNextButton.alpha = 0.3
            } else {
                myNextButton.alpha = 1
            }
            
            _ = checkFavorite() //북마크 여부 확인 후 버튼 색상 설정
            
            setButtonConstraint() //버튼 간격 정렬
            myScrollView.setContentOffset(CGPoint(x:0, y:0), animated: true)
         
            
        }
    
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
        
        
//        http://apps.timwhitlock.info/emoji/tables/unicode
//        myFavoriteButton.setTitle("\u{1F4D6}", for: .normal)
        myFavoriteButton.contentEdgeInsets = UIEdgeInsets(top: 2, left: 0, bottom: 0, right: 0)
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
    
    // FIXME: 문제 간격
    func setButtonConstraint() {
        
        setButtonFont(buttonNumber: questionNumber, buttonName: questionButton)
        setButtonFont(buttonNumber: answer1Number, buttonName: answer1Button)
        setButtonFont(buttonNumber: answer2Number, buttonName: answer2Button)
        setButtonFont(buttonNumber: answer3Number, buttonName: answer3Button)
        setButtonFont(buttonNumber: answer4Number, buttonName: answer4Button)
        setButtonFont(buttonNumber: answer5Number, buttonName: answer5Button)
        setButtonFont(buttonNumber: explainButton, buttonName: explainButton)
        
        view.layoutIfNeeded()
        myScrollView.layoutIfNeeded()
        viewInScroll.layoutIfNeeded()

        guard let questionButtonHeight = questionButton.titleLabel?.frame.size.height else {
            return
        }
        QuestionButtonHeightLayoutConstraint.constant = questionButtonHeight
        
        guard let answer1ButtonHeight = answer1Button.titleLabel?.frame.size.height else {
            return
        }
        Answer1ButtonHeightLayoutConstraint.constant = answer1ButtonHeight
        
        guard let answer2ButtonHeight = answer2Button.titleLabel?.frame.size.height else {
            return
        }
        Answer2ButtonHeightLayoutConstraint.constant = answer2ButtonHeight
        
        guard let answer3ButtonHeight = answer3Button.titleLabel?.frame.size.height else {
            return
        }
        Answer3ButtonHeightLayoutConstraint.constant = answer3ButtonHeight
        
        guard let answer4ButtonHeight = answer4Button.titleLabel?.frame.size.height else {
            return
        }
        Answer4ButtonHeightLayoutConstraint.constant = answer4ButtonHeight
        
        guard let answer5ButtonHeight = answer5Button.titleLabel?.frame.size.height else {
            return
        }
        Answer5ButtonHeightLayoutConstraint.constant = answer5ButtonHeight
        
        viewInScroll.layoutIfNeeded()
        myScrollView.layoutIfNeeded()
        view.layoutIfNeeded()
        
        
        
            /*
        view.layoutIfNeeded()
        myScrollView.layoutIfNeeded()
        viewInScroll.layoutIfNeeded()
        
        buttonHeight = (questionButton.titleLabel?.frame.size.height)! + 4
        questionConstraint?.isActive = false
        if #available(iOS 9.0, *) {
            questionConstraint = questionButton.heightAnchor.constraint(equalToConstant: buttonHeight)
        } else {
            // Fallback on earlier versions
        }
        questionConstraint?.isActive = true
        
        buttonHeight = (answer1Button.titleLabel?.frame.size.height)! + 4
        answer1Constraint?.isActive = false
        if #available(iOS 9.0, *) {
            answer1Constraint = answer1Button.heightAnchor.constraint(equalToConstant: buttonHeight)
        } else {
            // Fallback on earlier versions
        }
        answer1Constraint?.isActive = true
        
        buttonHeight = (answer2Button.titleLabel?.frame.size.height)! + 4
        answer2Constraint?.isActive = false
        answer2Constraint = answer2Button.heightAnchor.constraint(equalToConstant: buttonHeight)
        answer2Constraint?.isActive = true
        
        buttonHeight = (answer3Button.titleLabel?.frame.size.height)! + 4
        answer3Constraint?.isActive = false
        answer3Constraint = answer3Button.heightAnchor.constraint(equalToConstant: buttonHeight)
        answer3Constraint?.isActive = true
        
        buttonHeight = (answer4Button.titleLabel?.frame.size.height)! + 4
        answer4Constraint?.isActive = false
        answer4Constraint = answer4Button.heightAnchor.constraint(equalToConstant: buttonHeight)
        answer4Constraint?.isActive = true
        
        buttonHeight = (answer5Button.titleLabel?.frame.size.height)! + 4
        answer5Constraint?.isActive = false
        answer5Constraint = answer5Button.heightAnchor.constraint(equalToConstant: buttonHeight)
        answer5Constraint?.isActive = true
        
        buttonHeight = (explainButton.titleLabel?.frame.size.height)! + 4
        explainConstraint?.isActive = false
        explainConstraint = explainButton.heightAnchor.constraint(equalToConstant: buttonHeight)
        explainConstraint?.isActive = true
        
        viewInScroll.layoutIfNeeded()
        myScrollView.layoutIfNeeded()
        view.layoutIfNeeded()
        */
    }
    
    func setButtonFont(buttonNumber: UIButton, buttonName: UIButton) {
        
        var fontSize: CGFloat = 17 //글자 크기
        switch userDefautFontSize {
        case 0:
            fontSize = 15
        case 1:
            fontSize = 17
        case 2:
            fontSize = 20
        default:
            return;
        }
        
        let mutableParagraphStyle = NSMutableParagraphStyle()
        mutableParagraphStyle.lineSpacing = CGFloat(5) // 줄간격
        var attributedString: NSMutableAttributedString? //버튼 속성
        
        attributedString = NSMutableAttributedString(string: (buttonName.titleLabel?.text)!)
        
        if let stringLength = buttonName.titleLabel?.text?.characters.count {
            attributedString?.addAttribute(NSAttributedStringKey.paragraphStyle, value: mutableParagraphStyle, range: NSMakeRange(0, stringLength))
        }
        buttonName.titleLabel?.attributedText = attributedString
        buttonName.titleLabel?.font = UIFont(name: (buttonName.titleLabel?.font.fontName)!, size: fontSize)
        buttonNumber.titleLabel?.font = UIFont(name: (buttonNumber.titleLabel?.font.fontName)!, size: fontSize)
        
        return
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
            myFavoriteButton.backgroundColor = questionButton.titleLabel?.textColor
        } else {
            myFavoriteButton.backgroundColor = navigationController?.navigationBar.barTintColor
        }
        dbFavorite.close()
        return boolean
    }
    
    //MARK: 정답보기 버튼
    @IBAction func explanAction(_ sender: Any) {
        explan()
    }
    
    func explan() {
        
        explainButton.isHidden = false
        myExplainButton.alpha = 0.3
        
        answer1Number.isEnabled = false
        answer1Button.isEnabled = false
        answer2Number.isEnabled = false
        answer2Button.isEnabled = false
        answer3Number.isEnabled = false
        answer3Button.isEnabled = false
        answer4Number.isEnabled = false
        answer4Button.isEnabled = false
        answer5Number.isEnabled = false
        answer5Button.isEnabled = false
        
        switch correctAnswerNum {
        case 1:
            answer1Number.setTitleColor(UIColor.red, for: .normal)
            answer1Button.setTitleColor(UIColor.red, for: .normal)
        case 2:
            answer2Number.setTitleColor(UIColor.red, for: .normal)
            answer2Button.setTitleColor(UIColor.red, for: .normal)
        case 3:
            answer3Number.setTitleColor(UIColor.red, for: .normal)
            answer3Button.setTitleColor(UIColor.red, for: .normal)
        case 4:
            answer4Number.setTitleColor(UIColor.red, for: .normal)
            answer4Button.setTitleColor(UIColor.red, for: .normal)
        case 5:
            answer5Number.setTitleColor(UIColor.red, for: .normal)
            answer5Button.setTitleColor(UIColor.red, for: .normal)
        default:
            return
        }
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
    
//    @objc func gestureRecognizer(_: UISwipeGestureRecognizer, shouldRecognizeSimultaneouslyWith shouldRecognizeSimultaneouslyWithGestureRecognizer:UISwipeGestureRecognizer) -> Bool
//    {
//        return true
//    }
    
    @IBAction func previousQuestionAction(_ sender: UIButton) {
        previousQuestion()
    }
    
    @IBAction func nextQuestionAction(_ sender: UIButton) {
        nextQuestion()
    }
    
    func previousQuestion() {
        if questionNum == questionArrays.startIndex {
            CWMessageShow(text: "처음 문제입니다.")
        } else {
            questionNum = questionNum - 1
            if chapterNum != 0 {
                userDefautQuestionProgress[chapterNum - 1] = Float(questionNum)
            }
            loadData()
        }
    }
    
    func nextQuestion() {
        
        if questionArrays.endIndex == 0 ||
            questionNum+1 == questionArrays.endIndex {
            CWMessageShow(text: "마지막 문제입니다.")
        } else {
            questionNum = questionNum + 1
            if chapterNum != 0 {
                userDefautQuestionProgress[chapterNum - 1] = Float(questionNum)
            }
            loadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func addToFavorite() {
        
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
//            CWMessageShow(text: "북마크에 추가되었습니다.")
            dbFavorite.close()
            db.close()
        }
        _ = checkFavorite()
    }
    
    @IBAction func addToFavoriteAction(_ sender: UIButton) {
        
        addToFavorite()
        
    }
    
    func checkAnswer(number: Int, answerButton: UIButton, answerNumber: UIButton) -> Void {
        if correctAnswerNum == number {
//            CWAnswerShow(text: "✔︎")
            explan()
        } else {
            answerNumber.setTitleColor(navigationController?.navigationBar.barTintColor, for: .normal)
            answerButton.setTitleColor(navigationController?.navigationBar.barTintColor, for: .normal)
            delay(delay: 0.5, closure: {
                UIView.animate(withDuration: 0.5, animations: {
                    answerNumber.setTitleColor(self.questionButton.titleLabel?.textColor, for: .normal)
                    answerButton.setTitleColor(self.questionButton.titleLabel?.textColor, for: .normal)
                })
            })
            if userDefautSwitchWrongAnswerVibrate {
                if #available(iOS 9.0, *) {
                    AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate), nil)
                } else {
                    // Fallback on earlier versions
                }
            }
            CWAnswerShow(text:"✘")
            if userDefautSwitchWrongAnswerReg {
                if checkFavorite() == false { //북마크에 등록되지 않았을 경우만
                    addToFavorite()
                }
            }
        }
    }
    
    @IBAction func answer1NumberAction(_ sender: Any) {
        checkAnswer(number: 1, answerButton: answer1Button, answerNumber: answer1Number)
    }
    
    @IBAction func answer1Action(_ sender: Any) {
        checkAnswer(number: 1, answerButton: answer1Button, answerNumber: answer1Number)
    }
    
    @IBAction func answer2NumberAction(_ sender: Any) {
        checkAnswer(number: 2, answerButton: answer2Button, answerNumber: answer2Number)
    }
    
    @IBAction func answer2Action(_ sender: Any) {
        checkAnswer(number: 2, answerButton: answer2Button, answerNumber: answer2Number)
    }
  
    @IBAction func answer3NumberAction(_ sender: Any) {
        checkAnswer(number: 3, answerButton: answer3Button, answerNumber: answer3Number)
    }
    
    @IBAction func answer3Action(_ sender: Any) {
        checkAnswer(number: 3, answerButton: answer3Button, answerNumber: answer3Number)
    }
    
    @IBAction func answer4NumberAction(_ sender: Any) {
        checkAnswer(number: 4, answerButton: answer4Button, answerNumber: answer4Number)
    }
    @IBAction func answer4Action(_ sender: Any) {
        checkAnswer(number: 4, answerButton: answer4Button, answerNumber: answer4Number)
    }
    
    @IBAction func answer5NumberAction(_ sender: Any) {
        checkAnswer(number: 5, answerButton: answer5Button, answerNumber: answer5Number)
    }
    @IBAction func answer5Action(_ sender: Any) {
        checkAnswer(number: 5, answerButton: answer5Button, answerNumber: answer5Number)
    }
    
    //  MARK: 각종 메세지 표시
    func CWMessageShow(text: String) -> Void {
        CWMessageTextField.alpha = 1
        CWMessageTextField.text = text
        delay(delay: 0.5, closure: {
            UIView.animate(withDuration: 0.5, animations: {
                self.CWMessageTextField.alpha = 0
            })
        })
    }
    
    func CWAnswerShow(text: String) -> Void {
        CWAnswerLabel.alpha = 1
        CWAnswerLabel.text = text
//        let attributedString = NSAttributedString(string: (CWAnswerLabel.text)!, attributes: [
//            NSForegroundColorAttributeName : UIColor.white,
//            NSStrokeColorAttributeName : UIColor.black,
//            NSStrokeWidthAttributeName : NSNumber(value: -0.2),
//            NSFontAttributeName : UIFont.systemFont(ofSize: 26.0)
//            ])
//        CWAnswerLabel.attributedText = attributedString
        delay(delay: 0.5, closure: {
            UIView.animate(withDuration: 0.5, animations: {
                self.CWAnswerLabel.alpha = 0
            })
        })
    }
    
    func delay(delay: Double, closure: @escaping () ->()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            closure()
        }
    }
    
    // MARK: - 화면 회전 시
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        delay(delay: 0, closure: {
            UIView.animate(withDuration: 0, animations: {
                self.setButtonConstraint()
            })
        })
 
        if UIDevice.current.orientation.isLandscape {
//            print("Landscape")
        } else {
//            print("Portrait")
        }
    }
}
