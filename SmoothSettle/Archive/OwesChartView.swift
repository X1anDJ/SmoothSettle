//
//  OwesChartView.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 12/12/24.
//

import Foundation
import SwiftUI
import Charts

// MARK: - Chart Data Model
struct ChartData: Identifiable {
    let id = UUID()
    let name: String
    let owes: Double
    let formattedOwes: String
}

// MARK: - SwiftUI Chart View
struct OwesChartView: View {
    var data: [ChartData]
    var timePeriod: String
    var totalAmount: String

    // Define a color palette to assign consistent colors to each person
    private let colorPalette: [Color] = [
        Color(UIColor(hex: "ba3133")), // Color 1
        Color(UIColor(hex: "f94144")), // Color 2
        Color(UIColor(hex: "f3722c")), // Color 3
        Color(UIColor(hex: "f8961e")), // Color 4
        Color(UIColor(hex: "f9c74f")), // Color 5
        Color(UIColor(hex: "90be6d")), // Color 6
        Color(UIColor(hex: "43aa8b")), // Color 7
        Color(UIColor(hex: "4d908e")), // Color 8
        Color(UIColor(hex: "577590")), // Color 9
        Color(UIColor(hex: "4d94b2"))  // Color 10
    ]
    
    // Function to assign a color to each person based on their index
    private func color(for index: Int) -> Color {
        return colorPalette[index % colorPalette.count]
    }
    
    var body: some View {
        VStack {
            HStack {
                let expensesByPersonLocalized = String(localized: "expenses_by_person")
                Text(expensesByPersonLocalized)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.bottom, 16) // Increased padding for better spacing
                    .foregroundColor(Color(Colors.primaryDark))
                Spacer()
            }
            HStack {
                Text(timePeriod)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
            }
            if data.isEmpty {
                let noExpensesLocalized = String(localized: "no_expenses")
                Text(noExpensesLocalized)
                    .foregroundColor(Color(.darkGray))
                    .padding()
            } else {
                GeometryReader { geometry in
                    HStack(spacing: 0) {
                        Chart {
                            ForEach(Array(data.enumerated()), id: \.element.id) { index, entry in
                                SectorMark(
                                    angle: .value("Amount", entry.owes),
                                    innerRadius: .ratio(0.4),
                                    angularInset: 1
                                )
                                .foregroundStyle(color(for: index))
                                .annotation(position: .overlay) {
                                    // Optional: Add labels inside the pie slices
                                    // set text to bold
                                    
                                   // Text(String(format: "$%.0f", entry.owes))
                                    Text(entry.formattedOwes)
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .rotationEffect(.degrees(0))
                                }
                            }
                        }
                        .chartLegend(.hidden) // Hide default legend
                        .frame(width: geometry.size.width * 2 / 3.4 , height: geometry.size.width * 2 / 3.4)
                        
                        Spacer()
                        
                        VStack {
                            LegendView(data: data, colorPalette: colorPalette)

                            Spacer()
                            // total amount label
                            VStack(spacing: 8) {
                                
                                Text(String(localized: "Total"))
                                    .font(.footnote)
                                    .foregroundColor(.primary)
                                    .padding(.top, 16)
                                    
                               // Text(String(format: "$%.2f", data.reduce(0) { $0 + $1.owes }))
                                Text(totalAmount)
                                    .font(.body)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(Colors.accentOrange))
                                    .padding(.bottom, 16)
                            }
                            .frame(width: geometry.size.width / 3 )
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(Colors.background1))
//                                    .shadow(radius: 1, x: 0, y: 2)
                            )

                        
                        }
                        .frame(width: geometry.size.width / 3 )

                    }
                }
            }
        }
        
    }
}



// MARK: - Legend View
struct LegendView: View {
    var data: [ChartData]
    var colorPalette: [Color]
    
    // Function to assign a color to each person based on their index
    private func color(for index: Int) -> Color {
        return colorPalette[index % colorPalette.count]
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(Array(data.enumerated()), id: \.element.id) { index, entry in
                HStack {
                    Circle()
                        .fill(color(for: index))
                        .frame(width: 12, height: 12)
                    Text(entry.name)
                        .font(.caption)
                        .foregroundColor(.primary)
                    Spacer()
                }
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(Colors.background1))
//                .shadow(radius: 1, x: 0, y: 2)
        )
    }
}
