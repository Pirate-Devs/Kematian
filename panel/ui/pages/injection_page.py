import os
import json
import aiofiles

from nicegui import ui


async def injections_page() -> None:
    """Injections page for the stealer."""
    json_data_path = os.path.join(
        os.getenv("APPDATA"), "Kematian-Stealer", "injections.json"
    )

    async with aiofiles.open(json_data_path, "r") as f:
        json_data = json.loads(await f.read())

    with ui.card().classes(
        "w-full h-full justify-center items-center no-shadow border-[1px] border-gray-200 rounded-lg"
    ):
        ui.json_editor({"content": {"json": json_data}}).classes("w-full h-full")
