//
//  ViewController.swift
//  JSLTransitionLib
//
//  Created by jason_lee_92@yahoo.com on 04/22/2019.
//  Copyright (c) 2019 jason_lee_92@yahoo.com. All rights reserved.
//

import UIKit
import JSLTransitionLib

enum DemoType {
    case normal, semi, presentTo
}

class DemoViewController: UIViewController {

    private struct SourceData {
        let title: String
        let type: DemoType
    }

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "CELL")
        return tableView
    }()

    private lazy var sourceDatas: [SourceData] = {
        let rawValue: [[DemoType: String]] = [
            [.normal: "普通类型自定义转场"],
            [.semi: "半弹窗类型自定义转场"],
            [.presentTo: "上滑模态推出下一页面"]
        ]

        var sourceDatas: [SourceData] = []
        rawValue.forEach({ data in
            sourceDatas.append(SourceData(title: data.values.first!, type: data.keys.first!))
        })

        return sourceDatas
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.frame = view.bounds
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension DemoViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sourceDatas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELL", for: indexPath)
        cell.textLabel?.text = sourceDatas[indexPath.row].title
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let fistViewController = FirstViewController()
        fistViewController.type = sourceDatas[indexPath.row].type
        fistViewController.title = sourceDatas[indexPath.row].title

        let navi = UINavigationController(rootViewController: fistViewController)
        navi.presentationTransitioningDelegateS = ViewControllerTransitionDelegate(presentedViewController: navi)
        self.present(navi, animated: true, completion: nil)
    }

}

