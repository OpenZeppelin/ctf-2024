from typing import Dict

from ctf_launchers.pwn_launcher import PwnChallengeLauncher
from ctf_server.types import LaunchAnvilInstanceArgs

BLOCK_TIME = 6

class Challenge(PwnChallengeLauncher):
    def get_anvil_instances(self) -> Dict[str, LaunchAnvilInstanceArgs]:
        return {
            "main": self.get_anvil_instance(
                block_time=BLOCK_TIME,
            ),
        }

Challenge().run()
