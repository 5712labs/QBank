//
//  QuestionViewController.swift
//  CivilLawQBank
//
//  Created by Mac on 2017. 4. 1..
//  Copyright © 2017년 5712ya. All rights reserved.
//

import UIKit

class QuestionViewController: UITableViewController {
    
    @IBOutlet weak var mySegment: UISegmentedControl!

    var chapterItems: ChapterItems?
    var dbPath: String? //sqlite 파일 주소
    override func viewDidLoad() {
        super.viewDidLoad()
        setInitialChatperList()
    }

    override func viewDidAppear(_ animated: Bool) {
        
        self.navigationItem.title = "민법총칙 실전문제" // 다음화면의 뒤로가기에 < 만 표시
        if mySegment.selectedSegmentIndex == 1 {
            setInitialChatperList()
            tableView.reloadData()
        }
        tableView.reloadData() // 상태바 갱신
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setInitialChatperList() {
        switch mySegment.selectedSegmentIndex {
        case 0: //전체학습
//            dbPath = Bundle.main.path(forResource: "questionlist", ofType:"sqlite")
            dbPath = questionPath
        case 1: //북마크보기
            dbPath = favoritePath
        default:
            return
        }

        if dbPath == nil {
            print("5712 DB Path is Null")
            return
        }
        
        guard let db = FMDatabase(path: dbPath) else {
            print("5712 DB Not Found")
            return
        }
        if !db.open() {
            print("5712 DB Can't Open")
            return
        }
        
        chapterList.chapterItems.removeAll()
        qnumberMaxTotal = 0 //총문항수
        
        chapterItems = ChapterItems()
        chapterItems?.chapter = "1"
        chapterItems?.chapterText = "민법일반"
        chapterList.chapterItems.append(chapterItems!)
        
        chapterItems = ChapterItems()
        chapterItems?.chapter = "2"
        chapterItems?.chapterText = "권리와 의무"
        chapterList.chapterItems.append(chapterItems!)
        
        chapterItems = ChapterItems()
        chapterItems?.chapter = "3"
        chapterItems?.chapterText = "자연인"
        chapterList.chapterItems.append(chapterItems!)
        
        chapterItems = ChapterItems()
        chapterItems?.chapter = "4"
        chapterItems?.chapterText = "법인"
        chapterList.chapterItems.append(chapterItems!)
        
        chapterItems = ChapterItems()
        chapterItems?.chapter = "5"
        chapterItems?.chapterText = "권리의 객체"
        chapterList.chapterItems.append(chapterItems!)
        
        chapterItems = ChapterItems()
        chapterItems?.chapter = "6"
        chapterItems?.chapterText = "권리변동"
        chapterList.chapterItems.append(chapterItems!)
        
        chapterItems = ChapterItems()
        chapterItems?.chapter = "7"
        chapterItems?.chapterText = "의사표시"
        chapterList.chapterItems.append(chapterItems!)
        
        chapterItems = ChapterItems()
        chapterItems?.chapter = "8"
        chapterItems?.chapterText = "법률행위의 대리"
        chapterList.chapterItems.append(chapterItems!)
        
        chapterItems = ChapterItems()
        chapterItems?.chapter = "9"
        chapterItems?.chapterText = "무효와 취소"
        chapterList.chapterItems.append(chapterItems!)
        
        chapterItems = ChapterItems()
        chapterItems?.chapter = "10"
        chapterItems?.chapterText = "조건과 기한"
        chapterList.chapterItems.append(chapterItems!)
        
        chapterItems = ChapterItems()
        chapterItems?.chapter = "11"
        chapterItems?.chapterText = "기간"
        chapterList.chapterItems.append(chapterItems!)
        
        chapterItems = ChapterItems()
        chapterItems?.chapter = "12"
        chapterItems?.chapterText = "소멸시효"
        chapterList.chapterItems.append(chapterItems!)
        
        for items in chapterList.chapterItems {
            items.examtype = "A"
            items.subject = "civillaw"

            let selectSQL = "SELECT COUNT(*) FROM questionlist where examtype = '\(items.examtype)' AND subject = '\(items.subject)' AND chapter = \(items.chapter) AND anumber = 0"
            guard let result = db.executeQuery(selectSQL, withArgumentsIn: nil) else {
                print("57122 Error: \(String(describing: db.lastErrorMessage()))")
                return
            }
            while result.next() {
                items.qnumberMax = Int(result.int(forColumnIndex: 0))
                qnumberMaxTotal = qnumberMaxTotal + items.qnumberMax
            }
        }
        
    }
    
    // MARK: - TABLEVIEW
    // 테이블 뷰의 섹션 갯수
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var sectionTitle: String = ""
        
        if section == 0 {
            sectionTitle = "전체 문제풀기"
        } else if section == 1 {
            sectionTitle = "단원별 문제풀기"
        } else {
            
        }
        
        return "\(sectionTitle)"
    }
    
    // 테이블 뷰의 셀 갯수
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var sectionCount: Int = 0
        
        if section == 0 {
            sectionCount = 1
        } else if section == 1 {
            sectionCount = chapterList.chapterItems.count
        } else {
            
        }
        
        return sectionCount
    }
    
    // 테이블 뷰의 셀에 표시할 내용
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionTableViewCell", for: indexPath) as! QuestionTableViewCell
        if indexPath.section == 0 {
            cell.myChapterLabel.text = "무작위 문제풀기"
            cell.myChapterCountLabel.text = String(qnumberMaxTotal)
            cell.myProgressView.isHidden = true
            cell.myProgressLabel.isHidden = true
        } else if indexPath.section == 1 {
            cell.myChapterLabel.text = "\(chapterList.chapterItems[indexPath.row].chapterText)"
            cell.myChapterCountLabel.text = "\(chapterList.chapterItems[indexPath.row].qnumberMax)"
            
            switch mySegment.selectedSegmentIndex {
            case 0: //전체학습
                cell.myProgressView.layer.cornerRadius = 3
                cell.myProgressView.clipsToBounds = true
                var progress:Float = 0
                if userDefautQuestionProgress[indexPath.row] != 0 {
                    progress = (userDefautQuestionProgress[indexPath.row] + 1) / Float(chapterList.chapterItems[indexPath.row].qnumberMax)
                }
                cell.myProgressView.progress = progress
                
//                if progress < 0 {
//                    cell.myProgressView.progress = 0
//                } else {
//                    cell.myProgressView.progress = progress
//                }
                cell.myProgressLabel.text = "\(Int(progress * 100))%"
                cell.myProgressView.isHidden = false
                cell.myProgressLabel.isHidden = false
            case 1: //북마크보기
                cell.myProgressView.isHidden = true
                cell.myProgressLabel.isHidden = true
            default:
                return cell
            }

            
        } else if indexPath.section == 2 {
            cell.myChapterLabel.text = ""
            cell.myChapterCountLabel.text = ""
        }
        let imageNamed = "s\(indexPath.section)r\(indexPath.row)Icon.png"
        cell.myChaterImageView.image  = UIImage(named: imageNamed)
        
        // 테이블 뷰 셀 선택시 배경 색상
        let backgroundView = UIView()
        backgroundView.backgroundColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        cell.selectedBackgroundView = backgroundView
        
        return cell
    }
    
    // MARK: - TABLEVIEW ACTION
    // 테이블 뷰에서 셀을 터치 하였을 경우 다른 화면에 값 전달
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueShowDetails" {
            guard let selectedIndexPath: [IndexPath] = self.tableView.indexPathsForSelectedRows else {
                return
            }
            self.tableView.deselectRow(at: selectedIndexPath[0], animated: true)
            
            let descVC = segue.destination as! MyDetailViewController
            let presVC = self.tableView.cellForRow(at: selectedIndexPath[0]) as! QuestionTableViewCell
            
            descVC.dbPath = dbPath //sqlite 파일 주소
            descVC.chapterName = presVC.myChapterLabel.text!
            
            descVC.examtype = "A" //시헝유형
            descVC.subject = "civillaw" //과목명
            if selectedIndexPath[0].section == 0 { //전체 문제풀기
                descVC.chapterNum = selectedIndexPath[0].row //단원
            } else if selectedIndexPath[0].section == 1 { // 단원별 문제풀기
                if dbPath == questionPath { // 전체학습일 경우(북마크보기가 아닐때)
                    if userDefautSwitchQuestionContinue { // 이어 보기
                        descVC.questionNum = Int(userDefautQuestionProgress[selectedIndexPath[0].row])
                    } else {
                        userDefautQuestionProgress[selectedIndexPath[0].row] = 0
                    }
                }
                descVC.chapterNum = selectedIndexPath[0].row + 1
            } else {
                return
            }
            self.navigationItem.title = "" // 다음화면의 뒤로가기에 < 만 표시
        }
        
    }
    
    @IBAction func mySegmentAction(_ sender: UISegmentedControl) {
        setInitialChatperList()
        tableView.reloadData()
    }
    
    @IBAction func unwindToTableViewController(segue:UIStoryboardSegue) {
//        tableView.reloadData()
//        print("5712 unwindToListTableViewController=\(segue)")
    }
    
}
