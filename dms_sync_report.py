#!/usr/bin/env python3
"""
ScanDigitize Enterprise DMS - Python PC Daily Report & Sync Tool Launcher
"""

import sys
import os

# Redirect execution to python_dms_tool/dms_sync_report.py
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "python_dms_tool"))
from dms_sync_report import main

if __name__ == "__main__":
    main()
