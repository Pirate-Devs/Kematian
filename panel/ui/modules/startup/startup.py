import os


class Startup:
    def __init__(self) -> None:
        self._kematian_logs_dir = os.path.join(
            os.getenv("APPDATA"), "Kematian-Stealer", "logs"
        )

    def delete_old_logs(self):
        found_logs = []
        for folder_name in os.listdir(self._kematian_logs_dir):
            pass
