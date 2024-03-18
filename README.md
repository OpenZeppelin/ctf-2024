# Ethernaut CTF 2024

Here you can find the challenges for the Ethernaut CTF 2024 with their respective solutions. The challenges ran on top of a custom kCTF infrastructure, which you can find [here](https://github.com/OpenZeppelin/ctf-infra).

### How to run challenges locally
1. Git clone the [ctf-infra](https://github.com/OpenZeppelin/ctf-infra) repository, cd into `paradigmctf.py` and run `docker-compose up -d` to start the infrastructure.
2. Git clone this repo, cd into `<challenge_name>/challenge` and run `docker-compose up -d` to start the challenge server.
3. You can now access the challenge server at `localhost:1337`, for example: `nc localhost 1337`.

# Challenges

Challenges are listed in alphabetical order with the final number of solves and points.

## Alien Spaceship
by steventhornton / 349 points / 37 solves

**Description**:

You have hacked into an alien spaceship and stolen the bytecode that controls their spaceship. They are on a mission to attack your home planet. Luckily for you their spaceship runs on the EVM. Take over control of their spaceship and successfully `abortMission`.

[Solution](alienspaceship/README.md) and [solve script](alienspaceship/challenge/project/script/Solve.s.sol)

## beef
by [cairoeth](https://twitter.com/cairoeth) / 485 points / 6 solves

**Description**:

My favorite project airdropped some tokens, but I didn't get any. Can you help me burn all of the supply? >:)

[Solution](beef/README.md) and [solve script](beef/challenge/project/script/Solve.s.sol)

## Dutch
by [cairoeth](https://twitter.com/cairoeth) / 289 points / 48 solves

**Description**:

Dutch auctions are great for NFTs. Can you become the highest bidder?

[Solution](dutch/README.md) and [solve script](dutch/challenge/project/script/Solve.s.sol)

## Dutch 2
by [cairoeth](https://twitter.com/cairoeth) / 453 points / 15 solves

**Description**:

Looks like someone is auctioning a lot of tokens, but they are encrypted. Might be a good idea to bid...

[Solution](dutch-2/README.md) and [solve script](dutch-2/challenge/project/script/Solve.s.sol)

## Greedy Sad Man
by [ericnordelo](https://twitter.com/ericng39) / 428 points / 21 solves

**Description**:

A very greedy and sad man is accepting donations in order to reduce his sadness. Everyone deserves happiness. Will you be able to make him happy?

[Solution](greedy-sad-man/README.md) and [solve script](greedy-sad-man/challenge/project/solve.py)

## Space Bank
by [pedroais2](https://twitter.com/Pedroais2) / 204 points / 64 solves

**Description**:

The formidable Space Bank is known for its stringent security systems and vast reserves of space tokens (Galactic credits). Outsmart two state-of-the-art alarms, steal the tokens, and then detonate the bank to claim victory.

[Solution](spacebank/README.md) and [solve script](spacebank/challenge/project/script/Solve.s.sol)

## start.exe
by [cairoeth](https://twitter.com/cairoeth) / 10 points / 298 solves

**Description**:

This transaction seems to be the start of something big. Can you figure out what it is? https://sepolia.etherscan.io/tx/0x73fcb6eec33280c39a696b8db0f7b3f71f789c28ef722e0c716f9c8cef6aa040

[Solution](start.exe/README.md)

## Wombo Combo
by [cairoeth](https://twitter.com/cairoeth) / 295 points / 47 solves

**Description**:

You should stake your tokens to get more tokens!

[Solution](wombocombo/README.md) and [solve script](wombocombo/challenge/project/script/Solve.s.sol)

## XYZ
by [cairoeth](https://twitter.com/cairoeth) / 449 points / 16 solves

**Description**:

XYZ: the most advanced algorithmic stablecoin that never depegs.

[Solution](xyz/README.md) and [solve script](xyz/challenge/project/script/Solve.s.sol)