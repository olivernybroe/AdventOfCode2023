bring cloud;
bring fs;
bring expect;
bring regex;


let isNumber = inflight (text: str): bool => {
    try {
        num.fromStr(text);
        return true;
    } catch {
        return false;
    }
};

let isSymbol = inflight (text: str): bool => {
    return regex.match("^[^0-9.]+$", text);
};

let findNumberAt = inflight(line: str, index: num): num? => {
    let var number = "";

    // Is current char a number?
    if isNumber(line.at(index)) {
        number = number + line.at(index);
    } else {
        return nil;
    }

    // Find left numbers unless we are at the beginning of the line
    if index > 0 {
        for i in (index - 1)..-1 {
            let character = line.at(i);
            if isNumber(character) {
                number = character + number;
            } else {
                break;
            }
        }
    }

    // Find right numbers unless we are at the end of the line
    if index < line.length - 1 {
        for i in (index + 1)..line.length {
            let character = line.at(i);
            if isNumber(character) {
                number = number + character;
            } else {
                break;
            }
        }
    }

    return num.fromStr(number);
};

let surroundingNumbers = inflight (currentLine: str, prevLine: str, nextLine: str, index: num): Array<num> => {
    let var numbers = MutArray<num> [];

    // Find numbers on previous line
    if isNumber(prevLine.at(index)) {
        if let prevCurrentLineNumber = findNumberAt(prevLine, index) {
            numbers.push(prevCurrentLineNumber);
        }
    } else {
        if index > 0 {
            if let prevLeftNumber = findNumberAt(prevLine, index - 1) {
                numbers.push(prevLeftNumber);
            }
        }
        if index < prevLine.length - 1 {
            if let prevRightNumber = findNumberAt(prevLine, index + 1) {
                numbers.push(prevRightNumber);
            }
        }
    }

    // Find numbers on next line
    if isNumber(nextLine.at(index)) {
        if let nextCurrentLineNumber = findNumberAt(nextLine, index) {
            numbers.push(nextCurrentLineNumber);
        }
    } else {
        if index > 0 {
            if let nextLeftNumber = findNumberAt(nextLine, index - 1) {
                numbers.push(nextLeftNumber);
            }
        }
        if index < nextLine.length - 1 {
            if let nextRightNumber = findNumberAt(nextLine, index + 1) {
                numbers.push(nextRightNumber);
            }
        }
    }

    // Find numbers on current line
    if index > 0 {
        if let currentLineLeftNumber = findNumberAt(currentLine, index - 1) {
            numbers.push(currentLineLeftNumber);
        }
    }
    if index < currentLine.length - 1 {
        if let currentLineRightNumber = findNumberAt(currentLine, index + 1) {
            numbers.push(currentLineRightNumber);
        }
    }

    return numbers.copy();
};


let hasSurroundingNumber = inflight (currentLine: str, prevLine: str, nextLine: str, index: num): bool => {
    let numbers = surroundingNumbers(currentLine, prevLine, nextLine, index);
    return numbers.length > 0;
};

let repeat = inflight (text: str, count: num): str => {
    let var result = "";
    for i in 0..count {
        result = result + text;
    }
    return result;
};

let findNumbers = inflight (lines: Array<str>): Array<num> => {
    let var numbers = MutArray<num> [];
    let filler = repeat(".", lines.at(0).length);

    for lineNumber in 0..lines.length {
        let var prevLine = lines.at(lineNumber - 1);
        if lineNumber == 0 {
            prevLine = filler;
        }
        let currentLine = lines.at(lineNumber);
        let var nextLine = lines.at(lineNumber + 1);
        if lineNumber == lines.length - 1 {
            nextLine = filler;
        }

        for i in 0..currentLine.length {
            let currentChar = currentLine.at(i);
            let var isSymbol = isSymbol(currentChar);

            if isSymbol {
                for foundNumber in surroundingNumbers(currentLine, prevLine, nextLine, i) {
                    numbers.push(foundNumber);
                }
            }
        }

    }

    return numbers.copy();
};

let part1 = new cloud.Function(inflight (input: str): num => {
    let var lines = input;
    if lines == "" {
        lines = fs.readFile("input");
    }
    let numbers = findNumbers(lines.split("\r\n"));
    let var sum = 0;
    for number in numbers {
        sum = sum + number;
    }

    return sum;
}) as "part1";


let findGearRatios = inflight (lines: Array<str>): Array<num> => {
    let var numbers = MutArray<num> [];
    let filler = repeat(".", lines.at(0).length);

    for lineNumber in 0..lines.length {
        let var prevLine = lines.at(lineNumber - 1);
        if lineNumber == 0 {
            prevLine = filler;
        }
        let currentLine = lines.at(lineNumber);
        let var nextLine = lines.at(lineNumber + 1);
        if lineNumber == lines.length - 1 {
            nextLine = filler;
        }

        for i in 0..currentLine.length {
            let currentChar = currentLine.at(i);
            let var isSymbol = currentChar == "*";

            if isSymbol {
                let surroundingNumbers = surroundingNumbers(currentLine, prevLine, nextLine, i);

                if surroundingNumbers.length == 2 {
                    let var leftNumber = surroundingNumbers.at(0);
                    let var rightNumber = surroundingNumbers.at(1);
                    let var gearRatio = leftNumber * rightNumber;
                    numbers.push(gearRatio);
                }
            }
        }

    }

    return numbers.copy();
};

let part2 = new cloud.Function(inflight (input: str): num => {
    let var lines = input;
    if lines == "" {
        lines = fs.readFile("input");
    }
    let numbers = findGearRatios(lines.split("\r\n"));
    let var sum = 0;
    for number in numbers {
        sum = sum + number;
    }

    return sum;
}) as "part2";


test "find numbers" {
    let var lines = [
        "467..114..",
        "...*......",
        "..35..633.",
        "......#...",
        "617*......",
        ".....+.58.",
        "..592.....",
        "......755.",
        "...$.*....",
        ".664.598..",
    ];
    let var numbers = findNumbers(lines);

    expect.equal(numbers, [467, 35, 633, 617, 592, 664, 755, 598]);

    lines = [
        "...33",
        "..*..",
    ];
    numbers = findNumbers(lines);
    expect.equal(numbers, [33]);
}

test "repeat" {
    expect.equal(repeat(".", 0), "");
    expect.equal(repeat(".", 1), ".");
    expect.equal(repeat(".", 2), "..");
    expect.equal(repeat(".", 3), "...");
}

test "is number" {
    expect.equal(isNumber("1"), true);
    expect.equal(isNumber("9"), true);
    expect.equal(isNumber("0"), true);
    expect.equal(isNumber("+"), false);
    expect.equal(isNumber("."), false);
    expect.equal(isNumber("g"), false);
}

test "is symbol" {
    expect.equal(isSymbol("1"), false);
    expect.equal(isSymbol("9"), false);
    expect.equal(isSymbol("0"), false);
    expect.equal(isSymbol("+"), true);
    expect.equal(isSymbol("."), false);
    expect.equal(isSymbol("$"), true);
}

test "get surrounding numbers" {
    expect.equal(surroundingNumbers("$$3$5", ".32..", "444..", 0), [32, 444]);
    expect.equal(surroundingNumbers("$$3$5", ".32..", "444..", 3), [32, 444, 3, 5]);
    expect.equal(surroundingNumbers(".....", "44.44", ".....", 2), [44, 44]);
}

test "has surrounding number" {
    expect.equal(hasSurroundingNumber("$$$$$", "..2..", ".....", 0), false);
    expect.equal(hasSurroundingNumber("$$$$$", "..2..", ".....", 1), true);
    expect.equal(hasSurroundingNumber("$$$$$", "..2..", ".....", 2), true);
    expect.equal(hasSurroundingNumber("$$$$$", "..2..", ".....", 3), true);
    expect.equal(hasSurroundingNumber("$$$$$", "..2..", ".....", 4), false);
}

test "find number at" {
    expect.equal(findNumberAt("111$$443$5", 1), 111);
    expect.nil(findNumberAt("$$3$5", 0));
    expect.equal(findNumberAt("$$443$5", 2), 443);
    expect.equal(findNumberAt("$$443$5", 3), 443);
    expect.equal(findNumberAt("$$443$5", 4), 443);
    expect.equal(findNumberAt("111$$443$5", 0), 111);
    expect.equal(findNumberAt("111$$443$5", 2), 111);
    expect.equal(findNumberAt("$$443$5", 6), 5);
    expect.nil(findNumberAt("$$3$5", 1));
}

test "find gear ratios" {
    let var lines = [
        "467..114..",
        "...*......",
        "..35..633.",
        "......#...",
        "617*......",
        ".....+.58.",
        "..592.....",
        "......755.",
        "...$.*....",
        ".664.598..",
    ];
    let var numbers = findGearRatios(lines);

    expect.equal(numbers, [16345, 451490]);

}