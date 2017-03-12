
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

class ExploreCollectionViewController: UICollectionViewController {
    
    var objectImagePair = [(AVObject, AVFile)]()
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        print("hey there")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func __loadData(){
        self.objectImagePair = []
        let query = AVQuery(className: "Posts")
        query.addDescendingOrder("likes")
        query.findObjectsInBackground({ (results, error) in
            if error==nil {
                if let posts = results as? [AVObject] {
                    for post in posts {
                        if  post["Image"] == nil{
                            print("    CHECK THIS LOL NIL )")
                        }else{
                            self.objectImagePair.append((post,post["Image"] as! AVFile))
                        }
                    }
                    self.objectImagePair.shuffle()
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
        return self.objectImagePair.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = self.collectionView?.dequeueReusableCell(withReuseIdentifier: "exploreCollectionViewCell", for: indexPath) as! ExploreCollectionViewCell

        let object = self.objectImagePair[indexPath.row].0
        cell.postObject = object
        
        let file = self.objectImagePair[indexPath.row].1
        file.getDataInBackground { (data:Data?, error:Error?) in
            if error==nil{
                cell.imageToShow.image = UIImage(data: data!)
            }else{
                print(error!.localizedDescription)
            }
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = self.collectionView?.cellForItem(at: indexPath) as! ExploreCollectionViewCell
        let object = cell.postObject
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "postDetailVC") as! PostDetailViewController
        vc.postObject = object
        self.navigationController?.pushViewController(vc, animated: true)
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
