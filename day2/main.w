bring cloud;
bring fs;

inflight class CubeSet {
    blue: num;
    red: num;
    green: num;

    new(blue: num, red: num, green: num) {
        this.blue = blue;
        this.red = red;
        this.green = green;
    }

    pub getBlue(): num {
        return this.blue;
    }

    pub getRed(): num {
        return this.red;
    }

    pub getGreen(): num {
        return this.green;
    }
}

inflight class Game {
    id: num;
    sets: MutArray<CubeSet>;

    new(id: num) {
        this.id = id;
        this.sets = MutArray<CubeSet> [];
    }

    pub static inflight parse(line: str): Game {
        let id = line.substring(5, line.indexOf(":"));
        let game = new Game(num.fromStr(id));

        let sets = line.split(":").at(1).split(";");
        for set in sets {
            let cubes = set.split(",");
            let var blue = 0;
            let var red = 0;
            let var green = 0;

            for cube in cubes {
                let count = cube.trim().split(" ").at(0);
                let color = cube.trim().split(" ").at(1);
                if color == "blue" {
                    blue = num.fromStr(count);
                } elif color == "red" {
                    red = num.fromStr(count);
                } elif color == "green" {
                    green = num.fromStr(count);
                }
            }

            game.addSet(new CubeSet(blue, red, green));
        }


        return game;
    }

    pub getId(): num {
        return this.id;
    }

    pub getSets(): Array<CubeSet> {
        return this.sets.copy();
    }

    pub addSet(set: CubeSet) {
        this.sets.push(set);
    }
}

let isValidGame = inflight (revealed: Game, bag: CubeSet): bool => {
    for set in revealed.getSets() {
        if set.getBlue() > bag.getBlue() {
            return false;
        }
        if set.getRed() > bag.getRed() {
            return false;
        }
        if set.getGreen() > bag.getGreen() {
            return false;
        }
    }

    return true;
};

let validGamesSum = inflight (games: Array<Game>, bag: CubeSet): num => {
    let var sum = 0;
    for game in games {
        if isValidGame(game, bag) {
            sum += game.getId();
        }
    }

    return sum;
};

let parseGames = inflight (lines: Array<str>): Array<Game> => {
    let var games = MutArray<Game> [];
    for line in lines {
        games.push(Game.parse(line));
    }

    return games.copy();
};

let part1 = new cloud.Function(inflight () => {
    let lines = fs.readFile("input").split("\n");
    let games = parseGames(lines);
    let bag = new CubeSet(14, 12, 13);
    let sum = validGamesSum(games, bag);
    log("Sum of valid games: " + Json.stringify(sum));
}) as "Part 1";


test "is valid game" {
    let revealed = new Game(1);
    revealed.addSet(new CubeSet(3, 4, 0));
    let bag = new CubeSet(4, 5, 6);
    assert(isValidGame(revealed, bag));
}

test "is not valid game" {
    let revealed = new Game(1);
    revealed.addSet(new CubeSet(10, 2, 3));
    let bag = new CubeSet(4, 5, 6);
    assert(isValidGame(revealed, bag) == false);
}

test "can parse cube set" {
    let game = Game.parse("Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green");
    assert(game.getId() == 1);
    assert(game.getSets().length == 3);
}

test "can get sum of valid games" {
    let games = parseGames([
        "Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green",
        "Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue",
        "Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red",
        "Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red",
        "Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green",
    ]);
    let bag = new CubeSet(14, 12, 13);
    assert(validGamesSum(games, bag) == 8);
}

let lowestCubeSet = inflight (game: Game): CubeSet => {
    let var blue = 0;
    let var red = 0;
    let var green = 0;

    for set in game.getSets() {
        if blue == 0 || (set.getBlue() > blue && set.getBlue() != 0) {
            blue = set.getBlue();
        }
        if red == 0 || (set.getRed() > red && set.getRed() != 0) {
            red = set.getRed();
        }
        if green == 0 || (set.getGreen() > green && set.getGreen() != 0) {
            green = set.getGreen();
        }
    }
    return new CubeSet(blue, red, green);
};

let powerOfCubeset = inflight (set: CubeSet): num => {
    return set.getBlue() * set.getRed() * set.getGreen();
};

let lowestCubeSetPower = inflight (games: Array<Game>): num => {
    let var sum = 0;

    for game in games {
        let set = lowestCubeSet(game);
        sum += powerOfCubeset(set);
    }

    return sum;
};

let part2 = new cloud.Function(inflight () => {
    let lines = fs.readFile("input").split("\n");
    let games = parseGames(lines);
    let sum = lowestCubeSetPower(games);
    log("Sum of lowest cube set power: " + Json.stringify(sum));
}) as "Part 2";

test "can get lowest cube set" {
    let game = Game.parse("Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green");
    let lowest = lowestCubeSet(game);
    assert(lowest.getBlue() == 6);
    assert(lowest.getRed() == 4);
    assert(lowest.getGreen() == 2);
}

test "can get power of cube set" {
    let set = new CubeSet(6, 4, 2);
    assert(powerOfCubeset(set) == 48);
}

test "can get sum of the power of the lowest cube set" {
        let games = parseGames([
        "Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green",
        "Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue",
        "Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red",
        "Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red",
        "Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green",
    ]);
    assert(lowestCubeSetPower(games) == 2286);
}