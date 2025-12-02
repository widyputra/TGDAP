# ---------------------------------------------------------------------------
# Function	   : driftcal.awk
# Purpose      : 
#	This script calculates the instrument drift from a single
#   closed-loop terrestrial gravity survey. It processes raw
#   gravimeter readings, identifies the first and last
#   station measurements of the loop, computes mean values,
#   and estimates the drift rate over the loop duration.
#
# Description  :
#   This script is developed as part of the Terrestrial Gravity Data
#   Assessment Project (TGDAP). The aim is to perform an initial assessment
#   of gravimeter performance by evaluating drift behavior within one
#   measurement loop. The tool extracts time-tagged gravity readings,
#   converts timestamps if needed, computes statistical summaries, and
#   determines the drift correction that can be applied across the survey.
#
# Current Stage:
#   The current version supports drift estimation for a single loop only.
#   Future updates will include advanced filtering and integration into a 
#	broader gravity data assessment toolkit.
#
# Inputs       : Raw gravity readings with timestamps and station labels.
# Outputs      : Numerical drift estimate and optional diagnostic statistics.
#
# Widy
# Terrestrial Gravity Data Assessment Project (TGDAP)
# ---------------------------------------------------------------------------

function computeMean(label, n,   i, sum) {
    sum = 0
    for (i=1; i<=n; i++) sum += g[label,i]
    if (n > 0) return sum/n
    return 0
}

function computeExcelMean(label, n,   i, sum) {
    sum = 0
    for (i=1; i<=n; i++) sum += excel[label,i]
    if (n > 0) return sum/n
    return 0
}

function printBlock(point, n, label,   i, gravMean, excelMean, mu, sd, sigma, diff, filteredSum, filteredCount) {
    print "=== " label " " point " Block ==="
    print "PointID\tGrav\t\tSD\t\tTime\t\tDate\t\tDec Time"

    for (i=1; i<=n; i++) {
        print point "\t" g[label,i] "\t" s[label,i] "\t" t[label,i] "\t" d[label,i] \
            "\t" excel[label,i]
    }

    if (n > 0) {

        gravMean = computeMean(label, n)
        printf "\n%s Unfiltered Grav Mean: %.3f\n", label, gravMean

        excelMean = computeExcelMean(label, n)
        printf "%s Mean Dec Time: %.10f\n", label, excelMean

        # --- 2-sigma gravity filter ---
        mu = gravMean
        sd = 0
        for (i=1; i<=n; i++) sd += (g[label,i]-mu)^2
        sigma = sqrt(sd/n)

        filteredSum = filteredCount = 0
        for (i=1; i<=n; i++) {
            diff = g[label,i] - mu
            if (diff <= 2*sigma && diff >= -2*sigma) {
                filteredSum += g[label,i]
                filteredCount++
            }
        }
        if (filteredCount > 0)
            printf "%s Grav Filtered Mean (2Sigma): %.3f\n\n", label, filteredSum/filteredCount
        else
            printf "%s Grav Filtered Mean (2Sigma): NA\n\n", label
    }
}

# Detect new block
/^Line/ {
    split($2, pid, "S")
    sub(/\..*/, "", pid[1])
    point = pid[1]

    if (firstPoint == "") {
        firstPoint = point
        currentLabel = "First"
    } else if (point == firstPoint) {
        lastPoint = point
        currentLabel = "Last"
        delete g["Last"]; delete s["Last"]; delete t["Last"]
        delete d["Last"]; delete excel["Last"]
        rowCount["Last"] = 0
    } else {
        currentLabel = ""
    }
    next
}

# Measurement rows
/^[ \t]*-?[0-9]/ {
    if (currentLabel == "First" || currentLabel == "Last") {

        rowCount[currentLabel]++

        g[currentLabel,rowCount[currentLabel]] = $4
        s[currentLabel,rowCount[currentLabel]] = $5
        t[currentLabel,rowCount[currentLabel]] = $12
        d[currentLabel,rowCount[currentLabel]] = $15

        # Excel Serial DateTime
        split($15, D, "/")   # yyyy/mm/dd
        year = D[1]
        month = D[2]
        day = D[3]

        # Convert to days since 1899-12-30
        excelDays = mktime(year " " month " " day " 00 00 00") / 86400 + 25569

        # Only use time from $12
        split($12, T, ":")
        dec = T[1] + T[2]/60 + T[3]/3600

        excelSerial = excelDays + dec / 24
        excel[currentLabel,rowCount[currentLabel]] = excelSerial
    }
}

END {

    gravF = computeMean("First", rowCount["First"])
    gravL = computeMean("Last",  rowCount["Last"])

    excelF = computeExcelMean("First", rowCount["First"])
    excelL = computeExcelMean("Last",  rowCount["Last"])

    if (rowCount["First"] > 0 && rowCount["Last"] > 0) {

        drift = gravL - gravF
        excelDiff = excelL - excelF   # days
        excelDiffHours = excelDiff * 24.0

        printf "** Gravity Drift Report **\n"
        printf "Drift: %.3f mGal\n", drift
        printf "Drift: %.1f uGal\n\n", drift*1000

        printf "First Mean Dec Time : %.10f\n", excelF
        printf "Last  Mean Dec Time : %.10f\n", excelL
        printf "Dec Time Difference : %.10f days\n", excelDiff
        printf "Loop Duration    : %.5f hours\n\n", excelDiffHours
    }

    if (rowCount["First"] > 0) printBlock(firstPoint, rowCount["First"], "First")
    if (rowCount["Last"] > 0)  printBlock(lastPoint,  rowCount["Last"],  "Last")
}
