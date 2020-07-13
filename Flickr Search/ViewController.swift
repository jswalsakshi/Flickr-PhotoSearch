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
    
    //var footerView:CustomFooterView?
    var searches = FlickrSearchResults()
    let flickr = Flickr()
    var itemsPerRow: CGFloat = 3
    let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    var paging : Paging?
    var loadMore: Bool = false
    var selectedCellFrame: CGRect?
    var selectedIndexPath: IndexPath?
    let footerViewReuseIdentifier = "RefreshFooterView"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicatorView.isHidden = true
        self.setupCollectionView()
        // self.fetchSearchImages()
    }
    
    func photoForIndexPath(indexPath: IndexPath) -> FlickrPhoto {
        return searches.searchResults[(indexPath as NSIndexPath).row]
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    private func setupCollectionView() {
        self.photoCollectionView.register(UINib(nibName: PhotoCollectionViewCell.cellIdentifier, bundle: nil), forCellWithReuseIdentifier: PhotoCollectionViewCell.cellIdentifier)
        self.photoCollectionView.delegate = self
        self.photoCollectionView.dataSource = self
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searches.searchResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.cellIdentifier, for: indexPath) as! PhotoCollectionViewCell
        //         guard searchPhotos.count != 0 else {
        //                   return cell
        //               }
        //               let model = searchPhotos[indexPath.row]
        //               guard let mediaUrl = model.getImagePath() else {
        //                   return cell
        //               }
        //               let image = imageProvider.cache.object(forKey: mediaUrl as NSURL)
        //               cell.imgView_photo.backgroundColor = UIColor(white: 0.95, alpha: 1)
        //               cell.imgView_photo.image = image
        //               if image == nil {
        //                   imageProvider.requestImage(from :mediaUrl, completion: { (image) -> Void in
        //                       let indexPath_ = collectionView.indexPath(for: cell)
        //                       if indexPath == indexPath_ {
        //                           cell.imgView_photo.image = image
        //                       }
        //                   })
        //               }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let lastRowIndex = collectionView.numberOfItems(inSection: 0) - 1
        if indexPath.row == lastRowIndex && paging != nil {
            loadMorePhotos()
        }
        let flickrPhoto = photoForIndexPath(indexPath: indexPath)
        (cell as! PhotoCollectionViewCell).imgView_photo.image = #imageLiteral(resourceName: "placeholder")
        ImageDownloadManager.shared.downloadImage(flickrPhoto, indexPath: indexPath) { (image, url, indexPathh, error) in
            if let indexPathNew = indexPathh {
                DispatchQueue.main.async {
                    if let getCell = collectionView.cellForItem(at: indexPathNew) {
                        (getCell as? PhotoCollectionViewCell)!.imgView_photo.image = image
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        /* Reduce the priority of the network operation in case the user scrolls and an image is no longer visible. */
        if self.loadMore {return}
        let flickrPhoto = photoForIndexPath(indexPath: indexPath)
        ImageDownloadManager.shared.slowDownImageDownloadTaskfor(flickrPhoto)
    }
    
    // MARK: - Helper Method
    private func loadMorePhotos() {
        guard let searchText = self.searchBar.text, searchText.count > 0 else {
            return
        }
        if !loadMore && paging!.currentPage! < paging!.totalPages! {
            loadMore = true
            self.callSearchApi(searchText: searchText, pageNo: paging!.currentPage! + 1)
        }
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
    
    
    //compute the scroll value and play witht the threshold to get desired effect
    
}

//MARK: - SearchBar Delegate
extension ViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        searchBar.resignFirstResponder()
        
        //Reset old data first befor new search Results
        //resetValuesForNewSearch()
        
        self.loadMore = true
        guard let searchText = searchBar.text, searchText.count > 0 else {
            ImageDownloadManager.shared.cancelAll()
            self.searches.searchResults.removeAll()
            self.photoCollectionView?.reloadData()
            self.loadMore = false
            return
        }
        //searchTextField.startAnimating()
        self.callSearchApi(searchText: searchText, pageNo: 1)
    }
}

private typealias APIHandler = ViewController
extension APIHandler {
    func callSearchApi (searchText: String, pageNo: Int) {
        // use Flickr wrapper class to search Flickr for photos that match the given search term asynchronously
        // when search complets, the completion block will be called with the result set of FlickrPhoto objects and error (if there is one)
        flickr.searchFlickrForTerm(searchText, page: pageNo) { results, paging, error in
            
            //self.searchBar.stopAnimating()
            if let paging = paging, paging.currentPage == 1 {
                ImageDownloadManager.shared.cancelAll()
                self.searches.searchResults.removeAll()
                self.photoCollectionView?.reloadData()
            }
            
            if let error = error {
                // 2
                // log any errors to the console. In production display these errors to user
                print("Error searching: \(error)")
                return
            }
            
            if let results = results {
                // 3
                // results get logged and added to the front of the searches array
                print("Found \(results.searchResults.count) matching \(results.searchTerm)")
                self.searches.searchResults.append(contentsOf: results.searchResults)
                for photo in self.searches.searchResults {
                    print("URL:  \(photo.flickrImageURL()?.absoluteString ?? "")")
                }
                self.paging = paging
                self.photoCollectionView?.reloadData()
            }
            self.loadMore = false
        }
    }
}


//MARK: - Scrollview Delegate
extension ViewController: UIScrollViewDelegate {
    
    //MARK :- Getting user scroll down event here
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let threshold   = 100.0 ;
        let contentOffset = scrollView.contentOffset.y;
        let contentHeight = scrollView.contentSize.height;
        let diffHeight = contentHeight - contentOffset;
        let frameHeight = scrollView.bounds.size.height;
        var triggerThreshold  = Float((diffHeight - frameHeight))/Float(threshold);
        triggerThreshold   =  min(triggerThreshold, 0.0)
        let pullRatio  = min(abs(triggerThreshold),1.0);
        //        self.footerView?.setTransform(inTransform: CGAffineTransform.identity, scaleFactor: CGFloat(pullRatio))
        //        if pullRatio >= 1 {
        //            self.footerView?.animateFinal()
        //        }
        print("pullRatio:\(pullRatio)")
    }
    
    //compute the offset and call the load method
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset.y;
        let contentHeight = scrollView.contentSize.height;
        let diffHeight = contentHeight - contentOffset;
        let frameHeight = scrollView.bounds.size.height;
        let pullHeight  = abs(diffHeight - frameHeight);
        print("pullHeight:\(pullHeight)");
        if pullHeight == 0.0
        {
            //            if (self.footerView?.isAnimatingFinal)! {
            //                print("load more trigger")
            //                self.footerView?.startAnimate()
            //            }
        }
    }
}

