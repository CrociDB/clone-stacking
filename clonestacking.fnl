;; title:   Clone Stacking
;; author:  crocidb
;; desc:    figure out a way to leave the world by summoning clones
;; site:    https://crocidb.com/
;; license: MIT License (change this to your license of choice)
;; version: 0.1
;; script:  fennel
;; strict:  true

(var time 0)
(var shake 0)
(var shake-amount 0)
(fn screen-shake [time strength] 
  (set shake time)
  (set shake-amount strength))

;; LIB FUNCTIONS

;; Math
(fn lerp [v0 v1 t]
  (+ (* t v1) (* v0 (- 1 t))))

;; Tables/List
(fn contains [ls e]
  (var occurences 0)
  (each [k v (ipairs ls)] (when (= v e) (set occurences (+ occurences 1))))
  (> occurences 0))

;; Coroutines
(var coroutines {:coroutines [] :remove []})

(fn co-remove []
  (each [k v (ipairs coroutines.remove)]
    (table.remove coroutines.coroutines v))
  (set coroutines.remove []))

(fn co-start [routine]
  (var r (coroutine.create routine))
  (coroutine.resume r)
  (table.insert coroutines.coroutines r))

(fn co-update []
  (each [k v (ipairs coroutines.coroutines)]
    (if (= (coroutine.status v) "dead")
        (let [] 
          (table.insert coroutines.remove k))
        (= (coroutine.status v) "suspended")
        (let []
          (coroutine.resume v))))
  (co-remove))

(fn co-wait-time [s]
  (var starttime time)
  (while (< (- time starttime) s)
    (coroutine.yield)))

;; Particles

(var particles [])
(fn ps-create [x y amount lifetime speed]
  (var ps {:x x :y y :particles [] :lifetime lifetime})
  (for [i 0 amount]
    (var p {
            :active 1
            :x (+ x (math.random -3 3))
            :y (+ y (math.random -3 3))
            :dir (math.random 0 360)
            :lifetime (- lifetime (* lifetime (math.random)))
            :speed (+ speed (* speed (math.random) 2))})
    (table.insert ps.particles p))
  (table.insert particles ps))

(fn ps-update []
  (var rp [])
  (each [k v (ipairs particles)]
    (each [pk pv (ipairs v.particles)]
      (set pv.x (+ pv.x (* pv.speed (math.cos pv.dir))))
      (set pv.y (+ pv.y (* pv.speed (math.sin pv.dir))))

      (set pv.lifetime (- pv.lifetime 1))
      (when (< pv.lifetime 0) (set pv.active 0))

      (when (= pv.active 1) (pix pv.x pv.y 12)))
    (set v.lifetime (- v.lifetime 1))
    (when (< v.lifetime 0) (table.insert rp k)))
  ;; remove particle systems
  (each [rk rv (ipairs rp)] (table.remove particles rv)))

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
   (sprite-draw (. entity.sprites entity.sprite) (math.ceil entity.x) (math.ceil entity.y)))

;; Map
(fn map-create [mx my player goal]
  {:mx mx :my my :player player :goal goal})

(fn map-draw [m]
  (map m.mx m.my 30 17 0 0 0 1 nil))

(fn map-get-tile [m x y]
  (mget x y))

(fn map-check-valid-position [m x y allowed]
  (let [mx (+ m.mx x) my (+ m.mx y)]
    (if (and (>= mx 0) (>= my 0) (< mx 30) (< my 17)) 
      (contains allowed (map-get-tile m mx my))
      false)))

;; GAME STATES

(var game {:update (fn [])})

;; Game

(var player-pick-sprite (sprite-create [260 262] 20 1))
(var playerindicator (entity-create 0.0 0.0 [(sprite-create [258] 18 1)]))

(fn player-entity [] (entity-create 0.0 0.0 [ (sprite-create [288 290] 18 1)
                                        (sprite-create [292 294] 18 1)
                                        (sprite-create [296 298] 18 1)
                                        (sprite-create [300 302] 18 1)]))

(var stategame {:data {} :reset (fn []) :update (fn [])})

(fn player-create [mx my entity]
  {:mx mx :my my :entity entity :state :IDLE :clonepos [] :ix 0 :iy 0})

(fn player-is-any-clone-in-position [pos c]
  (var res 0)
  (each [k v (ipairs c)]
    (when (and (= v.mx pos.x) (= v.my pos.y))
      (set res (+ 1 res))))
  (> res 0))

(fn player-move-to [p dir m c]
  (var mx p.mx)
  (var my p.my)

  (if (= dir :UP)   (set my (- my 2))
      (= dir :DOWN)  (set my (+ my 2))
      (= dir :LEFT)  (set mx (- mx 2))
      (= dir :RIGHT)  (set mx (+ mx 2)))

  (if (= dir :UP)   (set p.entity.sprite 4)
      (= dir :DOWN)  (set p.entity.sprite 1)
      (= dir :LEFT)  (set p.entity.sprite 3)
      (= dir :RIGHT)  (set p.entity.sprite 2))
  
  (var allowed-to-move [2 4 6 8])
  (when (and (map-check-valid-position m mx my allowed-to-move) (not (player-is-any-clone-in-position {:x mx :y my} c)))
    (sfx 12 35 20 0 8 1)
    (set p.mx mx)
    (set p.my my)))

(fn player-position-in-cloning-range [p x y]
  (var res 0)
  (each [k v (ipairs p.clonepos)] 
    (when (and (= v.x x) (= v.y y))
      (set res (+ res 1))))
  (> res 0))

(fn player-move-indicator [p dir m]
  (var mx p.ix)
  (var my p.iy)

  (var poses [])

  (for [i 1 5]
    (if (= dir :UP)   (set my (- my 2))
        (= dir :DOWN)  (set my (+ my 2))
        (= dir :LEFT)  (set mx (- mx 2))
        (= dir :RIGHT)  (set mx (+ mx 2)))
    (when (player-position-in-cloning-range p mx my)
      (table.insert poses {:x mx :y my})))
    
  (when (> (length poses) 0) 
    (sfx 12 55 20 0 8 1)
    (set p.ix (. (. poses 1) :x))
    (set p.iy (. (. poses 1) :y))))
    

(fn player-start-cloning [p m c]
  (sfx 13 75 30 0 8 1)
  (set p.state :CLONING)
  (set p.entity.sprite 1)

  (screen-shake 5 1)

  (var x p.mx)
  (var y p.my)

  (set p.clonepos [])

  (var allowed-cloning [2])
  (for [i (- x 4) (+ x 4) 2]
    (for [j (- y 4) (+ y 4) 2]
      (let [pos {:x i :y j}]
        (if (and (map-check-valid-position m i j allowed-cloning) (not (player-is-any-clone-in-position pos c)))
          (table.insert p.clonepos pos)))))
          
    (set p.ix (. (. p.clonepos 1) :x))
    (set p.iy (. (. p.clonepos 1) :y)))

(fn player-clone-now [p m c setplayer]
  (set p.state :INACTIVE)
  
  (var x (* (+ p.ix m.mx) 8))
  (var y (* (+ p.iy m.my) 8))

  (var newp (player-create p.ix p.iy (player-entity)))
  (set newp.entity.x x)
  (set newp.entity.y y)
  
  (setplayer newp)

  (screen-shake 30 3)
  (sfx 15 43 100 1 2 .1)
  (sfx 16 50 30 0 8 .1)
  
  (ps-create (+ 8 x) (+ 8 y) 100 40 .5))

(fn player-draw-clone [p m]
  (each [k e (ipairs p.clonepos)]
    (sprite-draw player-pick-sprite (* (+ m.mx e.x) 8) (* (+ m.my e.y) 8))))

(fn player-start-idle [p m]
  (sfx 14 72 30 0 8 1)
  (set p.state :IDLE)
  (screen-shake 5 1))

(fn player-die [p killcallback]
  (co-start (lambda [] 
    (set p.state :DEAD)
    (set p.entity.sprite 1)
    (sfx 17 55 60 0 8 .1)
    (co-wait-time 50)
    (screen-shake 10 2)
    (sfx 15 43 100 1 9 .1)
    (killcallback))))

(fn player-update [pl m c setplayer killcallback]
  (var p pl)
  (var tx (* p.mx 8))
  (var ty (* p.my 8))

  (set p.entity.x (lerp p.entity.x tx .3))
  (set p.entity.y (lerp p.entity.y ty .3))

  (when (<= (math.abs (- p.entity.x tx)) .2) (set p.entity.x tx))
  (when (<= (math.abs (- p.entity.y ty)) .2) (set p.entity.y ty))

  (if (= p.state :IDLE)
        (let []
          (when (btnp 0) (player-move-to p :UP m c))
          (when (btnp 1) (player-move-to p :DOWN m c))
          (when (btnp 2) (player-move-to p :LEFT m c))
          (when (btnp 3) (player-move-to p :RIGHT m c))
          (when (btnp 4) (player-start-cloning p m c))
          (when (= (map-get-tile m p.mx p.my) 6) (set p (player-die p killcallback))))
      (= p.state :CLONING)
        (let []
          (when (btnp 0) (player-move-indicator p :UP m))
          (when (btnp 1) (player-move-indicator p :DOWN m))
          (when (btnp 2) (player-move-indicator p :LEFT m))
          (when (btnp 3) (player-move-indicator p :RIGHT m))
          (when (btnp 4) (player-clone-now p m c setplayer))
          (when (btnp 5) (player-start-idle p m)))))

(fn player-draw [p m]
  (entity-draw p.entity)
  
  (when (= p.state :CLONING)
    (player-draw-clone p m)
    (set playerindicator.x (* p.ix 8))
    (set playerindicator.y (* p.iy 8))
    (entity-draw playerindicator)))

(fn player-indicator-draw [pi p]
  (var x p.entity.x)
  (var y (- p.entity.y 12 (* (math.sin (* time .3)) 2)))

  (set pi.x (lerp pi.x x .4))
  (set pi.y (lerp pi.y y .4))

  (entity-draw pi))

(set stategame.data.map (map-create 0 0 {:x 8 :y 8 } {:x 19 :y 8}))
(set stategame.data.player (player-create stategame.data.map.player.x stategame.data.map.player.y (player-entity)))
(set stategame.data.clones [stategame.data.player])

(fn hud-draw [p m]
  (rect 0 0 53 15 15)
  (rect 200 0 240 15 15)
  (spr 288 202 0 0 1 0 0 2 2)
  (print "Level 01" 5 5 13)
  (print "001" 220 5 13)
  (print "X Clone" 198 25 13))

(set stategame.update (fn []
  (cls 0)

  (player-update  stategame.data.player 
                  stategame.data.map 
                  stategame.data.clones
                  (lambda [newp] 
                    (table.insert stategame.data.clones newp)
                    (set stategame.data.player newp))
                  (lambda []
                    (var p (. stategame.data.clones (- (length stategame.data.clones) 1)))
                    (table.remove stategame.data.clones)
                    (set p.state :IDLE)
                    (set stategame.data.player p)
                    p))

  (map-draw stategame.data.map)
  (each [k v (ipairs stategame.data.clones)]
    (player-draw v stategame.data.map))

  (when (= stategame.data.player.state :IDLE)
    (player-indicator-draw playerindicator stategame.data.player))
  
  (hud-draw stategame.data.player stategame.data.map)))

;; INITIALIZATION 

(set game.update stategame.update)

(fn _G.TIC []
  (set time (+ time 1))

  ; screen shake
  (when (> shake 0)
    (poke 0x3ff9 (math.random (- 0 shake-amount) shake-amount))
    (poke 0x3ffa (math.random (- 0 shake-amount) shake-amount))
		(set shake (- shake 1))
    (when (<= shake 0) (memset 0x3ff9 0 2)))

  (game.update)
  
  (co-update)
  (ps-update))

;; <TILES>
;; 002:00ffffff0fe44444fe444444f4444444f4444444f4444444f4444444f4444444
;; 003:ffffff0044444ef0444444ef4444444f4444444f4444444f4444444f4444444f
;; 004:00ffffff0fe44444fe444444f4444444f4444444f4444444f4444444f4444422
;; 005:ffffff0044444ef0444444ef4444444f4444444f4444444f4444444f3344444f
;; 006:00ffffff0f444444f44ffffff4f00000f4f00001f4f00012f4f00010f4f01001
;; 007:ffffff00444444f0fffff44f00000f4f10000f4f21000f4f01000f4f10010f4f
;; 008:00ffffff0fe44444fe444444f4444444f4444477f4447766f4476666f4447766
;; 009:ffffff0044444ef0444444ef7774444f6674444f6674444f6674444f6674444f
;; 018:f4444444f4444444f4444444f4444444f4444444fe4444440fe4444400ffffff
;; 019:4444444f4444444f4444444f4444444f4444444f444444ef44444ef0ffffff00
;; 020:f4444222f4442222f4444222f4444122fd4444110e4444410fed444400ffffff
;; 021:2234444f2223444f2224444f2214444f1144444f144444e044444ef0ffffff00
;; 022:f4f00100f4f00010f4f00001f4f00110f4f00000f44fffff0f44444400ffffff
;; 023:00100f4f01000f4f10000f4f01100f4f00000f4ffffff44f444444f0ffffff00
;; 024:f4444477f4444444f4444444f4444444f4444444fe4444440fe4444400ffffff
;; 025:6674444f7774444f4474444f4474444f4474444f444444ef44444ef0ffffff00
;; </TILES>

;; <SPRITES>
;; 002:0000000000000000000000000000000000000000000000000000333300003222
;; 003:0000000000000000000000000000000000000000000000003333000022230000
;; 004:0000000000000000003330000030000000300000000000000000000000000000
;; 005:0000000000000000000333000000030000000300000000000000000000000000
;; 006:0000000000000000000000000003330000030000000300000000000000000000
;; 007:0000000000000000000000000033300000003000000030000000000000000000
;; 018:0000032200000032000000030000000000000000000000000000000000000000
;; 019:2230000023000000300000000000000000000000000000000000000000000000
;; 020:0000000000000000000000000030000000300000003330000000000000000000
;; 021:0000000000000000000000000000030000000300000333000000000000000000
;; 022:0000000000000000000300000003000000033300000000000000000000000000
;; 023:0000000000000000000030000000300000333000000000000000000000000000
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

;; <MAP>
;; 006:000000000000000020302030203000102030607000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
;; 007:000000000000000021312131213101112131617101110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
;; 008:000000000000000020302030203000102030203080900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
;; 009:000000000000000021312131213101112131213181910000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
;; 010:000000000000000020302030203000102030607000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
;; 011:000000000000000021312131213101112131617101110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
;; </MAP>

;; <WAVES>
;; 000:0469bdefffdba9976554333566677666
;; 002:0123456789abcdef0123456789abcdef
;; 003:009bc034b74679568045778967968958
;; 004:0899abccc75432211148abaa96556665
;; 006:12457989abcccb211000172774788888
;; 008:023456789abbcdeefffeeedccba87510
;; </WAVES>

;; <SFX>
;; 000:400040003000100010001000107010701070207020703070300030704070507050706070700080009070a070b070c070d070e000f000f000f000f000304000000000
;; 012:4460340024001400140014002400240044005400740084009400a400b400c400c400d400e400f400f400f400f400f400f400f400f400f400f400f400304000000000
;; 013:f100f100e100e100d100c100c100b100a1009100810071005100310021001100110001000100010011002100410061008100a100c100e100f100f10070b000000000
;; 014:e100a1006100310021002100110001000100010001000100110011002100310041005100610071009100a100a100b100c100d100d100e100e100f10070b000000000
;; 015:610041c03100217021001100111011001100111011001100210031104100410051107100810091109100a100b11fc10fd10fe10ee11ef10ef10cf11b352000000000
;; 016:6800580038002800188018800880088018801880180028002880388048804880588068806800880088809880a880a880b880c800d800e800e800e80020b000000000
;; 017:260036003670368036802690260d160d167d067d067d067a067a160a160a260a260a367a466046605669660976089608a608b608c668d668e668f608475000000000
;; </SFX>

;; <TRACKS>
;; 000:100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
;; </TRACKS>

;; <PALETTE>
;; 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
;; </PALETTE>

