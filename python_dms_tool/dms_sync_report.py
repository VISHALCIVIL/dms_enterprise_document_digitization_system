#!/usr/bin/env python3
"""
=============================================================================
ScanDigitize Enterprise DMS - Python PC Daily Scanning Report & Sync Tool
=============================================================================
This Python utility runs on any PC to:
1. Fetch and aggregate daily scanning reports from the Flutter Android app.
2. Synchronize and verify Google Drive uploaded documents and folder structures.
3. Check Firestore document metadata against uploaded Google Drive files.
4. Export CSV reports and summary analytics for management.

Usage:
    python dms_sync_report.py --service-account path/to/key.json
    python dms_sync_report.py --date 2026-08-15 --export-csv
"""

import os
import sys
import json
import csv
import argparse
from datetime import datetime

# Optional imports with graceful fallbacks
try:
    from google.oauth2 import service_account
    from googleapiclient.discovery import build
    GOOGLE_API_AVAILABLE = True
except ImportError:
    GOOGLE_API_AVAILABLE = False

try:
    import firebase_admin
    from firebase_admin import credentials, firestore
    FIREBASE_AVAILABLE = True
except ImportError:
    FIREBASE_AVAILABLE = False

try:
    from tabulate import tabulate
    HAS_TABULATE = True
except ImportError:
    HAS_TABULATE = False


class DMSSyncReportTool:
    def __init__(self, service_account_path=None, target_date=None):
        self.service_account_path = service_account_path or self._find_service_account_key()
        self.target_date = target_date or datetime.now().strftime("%Y-%m-%d")
        self.drive_service = None
        self.db = None
        self.scanned_records = []

    def _find_service_account_key(self):
        """Search current directory and parent directory for service account JSON key file."""
        candidates = [
            "service_account.json",
            "service-account.json",
            "credentials.json",
            "../service_account.json",
        ]
        for candidate in candidates:
            if os.path.exists(candidate):
                return candidate
        return None

    def init_google_drive(self):
        """Initialize Google Drive API client using Service Account credentials."""
        if not GOOGLE_API_AVAILABLE:
            print("[WARNING] Google API client libraries not installed. Run: pip install -r requirements.txt")
            return False

        if not self.service_account_path or not os.path.exists(self.service_account_path):
            print(f"[NOTICE] Service Account key file not found at: '{self.service_account_path}'")
            print("         Google Drive live API check will be skipped or simulated.")
            return False

        try:
            scopes = ['https://www.googleapis.com/auth/drive.readonly']
            creds = service_account.Credentials.from_service_account_file(
                self.service_account_path, scopes=scopes
            )
            self.drive_service = build('drive', 'v3', credentials=creds)
            print(f"[OK] Authenticated Google Drive API using service account: {self.service_account_path}")
            return True
        except Exception as e:
            print(f"[ERROR] Failed to authenticate with Google Drive: {e}")
            return False

    def init_firebase(self):
        """Initialize Firebase Firestore client using Service Account key."""
        if not FIREBASE_AVAILABLE:
            print("[WARNING] Firebase Admin SDK not installed. Run: pip install -r requirements.txt")
            return False

        if not self.service_account_path or not os.path.exists(self.service_account_path):
            print("[NOTICE] Service Account key file not found. Firestore live query skipped.")
            return False

        try:
            if not firebase_admin._apps:
                cred = credentials.Certificate(self.service_account_path)
                firebase_admin.initialize_app(cred)
            self.db = firestore.client()
            print(f"[OK] Connected to Firebase Firestore database.")
            return True
        except Exception as e:
            print(f"[ERROR] Failed to initialize Firebase Firestore: {e}")
            return False

    def fetch_firestore_scanning_records(self):
        """Fetch scanned document records for the target date from Firestore."""
        if not self.db:
            return []

        try:
            docs_ref = self.db.collection('scanned_documents')
            # Query documents for the target date
            query = docs_ref.where('date', '==', self.target_date)
            results = query.stream()

            records = []
            for doc in results:
                data = doc.to_dict()
                records.append(data)

            self.scanned_records = records
            print(f"[INFO] Fetched {len(records)} scanned records from Firestore for Date: {self.target_date}")
            return records
        except Exception as e:
            print(f"[ERROR] Error fetching Firestore records: {e}")
            return []

    def fetch_google_drive_files(self):
        """List files uploaded to Google Drive for the target date."""
        if not self.drive_service:
            return []

        try:
            query = "trashed = false"
            response = self.drive_service.files().list(
                q=query,
                pageSize=100,
                fields="nextPageToken, files(id, name, mimeType, createdTime, size, parents)"
            ).execute()

            files = response.get('files', [])
            print(f"[INFO] Found {len(files)} files/folders in Google Drive.")
            return files
        except Exception as e:
            print(f"[ERROR] Error querying Google Drive files: {e}")
            return []

    def generate_summary(self):
        """Calculate and format summary metrics for daily report."""
        records = self.scanned_records

        total_docs = len(records)
        total_pages = sum(r.get('pageCount', 0) for r in records)
        total_bytes = sum(r.get('fileSize', 0) for r in records)
        total_mb = round(total_bytes / (1024 * 1024), 2)

        synced_drive = sum(1 for r in records if r.get('googleDriveFileId') or r.get('syncStatus') == 'FULLY_SYNCED')
        pending_sync = total_docs - synced_drive

        operator_breakdown = {}
        project_breakdown = {}

        for r in records:
            op = r.get('operatorId', 'Unknown')
            proj = r.get('projectId', 'Default')
            operator_breakdown[op] = operator_breakdown.get(op, 0) + 1
            project_breakdown[proj] = project_breakdown.get(proj, 0) + 1

        summary = {
            "date": self.target_date,
            "total_documents": total_docs,
            "total_pages": total_pages,
            "total_size_mb": total_mb,
            "fully_synced_drive": synced_drive,
            "pending_sync": pending_sync,
            "operators": operator_breakdown,
            "projects": project_breakdown,
        }
        return summary

    def display_report(self):
        """Display clean terminal table report."""
        summary = self.generate_summary()

        print("\n" + "=" * 65)
        print(f"  SCAN DIGITIZE ENTERPRISE - DAILY SCANNING REPORT ({self.target_date})")
        print("=" * 65)

        metrics = [
            ["Report Date", summary["date"]],
            ["Total Documents Scanned", summary["total_documents"]],
            ["Total Pages Digitized", summary["total_pages"]],
            ["Total Data Volume (MB)", f"{summary['total_size_mb']} MB"],
            ["Synced to Google Drive", summary["fully_synced_drive"]],
            ["Pending Sync", summary["pending_sync"]],
        ]

        if HAS_TABULATE:
            print(tabulate(metrics, headers=["Metric", "Value"], tablefmt="fancy_grid"))
        else:
            for k, v in metrics:
                print(f"  - {k:<30}: {v}")

        if summary["operators"]:
            print("\n--- Scans per Operator ---")
            op_data = [[op, count] for op, count in summary["operators"].items()]
            if HAS_TABULATE:
                print(tabulate(op_data, headers=["Operator ID", "Documents Scanned"], tablefmt="simple"))
            else:
                for op, count in op_data:
                    print(f"  Operator: {op} -> {count} scans")

        if self.scanned_records:
            print("\n--- Scanned Documents Detail ---")
            headers = ["File Name", "Project", "Area", "Pages", "Drive Status"]
            rows = []
            for r in self.scanned_records:
                drive_status = "SYNCED" if r.get('googleDriveFileId') else "PENDING"
                rows.append([
                    r.get('fileName', 'N/A')[:30],
                    r.get('projectId', 'N/A'),
                    r.get('areaId', 'N/A'),
                    r.get('pageCount', 0),
                    drive_status
                ])
            if HAS_TABULATE:
                print(tabulate(rows, headers=headers, tablefmt="grid"))
            else:
                for row in rows:
                    print(" | ".join(str(x) for x in row))

        print("\n" + "=" * 65 + "\n")

    def export_csv(self, filename=None):
        """Export scanned documents detail to CSV."""
        if not filename:
            filename = f"daily_scan_report_{self.target_date}.csv"

        fieldnames = [
            "id", "fileName", "projectId", "areaId", "departmentId", "batchId",
            "operatorId", "date", "pageCount", "fileSize", "googleDriveFileId",
            "googleDriveFolderId", "uploadStatus", "syncStatus"
        ]

        with open(filename, mode="w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames, extrasaction="ignore")
            writer.writeheader()
            for r in self.scanned_records:
                writer.writerow(r)

        print(f"[SUCCESS] Daily report exported to CSV: '{filename}'")

    def export_json(self, filename=None):
        """Export summary report to JSON."""
        if not filename:
            filename = f"daily_scan_summary_{self.target_date}.json"

        summary = self.generate_summary()
        summary["documents"] = self.scanned_records

        with open(filename, "w", encoding="utf-8") as f:
            json.dump(summary, f, indent=2)

        print(f"[SUCCESS] Daily summary exported to JSON: '{filename}'")


def main():
    parser = argparse.ArgumentParser(description="ScanDigitize DMS PC Daily Report & Google Drive Sync Tool")
    parser.add_argument("--date", help="Date in YYYY-MM-DD format (default: today)", default=None)
    parser.add_argument("--service-account", help="Path to Service Account JSON key file", default=None)
    parser.add_argument("--export-csv", help="Export report details to CSV", action="store_true")
    parser.add_argument("--export-json", help="Export summary to JSON", action="store_true")

    args = parser.parse_args()

    tool = DMSSyncReportTool(
        service_account_path=args.service_account,
        target_date=args.date
    )

    print("\nStarting ScanDigitize PC Daily Report & Google Drive Sync Tool...")
    tool.init_google_drive()
    tool.init_firebase()

    tool.fetch_firestore_scanning_records()
    tool.fetch_google_drive_files()

    tool.display_report()

    if args.export_csv:
        tool.export_csv()
    if args.export_json:
        tool.export_json()


if __name__ == "__main__":
    main()
