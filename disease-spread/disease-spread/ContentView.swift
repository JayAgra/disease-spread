//
//  ContentView.swift
//  disease-spread
//
//  Created by Jayen Agrawal on 3/15/24.
//

import SwiftUI
import Charts

struct ContentView: View {
    @ObservedObject var controller: DiseaseController = DiseaseController()
    @State private var latentPeriod: Double = 6
    @State private var infectiousPeriod: Double = 10
    @State private var beta: Double = 0.8
    @State private var tau: Double = 0.5
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Latent Period")
                        .frame(width: 100, alignment: .leading)
                    Spacer()
                    Slider(value: $latentPeriod, in: 5...20, step: 1).padding()
                }
                HStack {
                    Text("Infectious Period")
                        .frame(width: 100, alignment: .leading)
                    Spacer()
                    Slider(value: $infectiousPeriod, in: 1...20, step: 1).padding()
                }
                HStack {
                    Text("Infectivity")
                        .frame(width: 100, alignment: .leading)
                    Spacer()
                    Slider(value: $beta, in: 0.05...5, step: 0.05).padding()
                }
                HStack {
                    Text("Lethality")
                        .frame(width: 100, alignment: .leading)
                    Spacer()
                    Slider(value: $tau, in: 0.05...10, step: 0.05).padding()
                }
                LineChart(data: controller.getSeirData(data: SEIR_Config(population: 6, beta: beta, latentPeriod: latentPeriod, infectiousPeriod: infectiousPeriod, tau: tau / 100)))
            }
            .navigationTitle("Spread Simulator")
            .padding()
        }
    }
}

struct LineChart: View {
    let data: [SEIR_Data]
    let maxYValue: Int
    
    init(data: [SEIR_Data]) {
            self.data = data
            self.maxYValue = max(
                data.max(by: { $0.susceptable < $1.susceptable })?.susceptable ?? 0,
                data.max(by: { $0.exposed < $1.exposed })?.exposed ?? 0,
                data.max(by: { $0.infected < $1.infected })?.infected ?? 0,
                data.max(by: { $0.recovered < $1.recovered })?.recovered ?? 0,
                data.max(by: { $0.died < $1.died })?.died ?? 0
            )
        }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                self.drawLine(pathPoints: self.getPathPoints(for: \.susceptable, in: geometry), color: .purple)
                self.drawLine(pathPoints: self.getPathPoints(for: \.exposed, in: geometry), color: .yellow)
                self.drawLine(pathPoints: self.getPathPoints(for: \.infected, in: geometry), color: .red)
                self.drawLine(pathPoints: self.getPathPoints(for: \.recovered, in: geometry), color: .green)
                self.drawLine(pathPoints: self.getPathPoints(for: \.died, in: geometry), color: .gray)
            }
        }
    }
    
    private func getPathPoints(for keyPath: KeyPath<SEIR_Data, Int>, in geometry: GeometryProxy) -> [CGPoint] {
        let maxValue = maxYValue
        let dataCount = data.count
        return data.enumerated().map { index, dataPoint in
            let x = CGFloat(index) * geometry.size.width / CGFloat(dataCount - 1)
            let y = geometry.size.height * (1 - CGFloat(dataPoint[keyPath: keyPath]) / CGFloat(maxValue))
            return CGPoint(x: x, y: y)
        }
    }
    
    private func drawLine(pathPoints: [CGPoint], color: Color) -> some View {
        Path { path in
            pathPoints.forEach { point in
                if pathPoints.first == point {
                    path.move(to: point)
                } else {
                    path.addLine(to: point)
                }
            }
        }
        .stroke(color, lineWidth: 2)
    }
}

#Preview {
    ContentView()
}
