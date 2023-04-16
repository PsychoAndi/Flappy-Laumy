pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--main
--
--09.04.2023

function _init()
--framecounter, blinktimer
	t=0
	blinkt=1
 
--cartridge data highscore
	cartdata("lofl")
 	--dset(1,0) --reset hiscore
 
--general init
	setup()
end

function _update()
--increase framecounter used 
--for animations
	t+=1
	
--for blinking text/squares
	blinkt+=1
	
--begin game or after gameover
	if game_stat=="begin" then
		upd_title()
		upd_bird()
	end
	
--run-loop
	if game_stat=="play" then
	--timer 1 per second
		upd_timer()
		
	--gamepad check
		check_buttons()
		
	--frame updates
	 	upd_clouds()
		upd_player()
		upd_heart()
		upd_cow()
		upd_bird()
		check_col()
		
		upd_worm()
	end	
	
	--game ends
	if game_stat=="over" or 
	   game_stat=="high" then
		upd_clouds()
		upd_bird()
		upd_over()
	end
end

function _draw()
--draw frame	
	if game_stat=="begin" then
		cls(1)
	 
		draw_title()
		draw_bird()
	end
	
	if game_stat=="play" then
	--blue background
		cls(12)
	
		draw_back()
		draw_clouds()
		draw_bird()
		draw_worm()
		draw_sun()
		draw_sign()
		
		draw_timer()
		draw_players()
		draw_cow()
		draw_heart()
		draw_parts()
		
		draw_score()
	end

	if game_stat=="over" or
	   game_stat=="high" then
		cls(12)
	 
		draw_sun()
		draw_players()
		draw_bird()
		draw_clouds()
		draw_back()
		if game_stat=="over" then
			draw_over()
		else
			draw_high()
		end
	end
end

-->8
--update

function upd_player()
--players fall the whole time 
	fall(ram,ram.bot)
	fall(lau,lau.bot)
end

function upd_cow()
--cow up/down
	if cow.y<=cow.min_y then
		cow.dir=1
	end
	if cow.y>=cow.max_y then
		cow.dir=-1
	end
	cow.y+=cow.dir*cow.spd
end

function upd_bird()
--from time to time there is a 
--bird flying 
	if rnd(200)>199 then
	--bird not flying yet
		if not(bird.fly) then
	 	bird.fly=true
	 	showsign=true
	 	--y-pos between min and max
			bird.y=bird_miny+
			flr(rnd(bird_maxy))
		end
	end
	--bird flies 
	if bird.fly and 
		bird.dir==1 then
		if bird.x<128 then
			bird.x+=1*bird.spd
			if bird.x>4 then
	  	showsign=false
   end
		else
			bird.dir=-1
			bird.x=blr[2]
			bird.fly=false
		end
	end
	if bird.fly and
	   	bird.dir==-1 then
		if bird.x>-8 then
	  bird.x-=1*bird.spd
	  if bird.x<122 then
	  	showsign=false
   end
		else
			bird.dir=1
			bird.x=blr[1]
			bird.fly=false
	 end
	end
end

function upd_worm()
--from time to time there is a 
--worm crouching
	if rnd(100)>99 then
		if not(worm.mov) then
	 	worm.mov=true
		end
	end
	--worm is active and long
	if worm.cf==24 then
		if worm.mov and
			worm.dir==1 then
	 	if worm.x<128 then
	  	worm.x+=1*worm.spd
	 	else
			worm.dir=-1
			worm.x=128
			worm.mov=false
	 	end
		end
		if worm.mov and
		   	worm.dir==-1 then
			if worm.x>0 then
				worm.x-=1*worm.spd
			else
				worm.dir=1
				worm.x=-8
				worm.mov=false
			end
		end
	end
end

function upd_heart()
--if the direction of the heart
--is not zero, then it is moving
--inside the screen (0..128)
--the sun changes l/r when 
--the heart hits nothing
	if hrz.dir==1 then
 	if hrz.x<128 then
  	hrz.x+=1*hrz.spd
 	else
		hrz.dir=0
		hrz.x=0
		change_sun()
 	end
	end
	if hrz.dir==-1 then
		if hrz.x>0 then
	 	hrz.x-=1*hrz.spd
		else
			hrz.dir=0
			hrz.x=0
			change_sun()
		end
	end
end

function check_col()
--if there is a heart moving, check
--collision. play a sound and an
--animation, increase score, change
--sun l/r
 if hrz.dir==1 then
		if col(hrz,lau) then
			sfx(hrz.hsfx)
			hrz.dir=0
			score+=1
			hit(lau.x,lau.y)
			change_sun()
		end
	end
	if hrz.dir==-1 then
		if col(hrz,ram) then
			sfx(hrz.hsfx)
			hrz.dir=0
			score+=1
			hit(ram.x,ram.y)
			change_sun()
		end
	end
	if hrz.dir!=0 then
		if col(hrz,cow) then
		 sfx(cow.hsfx)
		 hrz.dir=0
		 hit(cow.x,cow.y)
		 cow.hits+=1
		 if cow.dir==1 then
		  cow.dir=-1
		 elseif cow.dir==-1 then
			 cow.dir=1
   end
   change_sun()
	 end
 end
--if player collides with
--bird, set score to zero and
--calculate new bird pos
 if col(ram,bird) or 
 	  col(lau,bird) then
 		hit(bird.x,bird.y)
 		bird.x=rnd(blr)
 		bird.y=bird_miny+
	         flr(rnd(bird_maxy))
		bird.fly=false
		sfx(6)
		score=0
	end
end

function upd_clouds()
	for i=1,#clouds do
		clouds[i].x+=clouds[i].spd*clouds[i].dir
		if clouds[i].x>112 then
			clouds[i].dir=-1
		elseif clouds[i].x<0 then
	 		clouds[i].dir=1
		end
	end
end

function upd_timer()
--timer, every 30 frames=1 sec
--decrease 1
	if game_started then
		if t%30==0 then
	 		ptim-=1
	 	--sound when under 10 sec left
			if (ptim<10) and (ptim>-1) then
				sfx(5)
			end
			--speedup cow at 30 sec
			if ptim<30 then
    		cow.spd=1.5
   		end
			--more speedup at 15 sec
			if ptim<15 then
				cow.spd=2
			end
			if ptim<0 then
			--music off
				music(-1)
				game_started=false
				if score>hscore then
					music(1)
					dset(1,score)
					game_stat="high"	 	 	
				else
     			sfx(12)
					game_stat="over"
				end
	 		end
		end
	end
end

function upd_title()
--cow shakes head every second
	if t%30==0 then 
 		ch_y=3
	end
 
	if t%60==0 then
		ch_y=2
	end
 
	if btn(5,0) or btn(5,1) then
	--new game, reset all, then play
		setup()
		game_stat="play"
		music(0)
	end
end

function upd_over()
	--5 seconds until the 
	--text "press up" appears
 	go_timer()
 
 	if showtxt then
		if btn(4,0) or btn(4,1) then
	  	game_stat="begin"
		end
	end
end

-->8
--draw

function draw_players()
--draw players (2 sprites)
--when sun is at the same side,
--draw the little heart
	spr(getframe(ram.ani_t),
	    ram.x,ram.y)
	spr(getframe(ram.ani_b),
	    ram.x,ram.y+8)
	if hrz.dir==0 and 
	   sun.x==slr[1] then
		spr(10,ram.x+3,ram.y+4)
	end
	    
	spr(getframe(lau.ani_t),
	    lau.x,lau.y)
	spr(getframe(lau.ani_b),
	    lau.x,lau.y+8)
	if hrz.dir==0 and 
	   sun.x==slr[2] then
	 	spr(10,lau.x-4,lau.y+4)
	end
end

function draw_heart()
--draw heart only when its moving
	if hrz.dir!=0 then
	 	spr(getframe(hrz.ani),
	      hrz.x,hrz.y)
	end
end

function draw_cow()
--draw the cow obstacle
	if t>50 then
		spr(getframe(cow.ani_t),cow.x,cow.y)
		spr(getframe(cow.ani_b),cow.x-1,cow.y+8)
		spr(getframe(cow.ani_l),cow.x-6,cow.y+8)
		spr(getframe(cow.ani_r),cow.x+7,cow.y+8)
	end
end

function draw_score()
	print("score: "..score,30,2,7)
	print("hi: "..hscore,80,2,5)
end

function draw_timer()
--show time in cloud
	local col,xoff
 	xoff=0
 
 	if (ptim>=10) col=3
	if ptim<10 then
	--red text
		col=8
		xoff=2
	end
	print(ptim,58+xoff,10,col)
end

function draw_parts()
--particle-animation on hit
	for myp in all(parts) do
		pset(myp.x,myp.y,10)
		
		myp.x+=myp.sx
		myp.y+=myp.sy
		
		myp.sx=myp.sx*0.85
		myp.sy=myp.sy*0.85
		
		myp.age+=1
	
		if myp.age>myp.maxage then
			myp.size-=0.5
			if myp.size<0 then
				del(parts,myp)
			end
		end
	end
end

function draw_clouds()
	for i=1,#clouds do
		spr(clouds[i].sp_l,
			clouds[i].x,clouds[i].y)
		spr(clouds[i].sp_r,
			clouds[i].x+8,clouds[i].y)
	end 
end

function draw_bird()
	if bird.dir==1 then
		spr(getframe(bird.ani),
	     bird.x,bird.y)
	end
	--flip the sprite
	if bird.dir==-1 then
		spr(getframe(bird.ani),
	     bird.x,bird.y,1,1,true)
	end
end

function draw_worm()
	worm.cf=getframe(worm.ani)
	spr(worm.cf,worm.x,worm.y)
end

function draw_back()
--draw bg
	rectfill(0,124,128,128,11)
--flowers
	spr(28,56,108)
	spr(29,64,108)
	spr(44,56,116)
	spr(45,64,116)
--timer in cloud
	spr(46,54,9)
	spr(47,62,9)
end

function draw_sun()
--draw the sun
	if (sun.sl) sun.x=slr[1] else sun.x=slr[2]
	circfill(sun.x,sun.y,getframe(sun.ani),10)
end

function draw_sign()
	local of=0

	if (bird.dir==-1) of=61
	
	if showsign then
		spr(144,24+of,115)
		spr(145,32+of,115)
  	spr(146,40+of,115)
  	spr(161,32+of,123)
  	rect(23+of,114,41+of,122,blink("r"))
	end
end

function draw_title()
--titlescreen
 	rectfill(0,35,128,95,12)
 	rectfill(0,90,128,95,11)

	local ly=30
	local lx=17
	local py=75
	local px=16
	local lin={63,79,95,111}
 
--logo
	for i=1,4 do
		for j=1,10 do
			spr(j+lin[i],lx+j*8,ly+i*8)
		end
	end
	
--player
	spr(getframe(ram.ani_t),px,py)
	spr(getframe(ram.ani_b),px,py+8)
	spr(getframe(lau.ani_t),px+88,py)
	spr(getframe(lau.ani_b),px+88,py+8)
	spr(10,px+84,py+5)

--curtain
	for i=1,8 do
		spr(108,66,py+10)
		spr(92,66,py+ch_y)
		spr(109,74,py+10)
--flowers
		spr(28,46,py-1)
		spr(29,54,py-1)
		spr(44,46,py+7)
		spr(74,i*16-16,0,2,1)
		spr(74,i*16-16,17,2,1)
	end

--cow
	spr(93,74,py+2)
	spr(45,54,py+7)
		
	print("schnullersoft presents",21,10,12) 
	print("press ❎ to start",30,115,blink("t"))
	print("highscore:"..hscore,42,100,7)
end

function draw_high()
--new highscore
	local spw=0
 
--background
	rectfill(35,44,95,63,9)
	rect(35,44,95,63,blink("r"))

--logo "new high!"
	for i=128,134 do
		spr(i,40+spw,45)
		spw+=8
	end
	
	if showtxt then
		print("press -up-",47,57,blink("t"))
	end
end

function draw_over()
--game over
	local w=0
 
--background
	rectfill(35,44,95,63,13)
	rect(35,44,95,63,blink("r"))

	print("game over",48,46,
	      blink("t"))
	      
	if showtxt then
	 print("press -up-",46,57,
	       blink("t"))
	end
end
-->8
--support

function getframe(ani)
--get next animation frame
	return ani[flr(t/8)%#ani+1]
end

function col(a,b)
--check, if sprite a collides
--with sprite b
	local a_left=a.x
	local a_right=a.x+a.cox
	local a_bottom=a.y+a.coy
	local a_top=a.y-a.coy
	
	local b_left=b.x
	local b_right=b.x+b.cox
	local b_bottom=b.y+b.coy 
	local b_top=b.y

	if a_left>b_right then return false end
	if b_left>a_right then return false end
	if a_top>b_bottom then return false end
	if b_top>a_bottom then return false end
 
	return true
end

function change_sun()
--changes the side, where sun will appear
	sun.sl=not(sun.sl)
end

function blink(mode)
	local anim={}
	if mode=="r" then
	--square
		col_anim={8,8,8,8,
				9,9,9,9,
				10,10,10,10,
				9,9,9,9}
	elseif mode=="t" then
	--textcolours
		col_anim={5,5,
				6,6,6,6,6,6,
				7,7,7,7,7,7}
	end
	
	if blinkt>#col_anim then
		blinkt=1
	end

	return col_anim[blinkt]
end

function save_high()
	dset(0,hscore)
end

function go_timer()
--
	if t%30==0 then
	 	go+=1
	 	if go>gotim then
	  	go=0
	  	showtxt=true
	 	end
	end	
end

-->8
--actions

function check_buttons()
--ramy up
	if (btn(4,0)) mov_up(ram)
--laura up
	if (btn(4,1)) mov_up(lau)
--ramy fires if sun=left
	if btnp(5,0) then 
		if sun.x==slr[1] then
			shoot_heart(ram)
		end
	end
--laura fires if sun=right
	if btnp(5,1) then
		if sun.x==slr[2] then 
			shoot_heart(lau)
		end
	end
end

function fall(pl,y_max)
--player moves down because of
--gravity
	if pl.y<y_max then
		pl.grav*=acc
		pl.y=pl.y+pl.grav
	end
 
	if pl.y>=y_max then 
		pl.y=y_max
	end
		
	if pl.grav>=maxgrav then
		pl.grav=maxgrav
	end
end

function mov_up(pl)
--moves player up
 	pl.y=pl.y-2*pl.grav
	if pl.y<=8 then
		pl.y=8
	end
end

function shoot_heart(p)
--starts the heart, when no heart
--is on the screen. checks if the
--player is between his bounds
	if hrz.dir==0 and 
	  p.y<y_bottom and 
	  p.y>y_top then
  
		--game starts with first shot
		if game_started==false then
			game_started=true
			music(2)
		end
		
		--fires from player-position
		hrz.y=p.y
		hrz.x=p.x
		--set direction
		hrz.dir=p.hdir 
		--play sound 
		sfx(p.fsfx)
	end
end

function hit(px,py)
--array for particle-animation
--plays on collision
	for i=1,30 do
		local myp={}
		myp.x=px
		myp.y=py
		
		myp.sx=rnd(6)-3
		myp.sy=rnd(6)-3
		
		myp.age=rnd(10)
		myp.size=3+rnd(5)
		myp.maxage=5+rnd(5)
		
		add(parts,myp)
	end
end

-->8
--setup

--set all variables to their
--standard

function setup()
--game duration in seconds
	s=60
 
--game timer
	ptim=s

--gameover timer
	gotim=5
	go=0
	showtxt=false
 
--get highscore 
	hscore=dget(1)
 
--game status
	game_stat="begin"

--game start
 game_started=false

 score=0

 cloud_rows=5
 
--x-startpos bird,sun,worm
	blr={-28,156}
	slr={5,123}
	sl={true,false}
	wlr={-8,128} 
  
--bird bounds
	bird_miny=15
	bird_maxy=60
	showsign=false
	
--physics(gravitation)
	grav=0.5 
	maxgrav=2  
	acc=1.1 
 
--particle effect array
 	parts={}
 
--shooting boundaries
	y_bottom=95
	y_top=25

 --player
	ram={x=10,y=100,
			 ani_t={1,2,3,4},
			 ani_b={17,18,19,20},
			 grav=grav,cox=6,coy=14,
			 hdir=1,fsfx=0,bot=109}
	     
	lau={x=110,y=100,
			 ani_t={33,34,35,36},
			 ani_b={49,50,51,52},
			 grav=grav,cox=4,coy=14,
			 hdir=-1,fsfx=1,bot=109}
 
--sun
 sun={x=0,y=-2,col=10,
      ani={9,9,10,10,
           11,11,10,10},
      sl=rnd(sl)}
      
--heart
 	hrz={x=0,y=0,cox=2,coy=2,
       ani={10,11},
       spd=3,dir=0,hsfx=2}
      
--cow
 	cow={x=60,y=30,
			 min_y=16,max_y=100,
			 spd=1,dir=1,hits=0,
			 cox=0,coy=14,
			 ani_t={42,41},
			 ani_l={57,56,55},
			 ani_r={59,60,61},
			 ani_b={58,58,58,43,43,43},
			 hsfx=3}
 	ch_y=2
  
--bird
 	bird={x=rnd(blr),y=14,
				spd=0.4,dir=rnd({-1,1}),
				fly=false,cox=4,coy=14,
				ani={25,26,27},hsfx=6} 
 
--worm
	worm={x=rnd(wlr),y=119,
				spd=0.05,dir=rnd({-1,1}),
				mov=false,
				ani={23,23,24,24},
				cf=0} 
 
--clouds
	clouds={}
	for i=1,cloud_rows do
		c={x=-12+i*24,y=8+i*8,dir=1,
		spd=0.03*i,sp_l=30,sp_r=31}
		add(clouds,c)
		c={x=116-i*16,y=2+i*8,dir=-1,
			 spd=0.03*i,sp_l=30,sp_r=31}
		add(clouds,c)
	end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007777700000
00000000000000000000000000000000000000000000000000000000000880000008800000000000000000000880088000000000000000000007777777777000
00700700009999000000000000999900000000000000000000000000088888800888888000088000000808008888888800000000000000000077777000777700
00077000099494000099990009949400009999000000000000000000887777888888888800888800008888808888778800000000000000000077777770777700
00077000099999900994940009999990099494000000000000000000088888800888888000888800008877808888888800000000000000000067777707777600
007007000999ee90099999900999ee90099999900000000000000000000880000008800000088000000888000888888000000000000000000006777077776000
00000000009999000999ee90009999000999ee900000000000000000000000000000000000000000000080000088880000000000000000000000667777660000
00000000000990000099990000099000009999000000000000000000000000000000000000000000000000000008800000000000000000000000006666000000
0000000000d9d00000d9d00000d9d00000d9d0000000000000000000000000000000000000007700000077000000770000000000000000000000007777700000
0000000009ddd90009ddd90009ddd90009ddd90000000000000000000000000000000000000a7570040a7570000a757000000000000000000007777777777000
0000000009ddd90099ddd99009ddd900099d99000000000000000000000000000000000004aa77704a4a77700aaa777000000000000000000777777777777700
000000000ddddd000ddddd000ddddd000ddddd00000000000000000000000000000000004a4aa9994a4aa99904aaa99900000000000000000777777777777700
000000000ddddd000ddddd000ddddd000ddddd00000000000000000000000000000000004a4a999004aa99904a4a999000000000000a00000677777777777600
0000000003d0d3000dd0d00003d0d3003d000d300000000000000000000444000000000004aaa00000aaa0004a4aa00000000000a0a8a0a00066777777776000
000000000330330003003000033033003300033000000000000000000004040000000000000dd000000dd000040dd00000000a0a8a0a0a8a0000667777660000
0000000000000000000000000000000000000000000000000000000000440440044444400000000000000000000000000000a8a0a0a8a0a00000006666000000
0000000000000000000000000000000000000000000000000000000000000000000000000060006000600060000d222d000a0a0a0a0a0a8a0007777777777000
00000000000aaa0000000000000aaa0000000000000000000000000000000000000000000f6fff6f0f6fff6f000fffff00a8aba8a8aba0a00777777777777770
0000000000aaaaa0000aaa0000aaaaa0000aaa00000000000000000000000000000000000ef8f8fe0ef1f1fe000ddddd000a0aba0aba8a007777777777777777
0000000000bfbfa000aaaaa000bfbfa000aaaaa00000000000000000000000000000000000fdddf000fdddf000044044000ba8ababb0a0a07777777777777777
000000000fffffa000bfbfa00fffffa000bfbfa00000000000000000000000000000000000dfffd000dfffd00000000000a0ba0a8a0aba8a6777777777777776
000000000feeffa00fffffa00feeffa00fffffa0000000000000000000000000000000000dfefefd0dfefefd000000000a8abbababa8a0a00677777777777760
0000000000ffff0a0feeffa000ffff0a0feeffa00000000000000000000000000000000000dfffd000dfffd00000000000a0ba8ab0babb000067777777776600
00000000000ff00000ffff0a000ff00000ffff0a00000000000000000000000000000000000ddd00000ddd00000000000000b0a0b0b00b000006666666660000
000000000007f7000007f7000007f7000007f700000000000000000000000000000000000000ddd0000d222d0ddd000000000000000000000000000000000000
0000000000f777f000f777f000f777f000f777f000000000000000000000000000000ddd0000dfff000ffffffffd0000ddd00000000000000000000000000000
0000000000f777f00ff777ff00f777f000ff7ff00000000000000000000000dd00000dff000000df000ffffffd000000ffd00000dd0000000000000000000000
00000000007777700077777000777770007777700000000000000000000000df0000000d0000000d000dddddd0000000d0000000fd0000000000000000000000
00000000007777700077777000777770007777700000000000000000000000000000000000000000000440440000000000000000000000000000000000000000
00000000008707800007077000870780087000780000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008808800008008000880880088000880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000070000000000000000000000000000000000000000007000000000000000000770000088888880999999900000000000000000000000000000000
08800880000700000000000000000000000000000000000000000070000000000000000007000000088888880999999900000000000000000000000000000000
88888888000700000007770000077700000777000707700000000070000000000777000070000000088888880999999900000000000000000000000000000000
88887788007000000070070000700070007007000070070000077700000000007000700077000000088888880999999900000000000000000000000000000000
88888888007000000777770007000070077777000070070000700700000000007000700700000000088888880999999900000000000000000000000000000000
08888880070000000700000007000070070000000070070007000700000000070007000700000000088888880999999900000000000000000000000000000000
00888800070000000700000007007700070000000700700007000700000000070007007000000000088888880999999900000000000000000000000000000000
00088000077777000077700000770000007770000700700000777070000000007770007000000000008888800099999000000000000000000000000000000000
00000000000000000000000007007000000000000000000000000000000000000000070000000000000000000000000000600060000000000000000000000000
0000000000000000000000007000700000000000000000000000000000000000000007000000000000000000000000000f6fff6f000000000000000000000000
0000077777777777777777777000777777777777777777777777777777777777777770000000000000000000000000000ef1f1fe000000000000000000000000
00007000000000000000000077770000000000000000000000000000000000000000000000000000000000000000000000fdddf0000000000000000000000000
00007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dfffd0000000000000000000000000
0000700777770070000000000000000000000000000007000000000000000000000000000000000000000000000000000dfefefdffff00d00000000000000000
00007007000000700000000000000000000000000000700000000000000000000000000000000000000000000000000000dfffdfff6fff000000000000000000
000700700000070000000000000000000000000000007000000000000000000000000000000000000000000000000000000dddfffff6f0000000000000000000
00070077770007007770007770007770007007000007000000777000700070007707700070070000000000000000000000009ff6f6fff0000000000000000000
000700700000700700070700070700070700070000070000070007007000700700700707000700000000000000000000000999f6ffff00000000000000000000
007000700000707000700700070700070700700000700000700070070007000700700707007000000000000000000000000999ff0eff00000000000000000000
007007000007007000700770070770070700700000700000700070070007007007007007007000000000000000000000000000ff00ff00000000000000000000
007007000007000777070707700707700077700000777770077707007770707007007000777000000000000000000000000000dd00dd00000000000000000000
07000000000000000000070000070000000070000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000
07000000000000000000700000700000000700000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000
07000000000000000000700000700000000700000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000
00777777777777777777777777777777777777777777777777777777777777777777777777000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77000770777770770007700077007707707777770770077007700000000000000000000000000000000000000000000000000000000000000000000000000000
77000770777770770007700077007707707700000770077007700000000000000000000000000000000000000000000000000000000000000000000000000000
77700770700000770007700077007707707700000770077007700000000000000000000000000000000000000000000000000000000000000000000000000000
77770770777700770707700077777707707707770777777007700000000000000000000000000000000000000000000000000000000000000000000000000000
77077770700000770707700077777707707700770777777000000000000000000000000000000000000000000000000000000000000000000000000000000000
77007770777770770707700077007707707777770770077007700000000000000000000000000000000000000000000000000000000000000000000000000000
77000770777770777777700077007707707777770770077007700000000000000000000000000000000000000000000000000000000000000000000000000000
99999999999999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
94499494499449949000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
94949994949494949000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
94499494499494949000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
94949494949494999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
94499494949449949000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99999999999999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00010000250502505024050220501e0501a05014050110500e05009050090500a0500b0500c0500d0500e0500f0500f0500000000000000000000000000000000000000000000000000000000000000000000000
000100001c1501d1501e150201501f150201502015020150201501f1501e1501d1501915015150131501215011150141501c15020150231502415027150281500000000000000000000000000000000000000000
00010000323503235031350313502f3502c3502a350293502735024350213501f3501a3501835014350113500f3500c3500835004350003500a05011050180501d050230502b0503105036050380503905039050
00010000035500b550105501555002550065500c5501155015550175500155005550085500b5500f5501355017550055500a5500e5501455019550195500a6000860006600046000260000600000000000000000
00010000207501d7501a75017750137500f7500c750097500775004750007501d7501875014750107500e7500b750087500675003750007501e7501d750197501675014750117500f7500c750097500775005750
000100001b7502075024750287502a7502d7502f7503075030750307503075030750307502f7502f7502d7502a75026750217501c750157500b75002750007000f70006700017000520003200002000000000000
0001000003450074500a4500c4500d4500d4500b45009450064500345003450084500a4500c4500b4500b45009450064500045003450074500a4500d4500d4500c45007450024500545008450094500945006450
a80c1400297402b7402d7402d73529740297302972029715297402b7402d7402d7352974029730297202971500700007000070000700007000070000700007000070000700007000070000700007000070000700
a80c14002674027740297402973526740267302672026715267402774029740297352674026730267202671500000000000000000000000000000000000000000000000000000000000000000000000000000000
a80900000a04000000000000000000000000000e0400000000000000001104000000130400000011040000000a04000000000000000000000000000e040000000000000000110400000013040000001104000000
c10b0000240402403024025260401d0051d00529040290351d0050000526040260352404024035260402603522040220350000500005000050000500005000051604016030160201601500005000050000500005
c00b0000117401173500700007000c7400c7350070000700117401173500700007000c7400c73500700007000a7400a7300c7400d7400f7401174013740157401174011730117201171500700007000070000700
000200000225002250022500225002250022500225002250022500220003300302000025000250002500025000250002500025000250003000030000300002500025000250002500025000250002500025000250
__music__
04 07084344
04 0a0b4344
03 09414344

