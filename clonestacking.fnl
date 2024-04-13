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
  {:x x :y y :sprite spritelist})

(fn entity-draw [entity]
   (sprite-draw entity.sprite entity.x entity.y))

;; GAME STATES

(var game {:update (fn [])})

;; Game

(var stategame {:data {} :reset (fn []) :update (fn [])})
(set stategame.data.bomb (entity-create 0 0 (sprite-create [33 35] 10 1)))
(set stategame.update (fn []
  (cls 0)
  (map 0 0 30 17 0 0 1 1 nil)
  (entity-draw stategame.data.bomb)))

;; INITIALIZATION 

(set game.update stategame.update)

(fn _G.TIC []
  (set time (+ time 1))
  (game.update))

;; <TILES>
;; 000:000000000000ff00000fdcf000fdddcf000fddf00000ffdf0000fddd000fdddd
;; 001:0000000000000000000000000000000000000000fff00000ddcf0000dddcf000
;; 002:0000ff00000fdcf000fdddcf000fddf00000ffdf0000fddd000fdddd00fddd2d
;; 003:00000000000000000000000000000000fff00000ddcf0000dddcf000d2ddcf00
;; 004:0000000000000000000000000000000f0000000000000fff0000fddd000fdddd
;; 005:000000000ff00000fdcf0000dddcf000fddf0000fff00000ddcf0000dddcf000
;; 006:00000000000000000000000f0000000000000fff0000fddd000fdddd00fddddd
;; 007:0ff00000fdcf0000dddcf000fddf0000fff00000ddcf0000dddcf000dd2dcf00
;; 008:000000000000ff00000fdcf000fdddcf000fddf00000ffdf0000fddd000fdddd
;; 009:0000000000000000000000000000000000000000fff00000ddcf0000dddcf000
;; 010:0000ff00000fdcf000fdddcf000fddf00000ffdf0000fddd000fdddd00fdd2dd
;; 011:00000000000000000000000000000000fff00000ddcf0000dddcf000ddddcf00
;; 012:0000000000000000000000000000000f0000000000000fff0000fddd000fdddd
;; 013:000000000ff00000fdcf0000dddcf000fddf0000fff00000ddcf0000dddcf000
;; 014:00000000000000000000000f0000000000000fff0000fddd000fdddd00fddddd
;; 015:0ff00000fdcf0000dddcf000fddf0000fff00000ddcf0000dddcf000ddddcf00
;; 016:00fddd2d00fddddd00fedded000fedde0000fedd00000fff0000000000000000
;; 017:d2ddcf00dddddf00dddddf00eeddf000dddf0000fff000000000000000000000
;; 018:00fddddd00fddddd00fedded000fedde0000fedd00000fff0000000000000000
;; 019:dddddf00dddddf00dddddf00eeddf000dddf0000fff000000000000000000000
;; 020:00fddddd00fddddd00fedddd000feddd0000fedd00000fff0000000000000000
;; 021:dd2dcf00dddddf00ddeddf00dddef000dddf0000fff000000000000000000000
;; 022:00fddddd00fddddd00fedddd000feddd0000fedd00000fff0000000000000000
;; 023:dddddf00dddddf00ddeddf00dddef000dddf0000fff000000000000000000000
;; 024:00fdd2dd00fddddd00fedddd000feeed0000fedd00000fff0000000000000000
;; 025:ddddcf00dddddf00dddddf00dddef000dddf0000fff000000000000000000000
;; 026:00fddddd00fddddd00fedddd000feeed0000fedd00000fff0000000000000000
;; 027:dddddf00dddddf00dddddf00dddef000dddf0000fff000000000000000000000
;; 028:00fddddd00fddddd00feddde000feddd0000fedd00000fff0000000000000000
;; 029:ddddcf00eddddf00dddddf00ddddf000dddf0000fff000000000000000000000
;; 030:00fddddd00fddddd00feddde000feddd0000fedd00000fff0000000000000000
;; 031:dddddf00eddddf00dddddf00ddddf000dddf0000fff000000000000000000000
;; </TILES>

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

