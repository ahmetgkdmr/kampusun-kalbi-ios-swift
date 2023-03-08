
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class AnaVC: UIViewController {

    
    @IBOutlet weak var sgmntKategoriler: UISegmentedControl!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    private var fikirler = [Fikir]()
    private var fikirlerCollectionRef : CollectionReference!
    private var fikirlerListener : ListenerRegistration! // sürekli dinleme yapmak için güncellenen dataları anında alır.
    private var secilenKategori = Kategoriler.Dersler.rawValue
    
    private var listenerHandle : AuthStateDidChangeListenerHandle? // kullanıcı giriş yaptı mı anlamak için handler oluşturduk.
    
    // Sayfa ilk yüklendiğinde
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self // yetkilendirme
        tableView.dataSource = self // yetkilendirme
        
        fikirlerCollectionRef = Firestore.firestore().collection(Fikirler_REF)
        
    }

    // sayfa kapatıldığında
    override func viewWillDisappear(_ animated: Bool) {
        
        if fikirlerListener != nil {
        
            fikirlerListener.remove() // sayfa kapandığında sunucuyu sürekli olarak kontrol edip boşyere kaynak tüketmez.
            
        }
        
    }
    
    // Sayfa her gözüktüğünde
    override func viewWillAppear(_ animated: Bool) {
    
        // kullanıcı var mı yok mu kontrolü yapar.
        listenerHandle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            
            if user == nil {
                // Kullanıcı yoksa giriş sayfasına yönlendiriyoruz.
                print("Kullanıcı yok")
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let girisVC = storyboard.instantiateViewController(withIdentifier: "GirisVC")
                self.present(girisVC, animated: true, completion: nil)
                
            } else {
                
                self.setListener()
                
            }
            
        })
        
    }
    
    func setListener() {
        
        if secilenKategori == Kategoriler.Populer.rawValue{
            
            
            
            // Listener oluşturduk. Değişiklikleri anlık olarak alabilmek için (addSnapshotListener)
            fikirlerListener = fikirlerCollectionRef.yeniWhereSorgum()
                .addSnapshotListener { (snapshot, error) in
                
                if let error = error {
                    
                    debugPrint("Kayıtları Getirirken Hata Meydana Geldi : \(error.localizedDescription)")
                    
                } else {
                    
                    self.fikirler.removeAll() // verileri çoklamaması için
                    self.fikirler = Fikir.fikirGetir(snapshot: snapshot,begeniyeGore: true)
                    self.tableView.reloadData()
                    
                }
                
            }
            
        } else {
            
            // Listener oluşturduk. Değişiklikleri anlık olarak alabilmek için (addSnapshotListener)
            fikirlerListener = fikirlerCollectionRef.whereField(KATEGORI, isEqualTo: secilenKategori) // Db den gelen verilerin kategoriye göre filtrelenmesi
                .order(by: Eklenme_Tarihi, descending: true)
                .addSnapshotListener { (snapshot, error) in
                
                if let error = error {
                    
                    debugPrint("Kayıtları Getirirken Hata Meydana Geldi : \(error.localizedDescription)")
                    
                } else {
                    
                    self.fikirler.removeAll() // verileri çoklamaması için
                    self.fikirler = Fikir.fikirGetir(snapshot: snapshot)
                    self.tableView.reloadData()
                    
                }
                
            }
            
        }
        
    }
    
    
    // kategori değiştiğinde tetiklenir.
    @IBAction func kategoriChanged(_ sender: Any) {
        
        switch sgmntKategoriler.selectedSegmentIndex {
            
        case 0 :
            secilenKategori = Kategoriler.Dersler.rawValue
        case 1 :
            secilenKategori = Kategoriler.Etkinlikler.rawValue
        case 2 :
            secilenKategori = Kategoriler.Kampus.rawValue
        case 3 :
            secilenKategori = Kategoriler.Populer.rawValue
        default :
            secilenKategori = Kategoriler.Dersler.rawValue
            
        }
        
        fikirlerListener.remove()
        setListener() // Kategori değiştikten sonra tekrar bağlantı sağlamamız gerekiyor
        
    }
    
    // Oturumu kapatır.
    @IBAction func btnOturumKapatPressed(_ sender: Any) {
        
        let firebaseAuth = Auth.auth()
        do {
            
            try firebaseAuth.signOut()
        }
        catch let oturumHatasi as NSError {
            
            debugPrint("Oturum Kapatılırken Hata Meydana Geldi : \(oturumHatasi.localizedDescription)")
            
        }
        
    }
    
    // Yorumlar sayfasına geçiş yapar.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        if segue.identifier == "YorumlarSegue" {
            
            if let hedefVC = segue.destination as? YorumlarVC {
                
                if let secilenFikir = sender as? Fikir {
                    
                    hedefVC.secilenFikir = secilenFikir
                    
                }
                
            }
            
        }
        
    }
    
    
}

extension AnaVC : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fikirler.count
    }
    
    // Fikirlerin listelendiği hücrede gösterilcek değerleri gönderir.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FikirCell", for: indexPath) as? FikirCell {
            
            cell.gorunumAyarla(fikir: fikirler[indexPath.row],delegate: self)
            return cell }
        else {
            return UITableViewCell()
        }
            
    }
    
    //TableViewda bir alan seçildiğinde ona ait yorumların bulunduğu sayfaya gider.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "YorumlarSegue", sender: fikirler[indexPath.row])
    }
    
    
    
}

extension AnaVC : FikirDelegate {
    
    func seceneklerFikirPressed(fikir: Fikir) {
        
        let alert = UIAlertController(title: "Sil", message: "Paylaşımınızı silmek mi istiyorsunuz?", preferredStyle: .actionSheet)
        let silAction = UIAlertAction(title: "Paylaşımı Sil", style: .default) { (action) in
            
            //fikirler silinecek
            
            let yorumlarCollRef = Firestore.firestore().collection(Fikirler_REF).document(fikir.documentId).collection(YORUMLAR_REF)
            
            let begenilerCollRef = Firestore.firestore().collection(Fikirler_REF).document(fikir.documentId).collection(BEGENI_REF)
            
            // Fikir silinirker ona ait tüm yorumları ve beğenileri de sildik. Sadece fikir silersek onun altındaki subcollectionları silemeyiz.
            self.topluKayitSil(collectionRef: begenilerCollRef, completion: { (hata) in
                
                if let hata = hata {
                    debugPrint("Beğenileri silerken hata meydana geldi : \(hata.localizedDescription)")
                } else {
                    
                    self.topluKayitSil(collectionRef: yorumlarCollRef, completion: { (hata) in
                        
                        if let hata = hata {
                            debugPrint("Fikir silinirken ona ait yorumları silerken hata meydana geldi : \(hata.localizedDescription)")
                        } else {
                            // eğer yorum ve beğenileri silerken hata meydana gelmediyse fikri sildik.ş
                            Firestore.firestore().collection(Fikirler_REF).document(fikir.documentId).delete { (hata) in
                                
                                if let hata = hata {
                                    debugPrint("Fikir Silinirken Hata Meydana Geldi : \(hata.localizedDescription)")
                                    
                                } else {
                                    alert.dismiss(animated: true, completion: nil)
                                }
                                
                            }
                        }
                        
                    })
                }
            })
            
        }
        let iptalAction = UIAlertAction(title: "İptal Et", style: .cancel, handler: nil)
        
        alert.addAction(silAction)
        alert.addAction(iptalAction)
        present(alert,animated: true, completion: nil)
        
    }
    
    // limit ile 100 er 100 er sildik. Topluca hepsi silinmedi.
    func topluKayitSil(collectionRef : CollectionReference, silinecekKayitSayisi : Int = 100, completion : @escaping (Error?) -> ()){
        
        // verileri 100 er 100 er çektik.
        collectionRef.limit(to: silinecekKayitSayisi).getDocuments { (kayitSetleri, hata) in
            
            guard let kayitSetleri = kayitSetleri else {
                completion(hata)
                return
            }
            
            // kayitsetleri içinde herhangi bir data kalmadıysa silmeye gerek yok. Silincek yorum sayısı bittiğinde durur.
            guard kayitSetleri.count > 0 else {
                completion(nil)
                return
            }
            
            // birden fazla döküman için işlem yaptığımızdan batch kullandık.
            let batch = collectionRef.firestore.batch()
            
            kayitSetleri.documents.forEach {batch.deleteDocument($0.reference)} // silinme kısmı
            
            batch.commit { (batchHata) in // veritabanına yansıtmak commit
                
                if let hata = batchHata {
                    completion(hata)
                } else {
                    self.topluKayitSil(collectionRef: collectionRef, silinecekKayitSayisi: silinecekKayitSayisi, completion: completion)
                }
                
                
            }
            
        }
        
    }
    
}
