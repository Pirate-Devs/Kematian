import os
import sys
import time
import logging
import webbrowser

import requests


class AutoUpdater:
    def __init__(self) -> None:
        self.github_url = "https://github.com/Pirate-Devs/Kematian/releases/download/AutoBuild/main.exe"
        self.current_file = sys.argv[0]

    def get_current_file_bytes(self) -> bytes:
        with open(self.current_file, "rb") as file:
            return file.read()

    def get_github_file_bytes(self) -> bytes:
        return requests.get(self.github_url).content

    def check_if_exe(self) -> bool:
        if self.current_file.endswith(".exe"):
            return True
        return False

    def check_if_update(self) -> bool:
        return self.get_current_file_bytes() != self.get_github_file_bytes()

    def restart_program(self) -> None:
        os.execv(sys.executable, [sys.executable] + sys.argv)

    def update(self) -> None:
        if self.check_if_exe():
            logging.info("This is a exe file")
            if self.check_if_update():
                logging.critical(
                    "AN UPDATE IS AVAILABLE! Please update the program to the latest version by downloading it from the github page."
                )
                webbrowser.open(
                    "https://github.com/Pirate-Devs/Kematian/releases/download/AutoBuild/main.exe",
                    1,
                )
                input("Press enter to exit...")
                os._exit(0)


if __name__ == "__main__":
    updater = AutoUpdater()
    updater.update()
