import Firebase
import FirebaseStorage

//MARK -Auth
extension Auth {
    static func createUserToFireAuth(email: String?, password: String?, name: String?, completion: @escaping (Bool) -> Void) {
        guard let email = email else { return }
        guard let password = password else { return }
        Auth.auth().createUser(withEmail: email, password: password) { (auth, err) in
            if let err = err {
                print("auth情報の保存に失敗　", err)
                return
            }
            guard let uid = auth?.user.uid else { return }
            Firestore.setUserDataToFierStore(email: email, uid: uid, name: name) { success in
                completion(success)
            }
        }
    }
    
    static func loginWithFireAuth(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (res, err) in
            if let err = err {
                print("ログインに失敗: ", err)
                completion(false)
                return
            }
            print("ログインに成功")
            completion(true)
        }
    }
}
//MARK -FireStore
extension Firestore {
    static func setUserDataToFierStore(email: String, uid: String, name: String?, completion: @escaping (Bool) -> ()) {
        guard let name = name else { return }
        let document = ["name": name, "email": email, "createdAt": Timestamp(), "uid": uid] as [String : Any]
        
        Firestore.firestore().collection("users").document(uid).setData(document) { err in
            if let err = err {
                print("ユーザー情報のfireStoreへの保存に失敗：　", err)
                return
            }
            completion(true)
            print("ユーザー情報のforestoreへの保存が成功")
        }
    }
    
    //firestoreからユーザーの情報を取得
    static func fetchUserFromFirestore(uid: String, completion: @escaping (User?) -> Void) {
        Firestore.firestore().collection("users").document(uid).addSnapshotListener { (snapshot, err) in
            if let err = err {
                print("ユーザー情報の取得に失敗：　", err)
                completion(nil)
                return
            }
            
            guard let dic = snapshot?.data() else { return }
            let user = User(dic: dic)
            completion(user)
        }
    }
    
    //firestoreから自分以外のユーザーの情報を取得
    static func fetchUsersFromFirestore(completion: @escaping ([User]) -> Void) {
        Firestore.firestore().collection("users").getDocuments { (snapshots, err) in
            if let err = err {
                print("ユーザー情報の取得に失敗：　", err)
            }
            let users = snapshots?.documents.map({ snapshot -> User in
                let dic = snapshot.data()
                let user = User(dic: dic)
                return user
            })
            let filterdUsers = users?.filter({ user -> Bool in
                return user.uid != Auth.auth().currentUser?.uid
            })
            completion(filterdUsers ?? [User]())
        }
    }
    
    //ユーザー情報の更新
    static func updateUserInfo(dic: [String: Any], completion: @escaping () -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(uid).updateData(dic) { err in
            if let err = err {
                print("ユーザー情報の更新に失敗", err)
                return
            }
            completion()
            print("ユーザー情報の更新に成功")
        }
    }
}

//MARK -Storage
extension Storage {
    //ユーザーの情報をFireStorageに保存
    static func addProfileImageToStorage(image: UIImage, dic: [String: Any], completion: @escaping () -> Void) {
        guard let uploadImage = image.jpegData(compressionQuality: 0.3) else { return }
        let filename = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_image").child(filename)
        
        storageRef.putData(uploadImage, metadata: nil) { metaData, error in
            if let err = error {
                print("画像の保存に失敗しました。　", err)
                return
            }
            storageRef.downloadURL { url, error in
                if let err = error {
                    print("画像の取得に失敗しました。　", err)
                }
                
                guard let urlString = url?.absoluteString else { return }
                var dicWithImage = dic
                dicWithImage["profileImageUrl"] = urlString
                
                Firestore.updateUserInfo(dic: dicWithImage) {
                    completion()
                }
            }
        }
    }
}
