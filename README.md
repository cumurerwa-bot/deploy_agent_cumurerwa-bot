Overview A shell script that automates the creation of a Student Attendance Tracker workspace with proper directory structure, configuration files, and signal handling.

Features Automated project setup with directory structure

Python3 environment validation

Interactive threshold configuration (warning/failure %)

Ctrl+C signal handling with automatic archiving

Duplicate project name prevention

Generated Structure text attendance_tracker_{name}/ ├── attendance_checker.py ├── Helpers/ │ ├── assets.csv │ └── config.json └── reports/ └── reports.log Archive Feature Press Ctrl+C during execution to:

Create attendance_tracker_{name}_archive backup

Clean up incomplete project directory

Configuration The script prompts for:

Project name (unique)

Warning threshold (default: 75%)

Failure threshold (default: 50%)

Requirements Bash shell

Python3 (for running the attendance checker) How to Run the Script

Open a terminal and run the command ./setup_project.sh How to Implement the Archive Feature While the script is running, press Ctrl+C
