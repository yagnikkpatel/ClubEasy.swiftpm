import UIKit

enum AttendanceExportFormat {
    case csv
    case pdf
}

enum AttendanceExporter {

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .long
        return f
    }()

    private static let shortDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd MMM yyyy"
        return f
    }()

    // MARK: - CSV Export
    // Structure:
    //   Swift Coding Club
    //   <subtitle>
    //   (blank line)
    //   Date: <date>
    //   Sr., Name, Enrollment No., Email ID, Year, Status
    //   1, ..., P/A
    //   (blank line)
    //   Date: <next date>
    //   ...
    static func csvData(title: String, subtitle: String, filterDate: Date? = nil) -> Data? {
        let students = StudentStorage.load().sorted { $0.name < $1.name }
        var dates = AttendanceStorage.datesWithAttendance().sorted()
        
        if let filterDate = filterDate {
            let calendar = Calendar.current
            dates = dates.filter { calendar.isDate($0, inSameDayAs: filterDate) }
        }

        var rows: [String] = []

        // Header block
        rows.append(title)
        if !subtitle.isEmpty { rows.append(subtitle) }
        rows.append("Exported: \(shortDateFormatter.string(from: Date()))")
        rows.append("")

        // One block per date
        for date in dates {
            let records = AttendanceStorage.records(for: date)
            rows.append("Date: \(dateFormatter.string(from: date))")
            rows.append(["Sr.", "Name", "Enrollment No.", "Email ID", "Year", "Semester", "Status"].joined(separator: ","))

            var sr = 1
            for student in students {
                let status: String
                if let isPresent = records[student.id] {
                    status = isPresent ? "Present" : "Absent"
                } else {
                    status = "-"
                }
                let row = [
                    "\(sr)",
                    csvEscape(student.name),
                    csvEscape(student.enrollmentNumber),
                    csvEscape(student.collegeEmail),
                    csvEscape(student.year),
                    csvEscape(student.semester),
                    status
                ].joined(separator: ",")
                rows.append(row)
                sr += 1
            }
            rows.append("") // blank line between dates
        }

        return rows.joined(separator: "\n").data(using: .utf8)
    }

    private static func csvEscape(_ string: String) -> String {
        if string.contains(",") || string.contains("\"") || string.contains("\n") {
            return "\"" + string.replacingOccurrences(of: "\"", with: "\"\"") + "\""
        }
        return string
    }

    // MARK: - PDF Export
    static func pdfData(title: String, subtitle: String, filterDate: Date? = nil) -> Data {
        let students = StudentStorage.load().sorted { $0.name < $1.name }
        var dates = AttendanceStorage.datesWithAttendance().sorted()

        if let filterDate = filterDate {
            let calendar = Calendar.current
            dates = dates.filter { calendar.isDate($0, inSameDayAs: filterDate) }
        }

        let pageWidth: CGFloat = 595.2
        let pageHeight: CGFloat = 841.8
        let margin: CGFloat = 40

        let pdfRenderer = UIGraphicsPDFRenderer(
            bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        )

        return pdfRenderer.pdfData { ctx in
            // Column config: Sr, Name, Enrollment, Email, Year, Semester, Status
            let colWidths: [CGFloat]  = [25, 135, 100, 140, 35, 35, 60]
            let colHeaders = ["#", "Name", "Enrollment No.", "Email ID", "Year", "Sem", "Status"]
            var colX: [CGFloat] = [margin]
            for i in 0..<colWidths.count - 1 { colX.append(colX[i] + colWidths[i]) }
            let tableWidth = colWidths.reduce(0, +)
            let rowHeight: CGFloat = 18

            // Typography
            let titleAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 20, weight: .bold),
                .foregroundColor: UIColor(red: 240/255, green: 81/255, blue: 56/255, alpha: 1)
            ]
            let subtitleAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12, weight: .medium),
                .foregroundColor: UIColor.black
            ]
            let metaAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor.darkGray
            ]
            let sectionAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12, weight: .semibold),
                .foregroundColor: UIColor.black
            ]
            let headerAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 9, weight: .semibold),
                .foregroundColor: UIColor.white
            ]
            let cellAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 9),
                .foregroundColor: UIColor.white
            ]
            let presentAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 9, weight: .semibold),
                .foregroundColor: UIColor(red: 0.3, green: 0.9, blue: 0.4, alpha: 1)
            ]
            let absentAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 9, weight: .semibold),
                .foregroundColor: UIColor(red: 1.0, green: 0.35, blue: 0.3, alpha: 1)
            ]

            func drawPageHeader(y: inout CGFloat) {
                ctx.beginPage()
                y = margin

                // Title
                title.draw(at: CGPoint(x: margin, y: y), withAttributes: titleAttr)
                y += 26

                if !subtitle.isEmpty {
                    subtitle.draw(at: CGPoint(x: margin, y: y), withAttributes: subtitleAttr)
                    y += 18
                }

                "Exported: \(shortDateFormatter.string(from: Date()))".draw(
                    at: CGPoint(x: margin, y: y), withAttributes: metaAttr)
                y += 16

                // Rule
                let rule = UIBezierPath()
                rule.move(to: CGPoint(x: margin, y: y))
                rule.addLine(to: CGPoint(x: pageWidth - margin, y: y))
                UIColor.lightGray.setStroke()
                rule.lineWidth = 0.5
                rule.stroke()
                y += 10
            }

            func drawTableHeader(y: inout CGFloat) {
                // Orange header background
                UIColor(red: 240/255, green: 81/255, blue: 56/255, alpha: 1).setFill()
                UIBezierPath(
                    roundedRect: CGRect(x: margin, y: y, width: tableWidth, height: rowHeight),
                    byRoundingCorners: [.topLeft, .topRight],
                    cornerRadii: CGSize(width: 4, height: 4)
                ).fill()
                for (i, header) in colHeaders.enumerated() {
                    header.draw(at: CGPoint(x: colX[i] + 4, y: y + 4), withAttributes: headerAttr)
                }
                y += rowHeight
            }

            var y: CGFloat = 0
            drawPageHeader(y: &y)

            for (dateIdx, date) in dates.enumerated() {
                let records = AttendanceStorage.records(for: date)
                let presentCount = records.values.filter { $0 }.count
                let totalCount = students.count

                // Check space for section header + table header + at least 2 rows
                if y + 60 > pageHeight - margin {
                    drawPageHeader(y: &y)
                }

                // Date section label
                if dateIdx > 0 { y += 8 }
                let dateLabel = "Date: \(dateFormatter.string(from: date))   ·   \(presentCount)/\(totalCount) present"
                dateLabel.draw(at: CGPoint(x: margin, y: y), withAttributes: sectionAttr)
                y += 20

                drawTableHeader(y: &y)

                for (idx, student) in students.enumerated() {
                    if y + rowHeight > pageHeight - margin {
                        drawPageHeader(y: &y)
                        drawTableHeader(y: &y)
                    }

                    // Flat row background (no corner radius — unified table look)
                    let rowColor = idx % 2 == 0
                        ? UIColor(white: 0.18, alpha: 1)
                        : UIColor(white: 0.13, alpha: 1)
                    let isLastRow = idx == students.count - 1
                    rowColor.setFill()
                    if isLastRow {
                        // Round only bottom corners on last row
                        UIBezierPath(
                            roundedRect: CGRect(x: margin, y: y, width: tableWidth, height: rowHeight),
                            byRoundingCorners: [.bottomLeft, .bottomRight],
                            cornerRadii: CGSize(width: 4, height: 4)
                        ).fill()
                    } else {
                        UIBezierPath(
                            rect: CGRect(x: margin, y: y, width: tableWidth, height: rowHeight)
                        ).fill()
                    }

                    let isPresent: Bool? = records[student.id]
                    let statusText = isPresent == nil ? "-" : (isPresent! ? "Present" : "Absent")
                    let statusAttr = isPresent == nil ? cellAttr : (isPresent! ? presentAttr : absentAttr)

                    let cols: [(String, [NSAttributedString.Key: Any])] = [
                        ("\(idx + 1)", cellAttr),
                        (student.name, cellAttr),
                        (student.enrollmentNumber, cellAttr),
                        (student.collegeEmail, cellAttr),
                        (student.year, cellAttr),
                        (student.semester, cellAttr),
                        (statusText, statusAttr)
                    ]

                    for (i, (text, attr)) in cols.enumerated() {
                        // Clip text to column width
                        let rect = CGRect(
                            x: colX[i] + 4,
                            y: y + 3,
                            width: colWidths[i] - 8,
                            height: rowHeight - 4
                        )
                        (text as NSString).draw(
                            with: rect,
                            options: [.truncatesLastVisibleLine, .usesLineFragmentOrigin],
                            attributes: attr,
                            context: nil
                        )
                    }
                    y += rowHeight
                }
            }
        }
    }
}
