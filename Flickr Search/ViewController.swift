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
    
    fileprivate var searchPhotos = [Photo]()
    fileprivate let router = Router()
    fileprivate var pageCount = 0
    fileprivate let imageProvider = ImageProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicatorView.isHidden = true
        self.setupCollectionView()
        self.fetchSearchImages()
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
        return searchPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.cellIdentifier, for: indexPath) as! PhotoCollectionViewCell
         guard searchPhotos.count != 0 else {
                   return cell
               }
               let model = searchPhotos[indexPath.row]
               guard let mediaUrl = model.getImagePath() else {
                   return cell
               }
               let image = imageProvider.cache.object(forKey: mediaUrl as NSURL)
               cell.imgView_photo.backgroundColor = UIColor(white: 0.95, alpha: 1)
               cell.imgView_photo.image = image
               if image == nil {
                   imageProvider.requestImage(from :mediaUrl, completion: { (image) -> Void in
                       let indexPath_ = collectionView.indexPath(for: cell)
                       if indexPath == indexPath_ {
                           cell.imgView_photo.image = image
                       }
                   })
               }
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


//MARK: - SearchBar Delegate
extension ViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        searchBar.resignFirstResponder()
        
        //Reset old data first befor new search Results
        resetValuesForNewSearch()
        
        guard let text = searchBar.text,
            text.count != 0  else {
              //  labelLoading.text = "Please type keyword to search result."
                return
        }
        
        //Requesting here new keyword
        fetchSearchImages()
        
       // labelLoading.text = "Searching Images..."
    }
    
    //MARK: - Clearing here old data search results with current running tasks
    func resetValuesForNewSearch(){
        pageCount = 0
        router.cancelTask()
        searchPhotos.removeAll()
        self.photoCollectionView.reloadData()
    }
}

private typealias APIHandler = ViewController
extension APIHandler {
    func fetchSearchImages(){
        pageCount+=1   //Count increment here
        
        router.requestFor(text: searchBar.text ?? "home", with: pageCount.description, decode: { json -> Photos? in
            guard let flickerResult = json as? Photos else { return  nil }
            return flickerResult
        }) { [unowned self] result in
            DispatchQueue.main.async {
                //self.labelLoading.text = ""
                switch result{
                case .success(let value):
                    self.updateSearchResult(with: value.photos.photo)
                case .failure(let error):
                    print(error.debugDescription)
                    guard self.router.requestCancelStatus == false else { return }
//                    self.showAlertWithError((error?.localizedDescription) ?? "Please check your Internet connection or try again.", completionHandler: {[unowned self] status in
//                        guard status else { return }
//                        self.fetchSearchImages()
//                    })
                }
            }
        }
    }
    
    //MARK: - Handle response result
    func updateSearchResult(with photo: [Photo]){
        DispatchQueue.main.async { [unowned self] in
            let newItems = photo
            self.searchPhotos.append(contentsOf: newItems)
            self.photoCollectionView.reloadData()
        }
    }
}


//MARK: - Scrollview Delegate
extension ViewController: UIScrollViewDelegate {
    
    //MARK :- Getting user scroll down event here
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == photoCollectionView{
            if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= (scrollView.contentSize.height)){
                
                //Start locading new data from here
                fetchSearchImages()
            }
        }
    }
}

