bring cloud;
bring expect;
bring fs;
bring math;

inflight class SourceDestition {
    pub destinationRangeStart: num;
    pub sourceRangeStart: num;
    pub rangeLength: num;

    new(destinationRangeStart: num, sourceRangeStart: num, rangeLength: num) {
        this.destinationRangeStart = destinationRangeStart;
        this.sourceRangeStart = sourceRangeStart;
        this.rangeLength = rangeLength;
    }

    pub inflight isInSourceRange(value: num): bool {
        return value >= this.sourceRangeStart && value < this.sourceRangeStart + this.rangeLength;
    }

    pub inflight isInDestinationRange(value: num): bool {
        return value >= this.destinationRangeStart && value < this.destinationRangeStart + this.rangeLength;
    }

    pub inflight convert(value: num): num {
        return this.destinationRangeStart + (value - this.sourceRangeStart);
    }
}

inflight class SourceDestinationCollection {
    pub sourceDestinations: Array<SourceDestition>;

    new(sourceDestinations: Array<SourceDestition>) {
        this.sourceDestinations = sourceDestinations;
    }

    pub inflight convert(value: num): num {
        for sourceDestition in this.sourceDestinations {
            if sourceDestition.isInSourceRange(value) {
                return sourceDestition.convert(value);
            }
        }
        return value;
    }
}

inflight class Almanac {
    seeds: MutArray<num>;
    pub isSeedRange: bool;
    pub seedToSoilMap: SourceDestinationCollection;
    pub soilToFertilizerMap: SourceDestinationCollection;
    pub fertilizerToWaterMap: SourceDestinationCollection;
    pub waterToLightMap: SourceDestinationCollection;
    pub lightToTemperatureMap: SourceDestinationCollection;
    pub temperatureToHumidityMap: SourceDestinationCollection;
    pub humidityToLocationMap: SourceDestinationCollection;

    new(seeds: MutArray<num>, isSeedRange: bool, seedToSoilMap: SourceDestinationCollection, soilToFertilizerMap: SourceDestinationCollection, fertilizerToWaterMap: SourceDestinationCollection, waterToLightMap: SourceDestinationCollection, lightToTemperatureMap: SourceDestinationCollection, temperatureToHumidityMap: SourceDestinationCollection, humidityToLocationMap: SourceDestinationCollection) {
        this.seeds = seeds;
        this.isSeedRange = isSeedRange;
        this.seedToSoilMap = seedToSoilMap;
        this.soilToFertilizerMap = soilToFertilizerMap;
        this.fertilizerToWaterMap = fertilizerToWaterMap;
        this.waterToLightMap = waterToLightMap;
        this.lightToTemperatureMap = lightToTemperatureMap;
        this.temperatureToHumidityMap = temperatureToHumidityMap;
        this.humidityToLocationMap = humidityToLocationMap;
        this.seedIndex = 0;
        this.maxLoop = 0;
    }

    pub static inflight parse(input: str, seedsAsRange: bool): Almanac {
        let lines = input.split("\n");
        let var seeds = MutArray<num> [];

        if seedsAsRange {
            for seed in lines.at(0).substring(7).split(" ") {
                seeds.push(num.fromStr(seed));
            }
        } else {
            for seed in lines.at(0).substring(7).split(" ") {
                seeds.push(num.fromStr(seed));
            }
        }

        let sourceDesitionCollections = MutArray<SourceDestinationCollection> [];

        let var currentLine = 3;
        for i in 0..7 {
            let seedToSoils = MutArray<SourceDestition> [];
            while lines.at(currentLine) != "" && lines.length > currentLine {
                let parts = lines.at(currentLine).split(" ");
                seedToSoils.push(new SourceDestition(num.fromStr(parts.at(0)), num.fromStr(parts.at(1)), num.fromStr(parts.at(2))));
                currentLine += 1;
            }
            sourceDesitionCollections.push(new SourceDestinationCollection(seedToSoils.copy()));
            currentLine += 2;
        }

        return new Almanac(
            seeds,
            seedsAsRange,
            sourceDesitionCollections.at(0),
            sourceDesitionCollections.at(1),
            sourceDesitionCollections.at(2),
            sourceDesitionCollections.at(3),
            sourceDesitionCollections.at(4),
            sourceDesitionCollections.at(5),
            sourceDesitionCollections.at(6),
        );
    }

    var seedIndex: num = 0;
    var maxLoop: num = 0;
    pub inflight nextSeed(): num? {
        if this.isSeedRange {
            let start = this.seeds.at(0);
            let length = this.seeds.at(1);

             this.maxLoop += 1;
                if this.maxLoop > 100 {
                    return nil;
                }

            if this.seedIndex < length - 1 {
                let value = start + this.seedIndex;
                this.seedIndex += 1;
                return value;
            }

            if this.seedIndex == (length -1) {
                this.seeds.popAt(0);
                this.seeds.popAt(0);
                let value = start + this.seedIndex;
                this.seedIndex = 0;
                return value;
            }

            return nil;
        } else {
            if this.seedIndex >= this.seeds.length {
                return nil;
            }
            let value = this.seeds.at(this.seedIndex);
            this.seedIndex += 1;
            return value;
        }
    }
}

let seedToLocationConverter = inflight (seed: num, almanac: Almanac): num => {
    let soil = almanac.seedToSoilMap.convert(seed);
    let fertilizer = almanac.soilToFertilizerMap.convert(soil);
    let water = almanac.fertilizerToWaterMap.convert(fertilizer);
    let light = almanac.waterToLightMap.convert(water);
    let temperature = almanac.lightToTemperatureMap.convert(light);
    let humidity = almanac.temperatureToHumidityMap.convert(temperature);
    let location = almanac.humidityToLocationMap.convert(humidity);
    return location;
};

let findLowesetLocation = new cloud.Function(inflight (input: str): num => {
    let var lines = input;
    if lines == "" {
        lines = fs.readFile("input");
    }

    let almanac = Almanac.parse(lines, false);
    let locations = MutArray<num> [];
    let var seed = almanac.nextSeed();
    while seed != nil {
        if let seed = seed {
            locations.push(seedToLocationConverter(seed, almanac));
        }
        seed = almanac.nextSeed();
    }
    return math.min(locations.copy());
}) as "Part 1";

let findLowesetLocationWithSeedRange = new cloud.Function(inflight (input: str): num => {
    let var lines = input;
    if lines == "" {
        lines = fs.readFile("input");
    }

    let almanac = Almanac.parse(lines, true);
    let locations = MutArray<num> [];

    let var seed = almanac.nextSeed();
    while seed != nil {
        if let seed = seed {
            locations.push(seedToLocationConverter(seed, almanac));
        }
        seed = almanac.nextSeed();
    }
    return math.min(locations.copy());
}) as "Part 2";


test "can parse almanac" {
    let almanac = Almanac.parse(
        "seeds: 79 14 55 13\n\nseed-to-soil map:\n50 98 2\n52 50 48\n\nsoil-to-fertilizer map:\n0 15 37\n37 52 2\n39 0 15\n\nfertilizer-to-water map:\n49 53 8\n0 11 42\n42 0 7\n57 7 4\n\nwater-to-light map:\n88 18 7\n18 25 70\n\nlight-to-temperature map:\n45 77 23\n81 45 19\n68 64 13\n\ntemperature-to-humidity map:\n0 69 1\n1 0 69\n\nhumidity-to-location map:\n60 56 37\n56 93 4",
        false,
    );
    let seeds = MutArray<num> [];
    let var seed = almanac.nextSeed();
    while seed != nil {
        if let seed = seed {
            seeds.push(seed);
        }
        seed = almanac.nextSeed();
    }
    expect.equal(seeds, [79, 14, 55, 13]);
    expect.equal(
        Json.stringify(almanac.seedToSoilMap),
        Json.stringify(new SourceDestinationCollection([
            new SourceDestition(50, 98, 2),
            new SourceDestition(52, 50, 48),
        ]))
    );
    expect.equal(
        Json.stringify(almanac.soilToFertilizerMap),
        Json.stringify(new SourceDestinationCollection([
            new SourceDestition(0, 15, 37),
            new SourceDestition(37, 52, 2),
            new SourceDestition(39, 0, 15),
        ]))
    );
    expect.equal(
        Json.stringify(almanac.fertilizerToWaterMap),
        Json.stringify(new SourceDestinationCollection([
            new SourceDestition(49, 53, 8),
            new SourceDestition(0, 11, 42),
            new SourceDestition(42, 0, 7),
            new SourceDestition(57, 7, 4),
        ]))
    );
    expect.equal(
        Json.stringify(almanac.waterToLightMap),
        Json.stringify(new SourceDestinationCollection([
            new SourceDestition(88, 18, 7),
            new SourceDestition(18, 25, 70),
        ]))
    );
    expect.equal(
        Json.stringify(almanac.lightToTemperatureMap),
        Json.stringify(new SourceDestinationCollection([
            new SourceDestition(45, 77, 23),
            new SourceDestition(81, 45, 19),
            new SourceDestition(68, 64, 13),
        ]))
    );
    expect.equal(
        Json.stringify(almanac.temperatureToHumidityMap),
        Json.stringify(new SourceDestinationCollection([
            new SourceDestition(0, 69, 1),
            new SourceDestition(1, 0, 69),
        ]))
    );
    expect.equal(
        Json.stringify(almanac.humidityToLocationMap),
        Json.stringify(new SourceDestinationCollection([
            new SourceDestition(60, 56, 37),
            new SourceDestition(56, 93, 4),
        ]))
    );
    expect.equal(seedToLocationConverter(79, almanac), 82);
    expect.equal(seedToLocationConverter(14, almanac), 43);
    expect.equal(seedToLocationConverter(55, almanac), 86);
    expect.equal(seedToLocationConverter(13, almanac), 35);
}

test "can parse almanac with seed range" {
    let almanac = Almanac.parse(
        "seeds: 79 14 55 13\n\nseed-to-soil map:\n50 98 2\n52 50 48\n\nsoil-to-fertilizer map:\n0 15 37\n37 52 2\n39 0 15\n\nfertilizer-to-water map:\n49 53 8\n0 11 42\n42 0 7\n57 7 4\n\nwater-to-light map:\n88 18 7\n18 25 70\n\nlight-to-temperature map:\n45 77 23\n81 45 19\n68 64 13\n\ntemperature-to-humidity map:\n0 69 1\n1 0 69\n\nhumidity-to-location map:\n60 56 37\n56 93 4",
        true,
    );
    let seeds = MutArray<num> [];
    let var seed = almanac.nextSeed();
    while seed != nil {
        if let seed = seed {
            seeds.push(seed);
        }
        seed = almanac.nextSeed();
    }
    // write out the ranges 79-92, 55-67
    expect.equal(seeds, [
        79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, // 79-93
        55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, // 55-67
    ]);
}

test "is in source range" {
    let sourceDestition = new SourceDestition(0, 10, 5);
    expect.equal(sourceDestition.isInSourceRange(10), true);
    expect.equal(sourceDestition.isInSourceRange(11), true);
    expect.equal(sourceDestition.isInSourceRange(12), true);
    expect.equal(sourceDestition.isInSourceRange(13), true);
    expect.equal(sourceDestition.isInSourceRange(14), true);
    expect.equal(sourceDestition.isInSourceRange(15), false);
    expect.equal(sourceDestition.isInSourceRange(9), false);
}

test "is in destination range" {
    let sourceDestition = new SourceDestition(0, 10, 5);
    expect.equal(sourceDestition.isInDestinationRange(0), true);
    expect.equal(sourceDestition.isInDestinationRange(1), true);
    expect.equal(sourceDestition.isInDestinationRange(2), true);
    expect.equal(sourceDestition.isInDestinationRange(3), true);
    expect.equal(sourceDestition.isInDestinationRange(4), true);
    expect.equal(sourceDestition.isInDestinationRange(5), false);
    expect.equal(sourceDestition.isInDestinationRange(6), false);
}

test "can convert source to destination" {
    let sourceDestinationCollection = new SourceDestinationCollection([
        new SourceDestition(50, 98, 2),
        new SourceDestition(52, 50, 48),
    ]);

    expect.equal(sourceDestinationCollection.convert(79), 81);
    expect.equal(sourceDestinationCollection.convert(14), 14);
    expect.equal(sourceDestinationCollection.convert(55), 57);
    expect.equal(sourceDestinationCollection.convert(13), 13);
}