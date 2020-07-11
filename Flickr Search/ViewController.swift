//
//  ViewController.swift
//  Flickr Search
//
//  Created by Sakshi Jaiswal on 10/07/20.
//  Copyright © 2020 Sakshi Jaiswal. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var imageResponseModel: PhotosClass?
    let queryService = SessionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicatorView.isHidden = true
        self.setupCollectionView()
        self.callAPIforSongList()
        }
    }

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    private func setupCollectionView() {
        self.photoCollectionView.register(UINib(nibName: PhotoCollectionViewCell.cellIdentifier, bundle: nil), forCellWithReuseIdentifier: PhotoCollectionViewCell.cellIdentifier)
//        if #available(iOS 11.0, *) {
//            self.collectionView_notesType.contentInsetAdjustmentBehavior = .always
//        } else {
//            // Fallback on earlier versions
//        }
        //self.updateCollectionViewLayout()
        self.photoCollectionView.delegate = self
        self.photoCollectionView.dataSource = self
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.cellIdentifier, for: indexPath) as! PhotoCollectionViewCell
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ViewController: UICollectionViewDelegateFlowLayout {
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 8
        let size = UIScreen.main.bounds.width/2 - 3*padding/2
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
}

private typealias APIHandler = ViewController
extension APIHandler {
    func callAPIforSongList() {
//        guard let searchText = "Home", !artistName.isEmpty else {
//            return self.showToast(message: "Please Enter Artist Name", font: .systemFont(ofSize: 12.0))
//        }
//        SessionManager.sharedInstance.getServerData(searchText: "home", pageCount: 1, completionHandler: { (true, error, response, data) in
//            self.imageResponseModel = response?.photos
           // self.results.removeAll()
//            let listData = response?.results
//            listData?.forEach({ (order) in
//                self.results.append(order)
//            })
//            self.hideUnhideSearchBtn()
//            self.photoCollectionView.reloadData()
        
        queryService.getSearchResults(searchText: "Home", pageCount: 1) { (response, errormsg) in
            print(response?.first)
        }
        
        }
//    )}
}
