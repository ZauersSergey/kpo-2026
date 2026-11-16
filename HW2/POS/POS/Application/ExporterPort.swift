//
//  ExporterPort.swift
//  POS
//
//  Created by Сергей Зауэрс on 16.11.2026.
//

import Foundation

protocol FinalReportExporter {
    func export(_ report: FinalReport) throws -> String
}
