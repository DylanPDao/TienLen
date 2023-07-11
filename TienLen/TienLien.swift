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

struct DiscardHand: Identifiable {
    var hand: Stack
    var handOwner: Player
    var id = UUID()
}

struct TienLen {
    private(set) var discardedHand = [DiscardHand]()
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
                let cpuHand = getCPUHand(of: activePlayer)
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
    
    func getCPUHand(of player: Player) -> Stack {
        var pairExist = false, threeExist = false, fourExist = false, straightExist = false
        var rankCount = [Rank: Int]()
        var suitCount = [Suit: Int]()
        
        let playerCardsByRank = player.cards.sortByRank()
        
        for card in playerCardsByRank {
            if rankCount[card.rank] != nil {
                rankCount[card.rank]! += 1
            } else {
                rankCount[card.rank] = 1
            }
            
            if suitCount[card.suit] != nil {
                suitCount[card.suit]! += 1
            } else {
                suitCount[card.suit] = 1
            }
        }
        
        var cardsRankCount1 = 1
        var cardsRankCount2 = 1
        var thisRankCount = 0
        
        for rank in Rank.allCases {
            if rankCount[rank] != nil {
                thisRankCount = rankCount[rank]!
            } else {
                continue
            }
        
        // check if there are ranks > 1
        if thisRankCount > cardsRankCount1 {
            if cardsRankCount1 != 1 {
                cardsRankCount2 = cardsRankCount1
            }
            cardsRankCount1 = thisRankCount
        } else if thisRankCount > cardsRankCount2 {
            cardsRankCount2 = thisRankCount
        }
        
            pairExist = cardsRankCount1 > 1
            threeExist = cardsRankCount1 > 2
            fourExist = cardsRankCount1 > 3
            
            if straightExist {
                continue
            } else {
                straightExist = true
            }
            
            for i in 0 ... 4 {
                var rankRawValue = 1
                
                if rank <= Rank.ten {
                    rankRawValue = rank.rawValue + i
                } else if rank >= Rank.ace {
                    rankRawValue = (rank.rawValue + i) % 13
                    if rankRawValue == 0 {
                        rankRawValue = 13
                    }
                }
                
                if rankCount[Rank(rawValue: rankRawValue)!] != nil {
                    straightExist = straightExist && rankCount[Rank(rawValue: rankRawValue)!]! > 0
                } else {
                    straightExist = false
                }
            }
        }
        
        // Singles
        var validHands = combinations(player.cards, k: 1)
        
        // Pairs
        if pairExist {
            var possibleCombination = Stack()
            for card in playerCardsByRank {
                if rankCount[card.rank]! > 1 {
                    possibleCombination.append(card)
                }
            }
            let possibleHands = combinations(possibleCombination, k: 2)
            
            for i in 0 ..< possibleCombination.count {
                if HandType(possibleHands[i]) != .Invalid {
                    validHands.append(possibleHands[i])
                }
            }
        }
        
        // Three of a kind
        if threeExist {
            var possibleCombination = Stack()
            for card in playerCardsByRank {
                if rankCount[card.rank]! > 1 {
                    possibleCombination.append(card)
                }
            }
            let possibleHands = combinations(possibleCombination, k: 3)
            
            for i in 0 ..< possibleCombination.count {
                if HandType(possibleHands[i]) != .Invalid {
                    validHands.append(possibleHands[i])
                }
            }
        }
        
        // Four of a kind
        if fourExist {
            var possibleCombination = Stack()
            for card in playerCardsByRank {
                if (fourExist && rankCount[card.rank]! > 3) {
                    possibleCombination.append(card)
                }
            }
            let possibleHands = combinations(possibleCombination, k: 5)
            
            for i in 0 ..< possibleCombination.count {
                if HandType(possibleHands[i]) != .Invalid {
                    validHands.append(possibleHands[i])
                }
            }
        }
        
        var returnHand = Stack()
        for hand in validHands {
            if let lastDiscardHand = discardedHand.last {
                
            } else {
                if hand.contains(where: { $0.rank == Rank.three && $0.suit == Suit.clubs}) {
                    returnHand = hand
                }
            }
        }
        return returnHand
    }
    
    func combinations(_ cardArray: Stack, k: Int) -> [Stack] {
        
        var sub = [Stack]()
        var ret = [Stack]()
        var next = Stack()
        
        for i in 0 ..< cardArray.count {
            if k == 1 {
                var tempHand = Stack()
                tempHand.append(cardArray[i])
                ret.append(tempHand)
            } else {
                sub = combinations(sliceArray(cardArray, x1: i+1, x2: cardArray.count - 1), k: k-1)
                
                for subI in 0 ..< sub.count {
                    next = sub[subI]
                    next.append(cardArray[i])
                    ret.append(next)
                }
            }
        }
        return ret
    }
        
        func sliceArray(_ cardArray: Stack, x1: Int, x2: Int) -> Stack {
            var sliced = Stack()
            
            if x1 <= x2 {
                for i in x1 ... x2 {
                    sliced.append(cardArray[i])
                }
            }
            return sliced
        }
}


