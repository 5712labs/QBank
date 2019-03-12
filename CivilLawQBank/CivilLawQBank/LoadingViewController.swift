//
//  LoadingViewController.swift
//  CivilLawQBank
//
//  Created by Mac on 2017. 4. 28..
//  Copyright © 2017년 5712ya. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {

    @IBOutlet weak var myProgressView: UIProgressView!
    @IBOutlet weak var myProgressLabel: UILabel!
    
    var makeQuestionIndex: Float = 0.0 // 프로그레스바용 다운로드 완료 문제수
    var makeQuestionCount: Float = 0.0 // 프로그레스바용 총 문제수
    var timer: Timer?
    
    let fileMgr = FileManager.default
    let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppDelegate.AppUtility.lockOrientation(.portrait) //가로모드 금지
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if userDefautSwitchScreenRotation == false { //세로화면 고정이 아닐 경우
            AppDelegate.AppUtility.lockOrientation(.all) //화면회전 허용
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(LoadingViewController.updateProgress), userInfo: nil, repeats: true) // 0.1초에 한번씩 다운로드 프로그레스바 상태 갱신

        DispatchQueue.global().async {
            self.makeQuestionTable()  // 학습용 데이터베이스 생성 - 어플 설치 후 최초 1회
        }
        makeFavoriteTable() // 북마크용 데이터베이스 생성
    }

    @objc func updateProgress() { // 다운로드 프로그레스바 상태 갱신
        
        if makeQuestionIndex == 0 || makeQuestionCount == 0 {
            return
        }
        
        let progress = makeQuestionIndex / makeQuestionCount
        myProgressView.progress = progress
        //        myProgressLabel.text = String(format: "%0.1f", progress * 100) + "%"
        myProgressLabel.text = "최신문제 다운로드 중... " + String(format: "%0.0f", progress * 100) + "%(" + String(format: "%0.0f", makeQuestionIndex) + "/" + String(format: "%0.0f", makeQuestionCount) + ")"
        
        if progress == 1 {
            timer?.invalidate() // 0.1초에 한번식 호출 종료
            ShowMainSB() // 메인 네비게이션 뷰로 이동하기
        }
    }
    
    func ShowMainSB() { // 메인 네비게이션 뷰로 이동하기
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(withIdentifier: "MainSB")
        self.present(nextView, animated: true, completion: nil)
    }
    
    func makeQuestionTable() { // 학습용 데이터베이스 생성 - 어플 설치 후 최초 1회
        let docsDir = dirPaths[0]
        questionPath = docsDir + "/questionlist.sql" // 사용자 파일 경로
        guard let documentQuestionDB = FMDatabase(path: questionPath) else {
            return
        }
        if documentQuestionDB.open() == false {
            return
        }
        let sql_statement = "Create table if not exists questionlist(id integer primary key autoincrement, examtype text, subject text, chapter integer, qnumber integer, anumber integer, correct text, content text)"
        if documentQuestionDB.executeStatements(sql_statement) == false {
            return
        }
        
        guard let documentCountResult = documentQuestionDB.executeQuery("SELECT * FROM questionlist WHERE anumber = 0", withArgumentsIn: nil) else {
            print("5712 documentCountResult Error: \(String(describing: documentQuestionDB.lastErrorMessage()))")
            return
        }
        
        var documentDBCount = 0 //사용자 파일에 문제수
        while documentCountResult.next() == true {
            documentDBCount = documentDBCount + 1
        }
        
        var questionArray = Array<Int>()
        var questionArrays = Array<Array<Int>>()
        let bundleQuestionPath = Bundle.main.path(forResource: "questionlist", ofType:"sqlite")  // 번들 파일 경로
        guard let bundleQuestionDB = FMDatabase(path: bundleQuestionPath) else {
            return
        }
        if bundleQuestionDB.open() == false {
            return
        }
        let selectSQL = "SELECT * FROM questionlist WHERE anumber = 0"
        guard let bundleSelectResult = bundleQuestionDB.executeQuery(selectSQL, withArgumentsIn: nil) else {
            print("5712 bundleSelectResult Error: \(String(describing: bundleQuestionDB.lastErrorMessage()))")
            return
        }
  
        var bundleDBCount = 0 //번들 파일에 문제수
        
        questionArrays.removeAll()
        
        while bundleSelectResult.next() == true {
            let chapterValue = bundleSelectResult.string(forColumn: "chapter")
            questionArray.append(Int(chapterValue!)!)
            let qnumberValue = bundleSelectResult.string(forColumn: "qnumber")
            questionArray.append(Int(qnumberValue!)!)
            questionArrays.append(questionArray)
            questionArray.removeAll()
            
            bundleDBCount = bundleDBCount + 1
        }

        print("User File: \(documentDBCount) / Bundle File: \(bundleDBCount)")

        if documentDBCount == bundleDBCount { //사용자 파일에 문제수와 번들 파일에 문제수가 동일할 경우 리턴
            makeQuestionIndex = 1
            makeQuestionCount = 1
            return
        }
        
        // 번들파일의 문제를 사용자파일로 복사(문제를 섞어세 복사/초기 1회만)
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
        
        questionArrays.sort { $0[0] < $1[0] }
        
        let deleteQuery = "DELETE FROM questionlist"
        let documentDeleteResult = documentQuestionDB.executeUpdate(deleteQuery, withArgumentsIn: nil)
        if !documentDeleteResult {
            print("5712 Error: \(String(describing: documentQuestionDB.lastErrorMessage()))")
            return
        }
        
        for (index, arrays) in questionArrays.enumerated() {
            
            makeQuestionIndex = Float(index+1) // 프로그레스바용 다운로드 완료 문제수
            makeQuestionCount = Float(questionArrays.count) // 프로그레스바용 총문제수
            
            let selectSQL = "SELECT * FROM questionlist WHERE chapter = \(arrays[0]) and qnumber = \(arrays[1])"
            guard let bundleSelectResult = bundleQuestionDB.executeQuery(selectSQL, withArgumentsIn: nil) else {
                print("5712 Error: \(String(describing: bundleQuestionDB.lastErrorMessage()))")
                return
            }
            
            while bundleSelectResult.next() == true {
                
                guard let examtype = bundleSelectResult.string(forColumn: "examtype") else { return }
                guard let subject  = bundleSelectResult.string(forColumn: "subject") else { return }
                guard let chapter  = bundleSelectResult.string(forColumn: "chapter") else { return }
                guard let qnumber  = bundleSelectResult.string(forColumn: "qnumber") else { return }
                //                let qnumber = index+1
                guard let anumber  = bundleSelectResult.string(forColumn: "anumber") else { return }
                guard let correct  = bundleSelectResult.string(forColumn: "correct") else { return }
                guard let content  = bundleSelectResult.string(forColumn: "content") else { return }
                let contentConvert = content.replacingOccurrences(of: "'", with: "''") // ' 특수기호가 있을 경우 ''로 변경
                
                let insertQuery = "INSERT INTO questionlist (examtype, subject, chapter, qnumber, anumber, correct, content) VALUES ('\(examtype)', '\(subject)', \(chapter), \(qnumber), \(anumber), '\(correct)', '\(contentConvert)')"
                let documentInsertResult = documentQuestionDB.executeUpdate(insertQuery, withArgumentsIn: nil)
                if !documentInsertResult {
                    print("5712 Error: \(String(describing: documentQuestionDB.lastErrorMessage()))")
                    return
                }
            }
        }
        
        documentQuestionDB.close()
        bundleQuestionDB.close()
        
    }
    
    func makeFavoriteTable() { // 북마크용 데이터베이스 생성
        let docsDir = dirPaths[0]
        favoritePath = docsDir + "/favoritelist.sql"
        if fileMgr.fileExists(atPath: favoritePath) == true {
            return
        }
        
        guard let documentFavoriteDB = FMDatabase(path: favoritePath) else {
            return
        }
        if documentFavoriteDB.open() == false {
            return
        }
        let sql_statement = "Create table if not exists questionlist(id integer primary key autoincrement, examtype text, subject text, chapter integer, qnumber integer, anumber integer, correct text, content text)"
        if documentFavoriteDB.executeStatements(sql_statement) == false {
            return
        }
        documentFavoriteDB.close()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
