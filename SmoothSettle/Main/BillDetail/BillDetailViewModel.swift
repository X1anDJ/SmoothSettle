//
//  BillDetailViewModel.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/10/14.
//
import UIKit

class BillDetailViewModel {
    
    private let tripRepository: TripRepository
    private var bill: Bill
    
    var titleText: String {
        return bill.title ?? "Untitled Bill"
    }
    
    var dateText: String {
        guard let date = bill.date else { return "Unknown Date" }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
    
    var image: UIImage? {
        if let imageData = bill.imageData {
            return UIImage(data: imageData)
        }
        return nil
    }
    
    // Initializer
    init(tripRepository: TripRepository, bill: Bill) {
        self.tripRepository = tripRepository
        self.bill = bill
        

    }
    
    // Methods to interact with the model
    func changeBillImage(to image: UIImage?) {
        tripRepository.changeBillImage(billId: bill.id, image: image)
        // Update the local bill object after saving
        if let updatedBill = tripRepository.fetchBill(by: bill.id) {
            self.bill = updatedBill
        }
    }
    
    func getPayer() -> Person? {
        return bill.payer
    }
    
    func getInvolvers() -> [Person] {
        if let involversSet = bill.involvers as? Set<Person> {
            let involversArray = Array(involversSet).sorted { (person1, person2) -> Bool in
                // Sort by name alphabetically
                let name1 = person1.name ?? ""
                let name2 = person2.name ?? ""
                return name1 < name2
            }
            for (index, person) in involversArray.enumerated() {
                let name = person.name ?? "Unknown"

            }
            return involversArray
        }

        return []
    }

    
    func getAmount() -> Double {
        return bill.amount
    }
    
//    func printBillDetails() {
//        print("----- Bill Details -----")
//        print("ID: \(bill.id)")
//        print("Title: \(titleText)")
//        print("Date: \(dateText)")
//        print(String(format: "Amount: $%.2f", getAmount()))
//        
//        if let payer = getPayer(), let payerName = payer.name {
//            print("Payer: \(payerName)")
//        } else {
//            print("Payer: None")
//        }
//        
//        let involvers = getInvolvers()
//        if involvers.isEmpty {
//            print("Involvers: None")
//        } else {
//            print("Involvers:")
//            for (index, person) in involvers.enumerated() {
//                if let name = person.name {
//                    print("  \(index + 1). \(name)")
//                } else {
//                    print("  \(index + 1). Unknown Name")
//                }
//            }
//        }
//        print("------------------------")
//    }
}
