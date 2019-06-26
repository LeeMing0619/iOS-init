//
// Copyright (c) 2016 Elias
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

class FUser: FObject {
    
    var image: UIImage? = nil
// Class Functions
    class func imageNameWithDate() -> String{
        let interval = NSDate().timeIntervalSince1970;
        let userId = FUser.currentId()
        return userId + "/profile/\(interval).jpg"
    }
    
    class func currentId() -> String {
        if FIRAuth.auth()!.currentUser == nil {
            return "";
        }
        return FIRAuth.auth()!.currentUser!.uid
    }

    class func currentUser() -> FUser? {
        if FIRAuth.auth()!.currentUser != nil {
            let dictionary: [NSObject : AnyObject]? = NSUserDefaults.standardUserDefaults().objectForKey(Constant.StandardDefault.CURRENTUSER) as? [NSObject: AnyObject]
            if dictionary != nil {
                return FUser(path: Constant.Firebase.User.PATH, dictionary: dictionary!)
            }
        }
        return nil
    }

    class func updateCurrentUser(loginMethod: String) -> Void {
        let user: FUser = FUser.currentUser()!
        var update: Bool = false;
        
        if user[Constant.Firebase.User.NAME_LOWER] == nil {
            update = true
            user[Constant.Firebase.User.NAME_LOWER] = user[Constant.Firebase.User.NAME]!.lowercaseString
        }
        
        if user[Constant.Firebase.User.LOGINMETHOD] == nil {
            update = true
            user[Constant.Firebase.User.LOGINMETHOD] = loginMethod
        }
        
        if update {
            user.saveInBackground()
        }
    }
    
    class func userWithId(userId: String) -> FUser? {
        let user: FUser = FUser(path: Constant.Firebase.User.PATH)
        user[Constant.Firebase.OBJECTID] = userId
        return user
    }

    class func signInWithEmail(email: String, password: String, completion: (user: FUser?, error: NSError?) -> Void) {
        FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { (user: FIRUser?, error: NSError?) in
            if error == nil {
                FUser.load(user, completion: { (user, error) in
                    if error == nil {
                        completion(user: user, error: nil)
                    }
                    else {
                        try! FIRAuth.auth()!.signOut()
                        completion(user: nil, error: error)
                    }
                })
            }
            else {
                completion(user: nil, error: error)
            }
        })
    }

    class func createUserWithEmail(email: String, password: String, name: String, completion: (user: FUser?, error: NSError?) -> Void) {
        FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: { (firuser: FIRUser?, error: NSError?) in
            if error == nil {
                FUser.create(firuser!.uid, email: email, name: name, picture: nil, completion: { (user, error) in
                    if error == nil {
                        completion(user: user, error: nil)
                    }
                    else {
                        firuser?.deleteWithCompletion({ (error: NSError?) in
                            if error != nil {
                                try! FIRAuth.auth()?.signOut()
                            }
                        })
                        completion(user: nil, error: error)
                    }
                })
            }
            else {
                completion(user: nil, error: error)
            }
        })
    }

    class func signInWithCredential(credential: FIRAuthCredential, completion: (user: FUser?, error: NSError?) -> Void) {
        FIRAuth.auth()?.signInWithCredential(credential, completion: { (firuser: FIRUser?, error: NSError?) in
            if error == nil{
                FUser.load(firuser, completion: { (user, error) in
                    if error == nil {
                        completion (user: user, error: nil)
                    }
                    else {
                        try! FIRAuth.auth()?.signOut()
                        completion (user: nil, error: error)
                    }
                })
            }
            else {
                completion(user: nil, error: error)
            }
        })
    }

    class func signInWithFacebook(viewController: UIViewController, completion: (user: FUser?, error: NSError?) -> Void) {
#if FACEBOOK_LOGIN_ENABLED
        var login: FBSDKLoginManager = FBSDKLoginManager()
        var permissions: [AnyObject] = ["public_profile", "email", "user_friends"]
        login.logInWithReadPermissions(permissions, fromViewController: viewController, handler: {(result: FBSDKLoginManagerLoginResult, error: NSError?) -> Void in
            if error == nil {
                if result.isCancelled == false {
                    var accessToken: String = FBSDKAccessToken.currentAccessToken().tokenString
                    var credential: FIRAuthCredential = FIRFacebookAuthProvider.credentialWithAccessToken(accessToken)
                    self.signInWithCredential(credential, completion: completion)
                }
                else if completion != nil {
                    completion(nil, nil)
                }
            }
            else if completion != nil {
                completion(nil, error)
            }

        })
#else
    completion(user: nil, error: NSError(domain: "Facebook Login is not enabled", code: 100, userInfo: nil))
#endif
    }
    
    class func load(firuser: FIRUser?, completion: (user: FUser?, error: NSError?) -> Void) {
        let user = FUser.userWithId(firuser!.uid)
        user!.fetchInBackground({ (error: NSError?) in
            if error != nil {
                self.create(firuser!.uid, email: firuser!.email, name: firuser!.displayName, picture: firuser!.photoURL!.absoluteString, completion: completion)
            }
            else {
                completion(user: user, error: nil)
            }
        })
    }

    class func create(uid: String, email: String?, name: String?, picture: String?, completion: (user: FUser?, error: NSError?) -> Void) {
        let user = FUser.userWithId(uid)
        
        if email != nil {
            user![Constant.Firebase.User.EMAIL] = email
        }
        if name != nil {
            user![Constant.Firebase.User.NAME] = name
        }
        if picture != nil {
            user![Constant.Firebase.User.PICTURE] = picture
        }
        if Manager.sharedInstance.userAddress != nil {
            user!.address = Manager.sharedInstance.userAddress
        }
        
        user?.saveInBackground({ (error: NSError?) in
            if error == nil {
                completion(user: user, error: nil)
            }
            else {
                completion(user: nil, error: error)
            }
        })
    }
    
    class func logOut() -> Bool {
        do{
            try FIRAuth.auth()?.signOut()
            NSUserDefaults.standardUserDefaults().removeObjectForKey(Constant.StandardDefault.CURRENTUSER)
            NSUserDefaults.standardUserDefaults().synchronize()
            return true
        }catch{
            print("Error while signing out!")
        }
        return false
    }
    
    func isCurrent() -> Bool {
        return (self[Constant.Firebase.OBJECTID] as! String == FUser.currentId())
    }
    
    func saveLocalIfCurrent() {
        if self.isCurrent() {
            NSUserDefaults.standardUserDefaults().setObject(self.dictionary, forKey: Constant.StandardDefault.CURRENTUSER)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
//Override Functions
    override func saveInBackground() {
        self.saveLocalIfCurrent()
        super.saveInBackground()
    }

    override func saveInBackground(block: ((NSError?) -> Void)?) {
        self.saveLocalIfCurrent()
        
        super.saveInBackground({ (error: NSError?) in
            if error == nil {
                self.saveLocalIfCurrent()
            }
            if block != nil{
                block!(error)
            }
        })
    }
    
    override func fetchInBackground() {
        super.fetchInBackground { (error: NSError?) in
            if error == nil {
                self.saveLocalIfCurrent()
                
            }
        }
    }

    override func fetchInBackground(block: ((NSError?) -> Void)?) {
        super.fetchInBackground { (error: NSError?) in
            if error == nil {
                self.saveLocalIfCurrent()
            }
            if block != nil {
                block!(error)
            }
        }
    }
}

// Direct Access Extension
extension FUser {
    class func name() -> String? {
        return FUser.currentUser()!.name()
    }
    
    class func picture() -> String? {
        return FUser.currentUser()!.picture()
    }
    
    class func loginMethod() -> String? {
        return FUser.currentUser()!.loginMethod()
    }

    func name() -> String? {
        return self[Constant.Firebase.User.NAME] as? String
    }
    
    func picture() -> String? {
        return self[Constant.Firebase.User.PICTURE] as? String
    }
    
    func loginMethod() -> String? {
        return self[Constant.Firebase.User.LOGINMETHOD] as? String
    }
    
    var address: String? {
        get{
            return self[Constant.Firebase.User.ADDRESS] as? String
        }
        set{
            self[Constant.Firebase.User.ADDRESS] = newValue
        }
    }
}

