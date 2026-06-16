#!/bin/bash

#Lets's verify if python3 is installed
echo "Let's verify python3 installation"

if command -v python3; then
    echo " Python3 is installed."
    python3 --version
else
    echo "Python3 is missing. Install python3 to proceed!"
    exit 1
fi

#Asking user input for naming directory

echo "Provide name of your directory:"
read name

main_dir="attendance_tracker_$name"

while [ -d "$main_dir" ]; do
    echo "There is another project with the same name. Enter a new name:"
    read name
    main_dir="attendance_tracker_$name"
done

#Setting the signal trap
trap ctrl_c INT

ctrl_c() {
    echo  " Script Interrupted!!"

    if [ -d "$main_dir"  ]; then
        echo "Archiving current project directory..."
        tar -czf "${main_dir}_archive" "$main_dir"
        echo "Archive created: ${main_dir}_archive"

        echo "Cleaning up incomplete directory..."
        rm -rf "$main_dir"
        echo "Incomplete project directory deleted."
    fi

    exit 1
}

#Creating directories and files according to directory structure

mkdir -p "$main_dir"
mkdir -p "$main_dir/Helpers"
mkdir -p "$main_dir/reports"


cat << EOF > "$main_dir/attendance_checker.py" 
import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    # 1. Load Config
    with open('Helpers/config.json', 'r') as f:
        config = json.load(f)

    # 2. Archive old reports.log if it exists
    if os.path.exists('reports/reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports/reports.log', f'reports/reports_{timestamp}.log.archive')

    # 3. Process Data
    with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log', 'w') as log:
        reader = csv.DictReader(f)
        total_sessions = config['total_sessions']

        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")

        for row in reader:
            name = row['Names']
            email = row['Email']
            attended = int(row['Attendance Count'])

            # Simple Math: (Attended / Total) * 100
            attendance_pct = (attended / total_sessions) * 100

            message = ""
            if attendance_pct < config['thresholds']['failure']:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct < config['thresholds']['warning']:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."

            if message:
                if config['run_mode'] == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
EOF

cat << EOF > "$main_dir/Helpers/assets.csv"
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
EOF

cat << EOF > "$main_dir/Helpers/config.json"
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}

EOF

cat << EOF > "$main_dir/reports/reports.log"
--- Attendance Report Run: 2026-02-06 18:10:01.468726 ---
[2026-02-06 18:10:01.469363] ALERT SENT TO bob@example.com: URGENT: Bob Smith, your attendance is 46.7%. You will fail this class.
[2026-02-06 18:10:01.469424] ALERT SENT TO charlie@example.com: URGENT: Charlie Davis, your attendance is 26.7%. You will fail this class.


EOF

#Checking Directory structure

echo "Checking directory structure ..."

if [ -f "$main_dir/attendance_checker.py" ] &&
   [ -f "$main_dir/Helpers/assets.csv" ] &&
   [ -f "$main_dir/Helpers/config.json" ] &&
   [ -f "$main_dir/reports/reports.log" ]; then

    echo "Project setup successfull!"
else
    echo "Project setup failed! Incorrect directory structure."
fi

#Dynamic Configuration

#Asking user if they want to update threshold values
while true; do
	read -p "Do you want to update attendance threshold values? (y/n): " resp
	if [[ "$resp" = [Yy] ]]; then
		#Updating warning value
		while true; do
		echo "default warning threshold is 75%, press enter to keep default"
		read -p "Enter new warning threshold:" a
                a=${a:-75} 
		if [[ "$a" =~ ^[0-9]+$ ]] && [[ "$a" -ge 0 && "$a" -le 100 ]]; then
			break
		else
			echo "Value must be between 0 and 100!!"
                fi
	done
	       #Updating failure value
	       while true; do
	       echo "Default failure threshold is 50%, press enter to keep default"
	       read -p "Enter new failure threshold:" b
	       b=${b:-50} 
	       if [[ "$b" =~ ^[0-9]+$ ]] && [[ "$b" -ge 0 && "$b" -le 100 ]]; then
		       break
	       else
		       echo "Value must be between 0 and 100!!"
		fi
	done
	break
elif [[ "$resp" = [Nn] ]]; then
        echo "Values will remain the same!"
        break
    else
        echo "You must chose y or n!!"
    fi
done

#Updating Values

sed -i "s/\"warning\": [0-9]\+/\"warning\": $a/" "$main_dir/Helpers/config.json"
sed -i "s/\"failure\": [0-9]\+/\"failure\": $b/" "$main_dir/Helpers/config.json"


echo "Values successfully replaced:"

echo "Project successful"
