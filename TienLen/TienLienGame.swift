//
//  TienLienGame.swift
//  TienLen
//
//  Created by Dylan Dao on 7/7/23.
//

import Foundation

class TienLenGame: ObservableObject {
    @Published private var model = TienLen()
    
    var players: [Player] {
        return model.players
    }
    
    func select(_ card:Card, in player: Player) {
        model.select(card, in: player)
    }
    
    func evaluateHand(_ cards: Stack) -> HandType {
        return HandType(cards)
    }
    
    func activatePlayer( _ player: Player) {
        model.activatePlayer(player)
    }
    
    func findStartingPlayer() -> Player {
        return model.findStartingPlayer()
    }
}
