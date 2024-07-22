from nicegui import ui


async def credits_page() -> None:
    """Main page for the stealer. Very simple."""
    text_frames = [
        "https://github.com/KDot227",
        "https://github.com/Chainski",
        "https://github.com/EvilBytecode",
        "https://t.me/ebthit",
        "https://github.com/Smug246",
    ]

    with ui.card().classes(
        "w-full h-full justify-center no-shadow border-[1px] border-gray-200 rounded-lg"
    ):
        ui.label("Credits").classes("w-full text-center text-5xl font-bold")
        with ui.column(align_items="center").classes("w-full text-center py-2"):
            for text_frame in text_frames:
                ui.link(text=text_frame, target=text_frame, new_tab=True).props(
                    "text-lg"
                ).classes("text-center py-2 text-2xl")
