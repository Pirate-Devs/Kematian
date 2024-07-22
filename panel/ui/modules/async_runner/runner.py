import asyncio
from subprocess import PIPE


class AsyncRunner:
    def __init__(self) -> None:
        pass

    async def run_command(self, command: str) -> str:
        process = await asyncio.create_subprocess_shell(
            command, stdout=PIPE, stderr=PIPE
        )
        stdout, stderr = await process.communicate()
        if stderr:
            print(stderr.decode())
        return stdout.decode().strip()
