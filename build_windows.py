#!/usr/bin/env python3
"""
ScanDigitize Enterprise - Windows Desktop Build Script
"""

import sys
import subprocess

def print_header(title: str):
    print("=" * 55)
    print(f"  {title}")
    print("=" * 55)
    print()

def run_command(step_num: int, description: str, cmd: list[str]) -> None:
    print(f"{step_num}. {description}...")
    print(f"   Running: {' '.join(cmd)}")
    try:
        use_shell = sys.platform == "win32"
        subprocess.run(cmd, shell=use_shell, check=True)
        print()
    except subprocess.CalledProcessError as e:
        print(f"\n[ERROR] Step failed with exit code {e.returncode}: {' '.join(cmd)}")
        sys.exit(e.returncode)
    except FileNotFoundError:
        print(f"\n[ERROR] Command not found: '{cmd[0]}'. Please make sure Flutter is installed and in your PATH.")
        sys.exit(1)

def main():
    print_header("ScanDigitize Enterprise - Windows Desktop Build Script")

    run_command(1, "Fetching Flutter Dependencies", ["flutter", "pub", "get"])
    run_command(2, "Running Static Analysis", ["flutter", "analyze", "--no-fatal-warnings", "--no-fatal-infos"])

    if sys.platform != "win32":
        print("3. Building Release Windows Desktop Executable...")
        print("   [NOTICE] You are currently running on a non-Windows OS (macOS/Linux).")
        print("   Flutter requires a Windows host to build Windows desktop .exe files natively.")
        print("   To build the Windows executable:")
        print("   - Run this script on a Windows PC, OR")
        print("   - Push your code to GitHub to trigger .github/workflows/build_windows.yml\n")
        return

    run_command(3, "Building Release Windows Desktop Executable", ["flutter", "build", "windows", "--release"])

    print("=" * 55)
    print("  BUILD COMPLETE!")
    print("  Executable Location:")
    print(r"  build\windows\x64\runner\Release\scandigitize.exe")
    print("=" * 55)

if __name__ == "__main__":
    main()
