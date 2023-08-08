//
//  ViewController.swift
//  sesac-day16-lottery-api
//
//  Created by Gyeoul on 2023/08/08.
//

import UIKit
import SwiftyJSON
import Alamofire

struct Lotto {
    let id:Int
    let drawDate:String
    let sellAmount: Int
    let drawNum:[Int]
    let bonusNumber:Int
    let prize:Int
    let prizewinner:Int
}

class ViewController: UIViewController {
    @IBOutlet var labelGroup: [UILabel]! {
        didSet {
            labelGroup.sort {
                $0.tag < $1.tag
            }
        }
    }
    @IBOutlet var bonus: UILabel!
    @IBOutlet var textField: UITextField!
    @IBOutlet var lottoInfoLabel: UILabel!
    var list = Array(Array(1...1079).reversed())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "당첨번호 조회"
        setDefault()
        fetchData(drawNumber: list[0])
        textField.text = "\(list[0])회"
    }

    func fetchData(drawNumber:Int) {
        let url = "https://www.dhlottery.co.kr/common.do?method=getLottoNumber&drwNo=\(drawNumber)"
        AF.request(url, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                if json["returnValue"].stringValue == "fail"{
                    return
                }
                print("JSON: \(json)")
                var drawNums:[Int] = []
                for i in 1...6 {
                    drawNums.append(json["drwtNo\(i)"].intValue)
                }
                self.setData(lotto: Lotto(id: drawNumber, drawDate: json["drwNoDate"].stringValue, sellAmount: json["totSellamnt"].intValue, drawNum: drawNums, bonusNumber: json["bnusNo"].intValue, prize: json["firstWinamnt"].intValue, prizewinner: json["firstPrzwnerCo"].intValue))
            case .failure(let error):
                print(error)
                return
            }
        }
    }
    
    func setDefault() {
        for v in labelGroup {
            v.textColor = .white
            v.layer.cornerRadius = v.frame.height / 2
            v.clipsToBounds = true
        }
        bonus.textColor = .white
        bonus.layer.cornerRadius = bonus.frame.height / 2
        bonus.clipsToBounds = true
        textField.tintColor = .clear
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        textField.inputView = pickerView
        dismissPickerView()
    }
    
    func setData(lotto:Lotto) {
        for i in 0...lotto.drawNum.count-1 {
            labelGroup[i].text = "\(lotto.drawNum[i])"
            labelGroup[i].backgroundColor = getBallBackgroundColor(lotto.drawNum[i])
        }
        bonus.text = "\(lotto.bonusNumber)"
        bonus.backgroundColor = getBallBackgroundColor(lotto.bonusNumber)
        lottoInfoLabel.text = "\(lotto.drawDate) • 1등: \(lotto.prizewinner)명"
    }
    
    func getBallBackgroundColor(_ num:Int) -> UIColor {
        switch Int(num/10) {
        case 0:
            return .systemYellow
        case 1:
            return .systemBlue
        case 2:
            return .systemRed
        case 3:
            return .black
        case 4:
            return .systemGreen
        default:
            return .clear
        }
    }
    
    
    func dismissPickerView() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let button = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(endEdit))
        toolBar.setItems([button], animated: true)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
    }
    
    @objc func endEdit() {
        view.endEditing(true)
    }
}

extension ViewController: UIPickerViewDelegate,UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return list.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(list[row])회"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        fetchData(drawNumber: list[row])
        textField.text = "\(list[row])회"
    }
}
