Terrestrial Gravity Data Assessment Project (TGDAP)

Version: 1.0
Status: Active
Last Updated: 1 December 2025

**Overview**

The Terrestrial Gravity Data Assessment Project (TGDAP) is an initiative aimed at evaluating the quality, consistency, and reliability of terrestrial gravity measurements gathered from multiple survey campaigns. The project focuses on harmonizing datasets, validating instrument performance, assessing environmental and operational effects, and producing standardized gravity data suitable for geophysical interpretation and geodetic applications. At the current stage, the developer has completed the assessment of drift values derived from a single measurement loop and continues to work on providing tools that support a more comprehensive evaluation of terrestrial gravity data.

**Objectives**

Evaluate raw and processed terrestrial gravity measurements from various field campaigns.
Quantify data quality indicators such as repeatability, drift behavior, loop closure errors, and instrument stability.
Provide recommendations for improved acquisition procedures and processing workflows.

**Scope of Work**

Data Acquisition Assessment
Drift estimation and correction

**Data Requirements**

To perform a full gravity data assessment, the following inputs are typically required:
Raw gravimeter readings
Station coordinates includes the ellipsoidal height
Field logs (instrument information and loop start/end times)
Calibration parameters (scale factor, drift rate history)
Metadata for survey configuration

**Output Products**

Processing report 
Error statistics (repeatability, drift residuals, closure errors)

**Project Structure**
TGDAP/
│
├── data_raw/           # Raw gravity readings
├── data_processed/     # Corrected & filtered datasets
├── scripts/            # Processing scripts (Python, AWK, etc.)
├── docs/               # Technical documentation
├── results/            # reports
└── README.md           # This file

**Tools & Software**

Recommended tools typically used in TGDAP:
AWK (for field-style batch data restructuring)
Custom processing scripts

**Contact**

For questions, collaboration, or technical support:
Project Lead: Widy
