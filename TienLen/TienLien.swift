//
//  TienLien.swift
//  TienLen
//
//  Created by Dylan Dao on 7/7/23.
//

import Foundation

enum Rank:Int, CaseIterable, Comparable{
    case three=1, four, five, six, seven, eight, nine, ten, jack, queen, king, ace, two;
    
    static func < (lhs: Rank, rhs: Rank) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

enum Suit: Int, CaseIterable, Comparable {
    case spades=1, clubs, diamonds, hearts
    
    static func < (lhs: Suit, rhs: Suit) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

enum HandType {
    case Invalid, Single, Pair, ThreeOfAKind, Straight, ThreePairStraight, FourOfAKind, FourPairStraight
    
    init(_ cards: Stack) {
        var returnType: Self = .Invalid
        
        if cards.count == 1 {
            returnType = .Single
        }
        
        if  cards.count == 2 {
            if cards[0].rank == cards[1].rank {
                returnType = .Pair
            }
        }
        
        if cards.count == 3 {
            if cards[0].rank == cards[1].rank &&
                cards[0].rank == cards[2].rank {
                returnType = .ThreeOfAKind
            }
        }
        
        if cards.count == 5 {
            let sortedHand = cards.sortByRank()
            
            if (sortedHand[1].rank == sortedHand[2].rank && sortedHand[2].rank == sortedHand[3].rank &&
                (sortedHand[0].rank == sortedHand[3].rank || sortedHand[3].rank == sortedHand[4].rank)) {
                returnType = .FourOfAKind
            }
            
            var isStraight = true
            for (i, _) in sortedHand.enumerated() {
                if i + 1 < 5 {
                    if i == 0 && sortedHand[0].rank == .ace {
                        if ((sortedHand[i].rank.rawValue % 13) - (sortedHand[i + 1].rank.rawValue % 13)) != 1 &&
                            ((sortedHand[i + 1].rank.rawValue % 12) - (sortedHand[i].rank.rawValue % 12)) != 3 {
                            isStraight = false
                        }
                    } else {
                        if ((sortedHand[i].rank.rawValue % 13) - (sortedHand[i + 1].rank.rawValue % 13)) != 1 {
                            isStraight = false
                        }
                    }
                }
            }
        }
        
        self = returnType
    }
}

struct Card: Identifiable {
    var rank: Rank
    var suit: Suit
    var filename: String {
        return "\(rank)_of_\(suit)"
    }
    var id = UUID()
    var selected: Bool = false
}

typealias Stack = [Card]

extension Stack where Element == Card {
    func sortByRank() -> Self {
        var sortedHand = Stack()
        var remainingCards = Self()
        
        for _ in 1 ... remainingCards.count {
            var highestCardIndex = 0
            for (i, _) in remainingCards.enumerated() {
                if i + 1 < remainingCards.count {
                    if remainingCards[i + 1].rank >
                        remainingCards[highestCardIndex].rank ||
                        (remainingCards[i + 1].rank == remainingCards[highestCardIndex].rank &&
                         remainingCards[i + 1].suit > remainingCards[highestCardIndex].suit) {
                        highestCardIndex = i + 1
                    }
                }
            }
        }
        return sortedHand
    }
}

struct Player: Identifiable {
    var cards = Stack()
    var playerIsMe: Bool = false
    var id = UUID()
    var activePlayer = false
    var playerName = ""
}

struct Deck {
    private var cards = Stack()
    
    mutating func createFullDeck() {
        for suit in Suit.allCases {
            for rank in Rank.allCases {
                cards.append(Card(rank: rank, suit: suit))
            }
        }
    }
    
    mutating func shuffle() {
        cards.shuffle()
    }
    
    mutating func drawCard() -> Card {
        return cards.removeLast()
    }
    
    func cardsRemaining() -> Int {
        return cards.count
    }
}

struct TienLen {
    private(set) var players: [Player]
    
    private var activePlayer: Player {
        var player = Player()
        
        if let activePlayerIndex = players.firstIndex(where: {$0.activePlayer == true}) {
            player = players[activePlayerIndex]
        } else {
            if let humanIndex = players.firstIndex(where: {$0.playerIsMe == true}) {
                player = players[humanIndex]
            }
        }
        
        return player
    }
    
    init() {
        let opponents = [
            Player(playerName: "Player 1"),
            Player(playerName: "Player 2"),
            Player(playerName: "Player 3"),
        ]
        
        players = opponents
        players.append(Player(playerIsMe: true, playerName: "Me"))
        
        var deck = Deck()
        deck.createFullDeck()
        deck.shuffle()
        
        let randomStartingPlayerIndex = Int(arc4random()) % players.count
        
        while deck.cardsRemaining() > 0 {
            for p in randomStartingPlayerIndex...randomStartingPlayerIndex + (players.count - 1) {
                let i = p % players.count
                let card = deck.drawCard()
                players[i].cards.append(card)
            }
        }
    }
    
    mutating func select(_ card: Card, in player: Player) {
        if let cardIndex = player.cards.firstIndex(where: {$0.id == card.id}) {
            if let playerIndex = players.firstIndex(where: {$0.id == player.id}) {
                players[playerIndex].cards[cardIndex].selected.toggle()
            }
        }
    }
    
    mutating func activatePlayer(_ player: Player) {
        if let playerIndex = players.firstIndex(where: { $0.id == player.id }) {
            players[playerIndex].activePlayer = true
            
            if !players[playerIndex].playerIsMe {
                
            }
        }
    }
    
    func findStartingPlayer() -> Player {
        var startingPlayer: Player!
            
        for aPlayer in players {
               if aPlayer.cards.contains(where: {$0.rank == .three && $0.suit == .clubs}) {
                startingPlayer = aPlayer
            }
        }
        return startingPlayer
    }
}


