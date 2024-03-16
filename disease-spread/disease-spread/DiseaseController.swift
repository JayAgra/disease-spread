//
//  DiseaseController.swift
//  disease-spread
//
//  Created by Jayen Agrawal on 3/15/24.
//

import Foundation

class DiseaseController: ObservableObject {
    @Published public var default_config: SEIR_Config = SEIR_Config(population: 6, beta: 0.8, latentPeriod: 6, infectiousPeriod: 10, tau: 0.005)
    
    public func getSeirData(data: SEIR_Config) -> [SEIR_Data] {
        let N = pow(10, Double(data.population))
        let B = data.beta
        let K = 1 / data.latentPeriod
        var G = 1 / data.infectiousPeriod
        let T = data.tau
        
        if G + T > 1 {
            G = 1 - T
        }
        
        var susceptable: Double = N
        var exposed: Double = 0
        var infected: Double = 0
        var recovered: Double = 0
        var died: Double = 0
        
        var data: [SEIR_Data] = [SEIR_Data(day: 0, susceptable: Int(susceptable), exposed: Int(exposed), infected: Int(infected), recovered: Int(recovered), died: Int(died))];
        
        var day_susceptable: Double = -1
        var day_exposed: Double = 0
        var day_infected: Double = 1
        var day_recovered: Double = 0
        var day_died: Double = 0
        
        for day_num in 1...1000 {
            susceptable += day_susceptable
            exposed += day_exposed
            infected += day_infected
            recovered += day_recovered
            died += day_died
            data.append(SEIR_Data(day: day_num, susceptable: Int(susceptable), exposed: Int(exposed), infected: Int(infected), recovered: Int(recovered), died: Int(died)))
            if exposed + infected < 0.5 {
                break;
            }
            day_susceptable = -1 * ((B * infected * susceptable) / N)
            day_exposed = (-1 * day_susceptable) - (K * exposed)
            day_infected = (K * exposed) - (G * infected) - (T * infected)
            day_recovered = G * infected
            day_died = T * infected
        }
        
        return data
    }
}

public struct SEIR_Config {
    let population: Int
    let beta: Double
    let latentPeriod: Double
    let infectiousPeriod: Double
    let tau: Double
}

public struct SEIR_Data {
    let day: Int
    let susceptable: Int
    let exposed: Int
    let infected: Int
    let recovered: Int
    let died: Int
}
