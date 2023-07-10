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
                ForEach(tienLen.players) { player in
                    if !player.playerIsMe {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum:90), spacing: -65)]) {
                            ForEach(player.card) { card in
                                CardView(cardName:card.filename)
                            }
                        }
                        .frame(height: geo.size.height/6)
                    }
                }
                Rectangle()
                    .foregroundColor(Color.yellow)
                let playerHand = tienLen.players[3].cards.filter {
                    $0.selected == true
                }
                let handType = "\(tienLen.evaluateHand(playerHand))"
                Text(handType)
                    .font(.title)
                let myPlayer = tienLen.players[3]
                LazyVGrid(columns: [GridItem(.adaptive(minimum:90), spacing: -65)]) {
                    ForEach(myPlayer.cards) { card in
                        CardView(card: card)
                            .offset(y: card.selected ? -30 : 0)
                            .onTapGesture {
                                tienLen.select(card, in: myPlayer)
                            }
                    }
                }
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
