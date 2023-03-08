
import Foundation
import Firebase

extension Query {
    
    func yeniWhereSorgum () -> Query {
        
        //Bugünün tarihini yıl ay gün olarak aldık.
        let tarihVeriler = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        
        guard let bugun = Calendar.current.date(from: tarihVeriler), // bugünün başı
              let bitis = Calendar.current.date(byAdding: .hour, value: 24, to: bugun), // bugünün sonu
              let baslangic = Calendar.current.date(byAdding: .day, value: -100, to: bugun) else {
            fatalError("Belirtilen Tarih Aralıklarında Herhangi Bir Kayıt Bulunamadı")
        }
        
        // bitiş tarihinden ufak başlangıç tarihinden büyük tarih aralığı
        return whereField(Eklenme_Tarihi, isLessThanOrEqualTo: bitis).whereField(Eklenme_Tarihi, isGreaterThanOrEqualTo: baslangic).limit(to: 30) // verilerin tamamını değil 30 tanesini çek. Çok veri olabilir.
        //return whereField(Eklenme_Tarihi, isLessThanOrEqualTo: bitis).whereField(Eklenme_Tarihi, isGreaterThanOrEqualTo: bugun).limit(to: 30)
        
    }
    
    
    
}
