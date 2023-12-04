bring cloud;
bring expect;
bring math;
bring fs;


let findWinningNumbers = inflight (numbers: Array<num>, winningNumbers: Array<num>) => {
    let matchedNumbers = MutArray<num> [];
    for number in numbers {
        if winningNumbers.contains(number) {
            matchedNumbers.push(number);
        }
    }
    return matchedNumbers;
};

inflight class ScratchCard {
    pub id: num;
    pub numbers: Array<num>;
    pub winningNumbers: Array<num>;

    new(id: num, numbers: Array<num>, winningNumbers: Array<num>) {
        this.id = id;
        this.numbers = numbers;
        this.winningNumbers = winningNumbers;
    }

    pub static inflight fromString(s: str): ScratchCard {
        // get the id from `Card 1: ...`
        let id = num.fromStr(s.split(":").at(0).substring(4));
        // get the numbers from `... | ...`
        let numbers = s.split(":").at(1).split("|");

        // get the winning numbers from the first part, all numbers are at max 2 digits with padding
        let winningNumbersString = numbers.at(0).substring(1);
        let winningNumbers = MutArray<num> [];
        for numberIndex in 0..math.ceil((winningNumbersString.length / 3)) {
            let number = num.fromStr(winningNumbersString.substring(numberIndex * 3, numberIndex * 3 + 2));
            winningNumbers.push(number);
        }
        // get the numbers from the second part, all numbers are at max 2 digits with padding
        let numbersString = numbers.at(1).substring(1);
        let scratchedNumbers = MutArray<num> [];
        for numberIndex in 0..math.ceil((numbersString.length / 3)) {
            let number = num.fromStr(numbersString.substring(numberIndex * 3, numberIndex * 3 + 2));
            scratchedNumbers.push(number);
        }

        return new ScratchCard(id, scratchedNumbers.copy(), winningNumbers.copy());
    }

    pub inflight score(): num {
        let winningNumbers = findWinningNumbers(this.numbers, this.winningNumbers).length;
        if winningNumbers == 0 {
            return 0;
        }
        return 2 ** (winningNumbers - 1);
    }

    pub inflight getMatchingNumbers(): Array<num> {
        return findWinningNumbers(this.numbers, this.winningNumbers).copy();
    }
}

let carryOverScratchPads = inflight (scratchPads: Array<ScratchCard>): Map<num> => {
    let scratches = MutMap<num> {};

    // Add all scratches to the map
    for scratchPad in scratchPads {
        scratches.set(Json.stringify(scratchPad.id), 1);
    }

    // Loop over all scratch pads
    for scratchPad in scratchPads {
        let matchingNumbers = scratchPad.getMatchingNumbers().length;
        let increaseWith = scratches.get(Json.stringify(scratchPad.id));

        for i in 1..(matchingNumbers+1) {
            let scratchId = Json.stringify(scratchPad.id + i);
            let scratchesCount = scratches.get(scratchId) + increaseWith;

            scratches.set(scratchId, scratchesCount);
        }
    }

    return scratches.copy();
};

let part1 = new cloud.Function(inflight (input: str): num => {
    let var lines = input;
    if lines == "" {
        lines = fs.readFile("input");
    }
    let var sum = 0;
    for line in lines.split("\n") {
        let card = ScratchCard.fromString(line);
        sum += card.score();
    }


    return sum;
}) as "Part 1";

let part2 = new cloud.Function(inflight (input: str): num => {
    let var lines = input;
    if lines == "" {
        lines = fs.readFile("input");
    }
    let var scratchPads = MutArray<ScratchCard> [];
    for line in lines.split("\n") {
        scratchPads.push(ScratchCard.fromString(line));
    }

    let scratches = carryOverScratchPads(scratchPads.copy());
    let var sum = 0;
    for scratch in scratches.values() {
        sum += scratch;
    }

    return sum;
}) as "Part 2";

test "find winning numbers" {
    let numbers = [1, 2, 3, 4, 5];
    let winningNumbers = [3, 5, 7, 9, 11];
    let matchedNumbers = findWinningNumbers(numbers, winningNumbers);
    expect.equal(matchedNumbers, [3, 5]);
}

test "scratch card from string" {
    let card = ScratchCard.fromString("Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53");
    expect.equal(card.id, 1);
    expect.equal(card.winningNumbers, [41, 48, 83, 86, 17]);
    expect.equal(card.numbers, [83, 86, 6, 31, 17, 9, 48, 53]);
}

test "scratch card score" {
    let var card = ScratchCard.fromString("Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53");
    expect.equal(card.score(), 8);
    card = ScratchCard.fromString("Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19");
    expect.equal(card.score(), 2);
    card = ScratchCard.fromString("Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1");
    expect.equal(card.score(), 2);
    card = ScratchCard.fromString("Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83");
    expect.equal(card.score(), 1);
    card = ScratchCard.fromString("Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36");
    expect.equal(card.score(), 0);
    card = ScratchCard.fromString("Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11");
    expect.equal(card.score(), 0);
}

test "can carry-over winning scratches" {
    let scratchPads = [
        ScratchCard.fromString("Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53"),
        ScratchCard.fromString("Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19"),
        ScratchCard.fromString("Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1"),
        ScratchCard.fromString("Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83"),
        ScratchCard.fromString("Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36"),
        ScratchCard.fromString("Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11"),
    ];
    let scratches = carryOverScratchPads(scratchPads);
    expect.equal(scratches, {
        "1" => 1,
        "2" => 2,
        "3" => 4,
        "4" => 8,
        "5" => 14,
        "6" => 1,
    });
}