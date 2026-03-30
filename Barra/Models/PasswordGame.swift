import Foundation

// MARK: - Team

struct PasswordTeam: Identifiable, Equatable {
    let id: UUID
    var name: String
    var score: Int

    init(id: UUID = UUID(), name: String, score: Int = 0) {
        self.id = id
        self.name = name
        self.score = score
    }
}

// MARK: - Word Category

/// A deck of words organized by theme.
/// Each category has 40+ words curated for one-word-clue gameplay.
struct WordCategory: Identifiable, Equatable {
    let id: String          // e.g. "movies"
    let name: String        // e.g. "Movies & TV"
    let emoji: String       // e.g. "🎬"
    let words: [String]
}

// MARK: - Word Result

/// What happened with a single word — for the end-of-game history.
struct WordResult: Identifiable {
    let id = UUID()
    let word: String
    let scoredByTeam: String?   // nil = nobody got it
    let points: Int             // 0, 2, 4, or 6
    let clueAttempts: Int       // how many clue attempts it took (1, 2, or 3)
}

// MARK: - Game Phase

/// State machine for the Password game.
///
/// Flow per word:
///   passPhone → showingWord → judging → (scored | passPhone for next attempt | nobodyGotIt)
///   After scored/nobodyGotIt → passPhone for next word (or gameOver)
enum PasswordGamePhase: Equatable {
    case setup
    case passPhone          // "Pass the phone to [Team]'s describer"
    case showingWord        // Describer sees the word + gives a one-word clue
    case judging            // "Did [Team] guess correctly?"
    case scored             // Brief celebration — points awarded
    case nobodyGotIt        // All 3 attempts failed
    case gameOver           // Someone hit the target score
}

// MARK: - Point values

/// Points decrease with each clue attempt:
///   Attempt 1 → 6 points
///   Attempt 2 → 4 points
///   Attempt 3 → 2 points
func pointsForAttempt(_ attempt: Int) -> Int {
    switch attempt {
    case 1: return 6
    case 2: return 4
    case 3: return 2
    default: return 0
    }
}

// MARK: - Built-in Categories

enum PasswordCategories {
    static let all: [WordCategory] = [
        general, moviesTV, food, animals, sports, science, popCulture, places
    ]

    static let general = WordCategory(
        id: "general", name: "General", emoji: "🎯",
        words: [
            "Beach", "Castle", "Guitar", "Shadow", "Mirror",
            "Blanket", "Candle", "Anchor", "Diamond", "Rocket",
            "Whisper", "Balloon", "Pyramid", "Feather", "Chimney",
            "Tornado", "Helmet", "Glacier", "Falcon", "Bucket",
            "Pillow", "Wagon", "Statue", "Pebble", "Cabin",
            "Riddle", "Blossom", "Velvet", "Harvest", "Compass",
            "Lantern", "Thunder", "Garden", "Marble", "Fossil",
            "Jungle", "Crown", "Tunnel", "Swamp", "Hammer"
        ]
    )

    static let moviesTV = WordCategory(
        id: "movies", name: "Movies & TV", emoji: "🎬",
        words: [
            "Titanic", "Inception", "Batman", "Frozen", "Shrek",
            "Matrix", "Avatar", "Jaws", "Rocky", "Simpsons",
            "Friends", "Gladiator", "Pixar", "Joker", "Avengers",
            "Skywalker", "Hobbit", "Nemo", "Minions", "Godzilla",
            "Terminator", "Aladdin", "Tarzan", "Pinocchio", "Dumbo",
            "Seinfeld", "Narcos", "Stranger", "Peaky", "Breaking",
            "Squid", "Mandalorian", "Westworld", "Succession", "Ozark",
            "Deadpool", "Jumanji", "Coco", "Moana", "Ratatouille"
        ]
    )

    static let food = WordCategory(
        id: "food", name: "Food", emoji: "🍕",
        words: [
            "Pizza", "Sushi", "Burger", "Chocolate", "Avocado",
            "Pasta", "Taco", "Croissant", "Pancake", "Steak",
            "Waffle", "Pretzel", "Mango", "Cinnamon", "Popcorn",
            "Lobster", "Burrito", "Donut", "Smoothie", "Truffle",
            "Gumbo", "Nachos", "Falafel", "Tiramisu", "Ramen",
            "Kimchi", "Dumpling", "Kebab", "Gelato", "Fondue",
            "Omelette", "Churro", "Bagel", "Hummus", "Poutine",
            "Macaron", "Brisket", "Granola", "Risotto", "Tempura"
        ]
    )

    static let animals = WordCategory(
        id: "animals", name: "Animals", emoji: "🐾",
        words: [
            "Elephant", "Penguin", "Dolphin", "Cheetah", "Gorilla",
            "Flamingo", "Octopus", "Panther", "Koala", "Chameleon",
            "Jellyfish", "Scorpion", "Peacock", "Toucan", "Porcupine",
            "Platypus", "Vulture", "Mongoose", "Iguana", "Pelican",
            "Hamster", "Lobster", "Buffalo", "Falcon", "Anaconda",
            "Walrus", "Parrot", "Starfish", "Mantis", "Coyote",
            "Gazelle", "Manatee", "Stingray", "Cricket", "Badger",
            "Meerkat", "Hedgehog", "Macaw", "Bison", "Seahorse"
        ]
    )

    static let sports = WordCategory(
        id: "sports", name: "Sports", emoji: "⚽",
        words: [
            "Basketball", "Tennis", "Soccer", "Surfing", "Boxing",
            "Cricket", "Marathon", "Fencing", "Archery", "Gymnastics",
            "Diving", "Rowing", "Karate", "Handball", "Triathlon",
            "Volleyball", "Snowboard", "Lacrosse", "Badminton", "Polo",
            "Wrestling", "Sailing", "Climbing", "Bobsled", "Javelin",
            "Hurdles", "Dribble", "Knockout", "Offside", "Penalty",
            "Touchdown", "Referee", "Stadium", "Champion", "Overtime",
            "Halftime", "Playoffs", "Underdog", "Sprinter", "Goalie"
        ]
    )

    static let science = WordCategory(
        id: "science", name: "Science", emoji: "🔬",
        words: [
            "Gravity", "Volcano", "Molecule", "Eclipse", "Fossil",
            "Tornado", "Nucleus", "Oxygen", "Magnet", "Prism",
            "Bacteria", "Glacier", "Neutron", "Plasma", "Comet",
            "Asteroid", "Tsunami", "Genome", "Photon", "Quartz",
            "Mercury", "Celsius", "Spectrum", "Reactor", "Enzyme",
            "Protein", "Vaccine", "Nebula", "Galaxy", "Satellite",
            "Dinosaur", "Parasite", "Electron", "Biome", "Fungus",
            "Crystal", "Dopamine", "Caffeine", "Carbon", "Algorithm"
        ]
    )

    static let popCulture = WordCategory(
        id: "popculture", name: "Pop Culture", emoji: "🎤",
        words: [
            "Beyonce", "Snapchat", "TikTok", "Emoji", "Selfie",
            "Hashtag", "Netflix", "Spotify", "Podcast", "Meme",
            "Influencer", "Viral", "Tesla", "Bitcoin", "iPhone",
            "Fortnite", "Minecraft", "Pokemon", "PlayStation", "Nintendo",
            "Hogwarts", "Wakanda", "Thanos", "Yoda", "Gandalf",
            "Pikachu", "Mario", "Zelda", "Katniss", "Elsa",
            "Ironman", "Spiderman", "Barbie", "Kardashian", "Drake",
            "Rihanna", "Adele", "Grammy", "Oscar", "Comic"
        ]
    )

    static let places = WordCategory(
        id: "places", name: "Places", emoji: "🌍",
        words: [
            "Pyramid", "Eiffel", "Amazon", "Sahara", "Hollywood",
            "Everest", "Venice", "Tokyo", "Safari", "Bermuda",
            "Atlantis", "Vatican", "Alcatraz", "Chernobyl", "Pentagon",
            "Broadway", "Colosseum", "Acropolis", "Stonehenge", "Versailles",
            "Manhattan", "Maldives", "Bangkok", "Istanbul", "Dubai",
            "Monaco", "Havana", "Santorini", "Marrakech", "Reykjavik",
            "Patagonia", "Zanzibar", "Tasmania", "Kilimanjaro", "Galapagos",
            "Gibraltar", "Niagara", "Pompeii", "Timbuktu", "Yellowstone"
        ]
    )
}
