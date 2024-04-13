;; title:   Clone Stacking
;; author:  crocidb
;; desc:    figure out a way to leave the world by summoning clones
;; site:    https://crocidb.com/
;; license: MIT License (change this to your license of choice)
;; version: 0.1
;; script:  fennel
;; strict:  true

(var time 0)

;; LIB FUNCTIONS

;; Sprite
(fn sprite-create [idlist speed basecolor]
  {:idlist idlist :speed speed :basecolor basecolor})

(fn sprite-draw [animsprite x y]
  (let [current-sprite (. animsprite.idlist (+ 1 (% (// time animsprite.speed) (length animsprite.idlist))))]
    (spr current-sprite x y 0 animsprite.basecolor 0 0 2 2)))

;; Entity
(fn entity-create [x y spritelist]
  {:x x :y y :sprites spritelist :sprite 1})

(fn entity-draw [entity]
   (sprite-draw (. entity.sprites entity.sprite) entity.x entity.y))

;; GAME STATES

(var game {:update (fn [])})

;; Game

(var stategame {:data {} :reset (fn []) :update (fn [])})
(set stategame.data.player (entity-create 0 0 [(sprite-create [288 290] 15 1)
                                               (sprite-create [292 294] 15 1)
                                               (sprite-create [296 298] 15 1)
                                               (sprite-create [300 302] 15 1)]))
(set stategame.update (fn []
  (cls 0)
  (map 0 0 30 17 0 0 1 1 nil)
  (entity-draw stategame.data.player)))

;; INITIALIZATION 

(set game.update stategame.update)

(fn _G.TIC []
  (set time (+ time 1))
  (game.update))

;; <SPRITES>
;; 032:000000000000ff00000fdcf000fdddcf000fddf00000ffdf0000fddd000fdddd
;; 033:0000000000000000000000000000000000000000fff00000ddcf0000dddcf000
;; 034:0000ff00000fdcf000fdddcf000fddf00000ffdf0000fddd000fdddd00fddd2d
;; 035:00000000000000000000000000000000fff00000ddcf0000dddcf000d2ddcf00
;; 036:0000000000000000000000000000000f0000000000000fff0000fddd000fdddd
;; 037:000000000ff00000fdcf0000dddcf000fddf0000fff00000ddcf0000dddcf000
;; 038:00000000000000000000000f0000000000000fff0000fddd000fdddd00fddddd
;; 039:0ff00000fdcf0000dddcf000fddf0000fff00000ddcf0000dddcf000dd2dcf00
;; 040:000000000000ff00000fdcf000fdddcf000fddf00000ffdf0000fddd000fdddd
;; 041:0000000000000000000000000000000000000000fff00000ddcf0000dddcf000
;; 042:0000ff00000fdcf000fdddcf000fddf00000ffdf0000fddd000fdddd00fdd2dd
;; 043:00000000000000000000000000000000fff00000ddcf0000dddcf000ddddcf00
;; 044:0000000000000000000000000000000f0000000000000fff0000fddd000fdddd
;; 045:000000000ff00000fdcf0000dddcf000fddf0000fff00000ddcf0000dddcf000
;; 046:00000000000000000000000f0000000000000fff0000fddd000fdddd00fddddd
;; 047:0ff00000fdcf0000dddcf000fddf0000fff00000ddcf0000dddcf000ddddcf00
;; 048:00fddd2d00fddddd00fedded000fedde0000fedd00000fff0000000000000000
;; 049:d2ddcf00dddddf00dddddf00eeddf000dddf0000fff000000000000000000000
;; 050:00fddddd00fddddd00fedded000fedde0000fedd00000fff0000000000000000
;; 051:dddddf00dddddf00dddddf00eeddf000dddf0000fff000000000000000000000
;; 052:00fddddd00fddddd00fedddd000feddd0000fedd00000fff0000000000000000
;; 053:dd2dcf00dddddf00ddeddf00dddef000dddf0000fff000000000000000000000
;; 054:00fddddd00fddddd00fedddd000feddd0000fedd00000fff0000000000000000
;; 055:dddddf00dddddf00ddeddf00dddef000dddf0000fff000000000000000000000
;; 056:00fdd2dd00fddddd00fedddd000feeed0000fedd00000fff0000000000000000
;; 057:ddddcf00dddddf00dddddf00dddef000dddf0000fff000000000000000000000
;; 058:00fddddd00fddddd00fedddd000feeed0000fedd00000fff0000000000000000
;; 059:dddddf00dddddf00dddddf00dddef000dddf0000fff000000000000000000000
;; 060:00fddddd00fddddd00feddde000feddd0000fedd00000fff0000000000000000
;; 061:ddddcf00eddddf00dddddf00ddddf000dddf0000fff000000000000000000000
;; 062:00fddddd00fddddd00feddde000feddd0000fedd00000fff0000000000000000
;; 063:dddddf00eddddf00dddddf00ddddf000dddf0000fff000000000000000000000
;; </SPRITES>

;; <WAVES>
;; 000:00000000ffffffff00000000ffffffff
;; 001:0123456789abcdeffedcba9876543210
;; 002:0123456789abcdef0123456789abcdef
;; </WAVES>

;; <SFX>
;; 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
;; </SFX>

;; <TRACKS>
;; 000:100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
;; </TRACKS>

;; <PALETTE>
;; 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
;; </PALETTE>

