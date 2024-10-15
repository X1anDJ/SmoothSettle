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
    
    // Observable properties (you can use KVO, Combine, or your own mechanism)
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
            return Array(involversSet)
        }
        return []
    }
    
    func getAmount() -> Double {
        return bill.amount
    }
}
