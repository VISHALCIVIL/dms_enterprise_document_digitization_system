# ScanDigitize DMS - Python PC Daily Report & Google Drive Sync Tool

This Python package runs on any PC (Windows, Mac, or Linux) with Python installed to fetch, aggregate, and display daily scanning reports from your Flutter Android devices and verify synced Google Drive details.

---

## 🚀 Setup Instructions for PC

### 1. Install Python
Download and install Python 3.8+ from [python.org](https://www.python.org/downloads/) on your PC.

### 2. Install Required Dependencies
Open terminal / command prompt in the `python_dms_tool` folder and run:
```bash
pip install -r requirements.txt
```

### 3. Service Account Setup (Google Drive & Firestore Access)
Place your Google Cloud Service Account key file named `service_account.json` into this folder, or pass its path via CLI flag `--service-account /path/to/key.json`.

---

## 📊 How to Run

### Display Daily Scanning Report (Today)
```bash
python dms_sync_report.py
```

### Display Daily Report for a Specific Date
```bash
python dms_sync_report.py --date 2026-08-15
```

### Export Daily Report to CSV
```bash
python dms_sync_report.py --export-csv
```

### Export Summary to JSON
```bash
python dms_sync_report.py --export-json
```

---

## 📋 Features Included
- **Daily Scanning Statistics**: Total documents scanned, page counts, data volume (MB), and operator activity.
- **Google Drive Sync Verification**: Checks file uploads against Google Drive storage hierarchy (`Project/Area/Department/Year/Batch/`).
- **CSV & JSON Export**: Export reports directly to CSV spreadsheets for Excel analysis.
- **Offline & Graceful Fallbacks**: Works even if optional dependencies are not yet installed.
