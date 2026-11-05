//
//  MMEstimatorService.swift
//  FPMeter
//

import Foundation

enum MMEstimatorService {

    /// Estimate person-months from AFP using a 3-point productivity band.
    /// Higher FP/PM → fewer months (optimistic).
    /// Lower  FP/PM → more  months (conservative).
    /// Zero-division safe.
    static func estimate(afp: Double, config: ProductivityConfig) -> MMEstimate {
        func safeDiv(_ num: Double, _ den: Int) -> Double {
            guard den > 0 else { return 0 }
            let raw = num / Double(den)
            return (raw * 10).rounded() / 10
        }
        return MMEstimate(
            low: safeDiv(afp, config.high),
            average: safeDiv(afp, config.average),
            high: safeDiv(afp, config.low),
            productivityFactor: config.average
        )
    }

    /// Convert person-months to calendar months with team size.
    static func toCalendarMonths(mm: Double, teamSize: Int) -> Double {
        guard teamSize > 0 else { return 0 }
        return (mm / Double(teamSize) * 10).rounded() / 10
    }
}
