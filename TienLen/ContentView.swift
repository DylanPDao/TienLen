//
//  ContentView.swift
//  TienLen
//
//  Created by Dylan Dao on 7/7/23.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var tienLen = TienLenGame()
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                LazyVGrid(columns: [GridItem(.adaptive(minimum:90), spacing: -65)]) {
                    ForEach(tienLen.players[0].cards) { card in
                        CardView(card:card)
                    }
                }
                        .frame(height: geo.size.height/6)
                LazyVGrid(columns: [GridItem(.adaptive(minimum:90), spacing: -65)]) {
                    ForEach(tienLen.players[1].cards) { card in
                        CardView(card:card)
                    }
                }
                .frame(height: geo.size.height/6)
                LazyVGrid(columns: [GridItem(.adaptive(minimum:90), spacing: -65)]) {
                    ForEach(tienLen.players[2].cards) { card in
                        CardView(card:card)
                    }
                }
                .frame(height: geo.size.height/6)
                Rectangle()
                    .foregroundColor(Color.yellow)
                let playerHand = tienLen.players[3].cards.filter {
                    $0.selected == true
                }
                let handType = "\(tienLen.evaluateHand(playerHand))"
                Text(handType)
                    .font(.title)
                LazyVGrid(columns: [GridItem(.adaptive(minimum:90), spacing: -65)]) {
                    ForEach(tienLen.players[3].cards) { card in
                        CardView(card: card)
                            .offset(y: card.selected ? -30 : 0)
                            .onTapGesture {
                                tienLen.select(card, in: tienLen.players[3])
                            }
                    }
                }
            }
            .onAppear() {
                print("On Appear")
                let playerWithLowCard = tienLen.findStartingPlayer()
                tienLen.activatePlayer(playerWithLowCard)
                print(playerWithLowCard.playerName)
            }
        }
    }
}

struct CardView: View {
    var card: Card
    
    var body: some View {
        Image(card.filename)
            .resizable()
            .aspectRatio(2/3, contentMode: .fit)
            .scaledToFit()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
