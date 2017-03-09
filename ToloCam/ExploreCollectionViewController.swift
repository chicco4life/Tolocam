
import UIKit
//import Parse
//import Bolts
//import ParseUI
import AVOSCloud

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Iterator.Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}

extension MutableCollection where Indices.Iterator.Element == Index {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled , unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            guard d != 0 else { continue }
            let i = index(firstUnshuffled, offsetBy: d)
            swap(&self[firstUnshuffled], &self[i])
        }
    }
}

class ExploreCollectionViewController: UICollectionViewController,UIViewControllerPreviewingDelegate {

    var imageFiles = [AVFile]()
    let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let attributes = [
            NSForegroundColorAttributeName: UIColor(red: 253/255, green: 104/255, blue: 134/255, alpha: 0.9),
            NSFontAttributeName : UIFont(name: "PingFangSC-Medium", size: 20)! // Note the !
        ]
        
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        
        self.tabBarController?.tabBar.backgroundImage = UIImage(named: "#FFFFFF")
        
        //pull to refresh
        self.collectionView?.addSubview(refreshControl)
        self.refreshControl.addTarget(self, action: #selector(ExploreCollectionViewController.__refreshPulled), for: UIControlEvents.valueChanged)
        self.refreshControl.isUserInteractionEnabled = true
        self.collectionView?.alwaysBounceVertical = true
        
        //for auto resizing collection view cells
        let screenWidth = UIScreen.main.bounds.size.width
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: (screenWidth-2) / 3, height: (screenWidth-2) / 3)
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        self.collectionView!.collectionViewLayout = layout
        
        
//        _ = UICollectionView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight), collectionViewLayout: layout)
        
        print("collectionviewdidload is called")
        if (traitCollection.forceTouchCapability == .available){
            registerForPreviewing(with: self, sourceView: view)
        }
        
        __loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.backgroundImage = UIImage(named: "#FFFFFF")
    }
    
    func __refreshPulled() {
        self.__loadData()
        self.collectionView?.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let indexPath = collectionView?.indexPathForItem(at: location) else {return nil}
        guard (collectionView?.cellForItem(at: indexPath)) != nil else {return nil}
        //        guard let detailVC = storyboard?.instantiateViewControllerWithIdentifier("PostDetailVC") as? PostDetailViewController else {return nil}
        return self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("hey there")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func __loadData(){
        self.imageFiles = []
        let query = AVQuery(className: "Posts")
        query.addDescendingOrder("likes")
        query.findObjectsInBackground({ (results, error) in
            if error==nil {
                if let posts = results as? [AVObject] {
                    for post in posts {
                        if  post["Image"] == nil{
                            print("    CHECK THIS LOL NIL )")
                        }else{
                            print("    CHECK THIS LOL \(post["Image"])")
                            let imageToLoad = post["Image"]! as! AVFile
                            self.imageFiles.append(imageToLoad)
                        }
                    }
                    self.imageFiles.shuffle()
                    self.collectionView?.reloadData()
                }
            } else {
                if error!.localizedDescription == "The Internet connection appears to be offline."{
                    let alertController = UIAlertController(title:"Error", message:"The Internet connection appears to be offline. Please try again later.", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title:"OK", style: .cancel, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
            
        })
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageFiles.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView?.dequeueReusableCell(withReuseIdentifier: "exploreCollectionViewCell", for: indexPath) as! ExploreCollectionViewCell
        let imageFile = self.imageFiles[indexPath.row]
        imageFile.getDataInBackground({ (data:Data?, error:Error?) in
            if error == nil{
                cell.imageToShow.image = UIImage(data: data!)!
            }else{
                print(error!)
            }
        }) { (progress) in
            //progress
        }
        return cell
    }
    
    /*override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.size.width-4) / 3, height: (UIScreen.main.bounds.size.width-4) / 3)
    }*/
    
    
    /*
     // MARK: - Navigation
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
