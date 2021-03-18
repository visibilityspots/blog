-------------------------------------------------------------------------------
--                                                                         MAIN
function conky_main(color, theme, drawbg, unit, area_code, posfix)

	if conky_window == nil then return end

	local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)

	cr = cairo_create(cs)

	local updates=tonumber(conky_parse('${updates}'))
	if updates>5 then

	-- BACKGROUND COLOR
	if color == "white" then
		bgc = 0xffffff
		bga = 0.4
	else
		bgc = 0x1e1c1a
		bga = 0.8
	end

	local theme = ("0x" .. theme)
	local w = conky_window.width
	local h = conky_window.height
	local hori_space = w*0.06
	local vert_space = h*0.5
	local xp = hori_space
	local yp = vert_space

	-- BACKGROUND
	if drawbg == "on" then
	settings={
		x=0-1    , y=0 ,
		w=w+1    , h=h ,
		border=1 ,
		colour={{0,bgc,0.2},},
	};draw_box(settings)
	settings={
		x=0-1 , y=0 ,
		w=w+1 , h=h ,
		colour={{0.5,bgc,bga},{1,bgc,bga-0.1},},
		linear_gradient={0,0,w/2,h/2},
	};draw_box(settings)
	end

	-- APPEARANCE
	if color == "white" then
		bgc = 0x1e1c1a
		fgc = 0x1e1c1a
		bga = 0.15
		fga = 0.8
	else
		bgc = 0xffffff
		fgc = 0xffffff
		bga = 0.1
		fga = 0.8
	end
    

    --FIRST COLUMN
    settings = {--VARIA
        txt='Z',
        x=50             , y=95          ,
        txt_weight=0        , txt_size=100 ,
        txt_fg_colour=theme , txt_fg_alpha=fga ,
        font="OpenLogos"
    };display_text(settings)

    --SECOND COLUMN
    settings = {--UPTIME TITLE
        txt=conky_parse("Uptime: "),
        x=100               , y=20            ,
        txt_weight=0        , txt_size=12 ,
        txt_fg_colour=theme , txt_fg_alpha=fga    ,
    };display_text(settings)

    settings = {--UPTIME TITLE
        txt=conky_parse("${uptime}"),
        x=160               , y=20            ,
        txt_weight=1        , txt_size=12 ,
        txt_fg_colour=theme , txt_fg_alpha=fga    ,
    };display_text(settings)


    settings = {--UPDATES TITLE
        txt=conky_parse("Updates: "),
        x=100               , y=35           ,
        txt_weight=0        , txt_size=12 ,
        txt_fg_colour=fgc , txt_fg_alpha=fga    ,
    };display_text(settings)

    updates = conky_parse("${execi 360 yum -e0 -d0 check-update | wc -l}")
    if updates > '9' then
        color = theme 
        weigth = '1'
        message = 'available'
        xAs = '175'
    elseif updates > '0' then 
        color = theme
        weigth = '1'
        message = 'available'
        xAs = '180'
    else
        color = fgc
        weigth = '0'
        message = ''
        xAs = '175'
    end
    settings = {--# UPDATES
	txt=updates,
        x=160               , y=35           ,
        txt_weight=weigth        , txt_size=12 ,
        txt_fg_colour=color , txt_fg_alpha=fga    ,
    };display_text(settings)

    settings = {--UPDATES MESSAGE
        txt=message,
        x=xAs      , y=35           ,
        txt_weight=0        , txt_size=12 ,
        txt_fg_colour=fgc , txt_fg_alpha=fga    ,
    };display_text(settings)

    irssiState= conky_parse("${exec curl --user USERNAME:PASSWORD https://URLTO/status.html -k -s | head -1}")

    if irssiState == '1' then
    	color = theme
        message = ''
        state = 'Online'
    else
        color = theme
    	message = conky_parse("${exec curl --user USERNAME:PASSWORD https://URLTO/status.html -k -s | tail -1}")
        state = 'Offline '
    end

    settings = {--IRSSI TITLE
        txt='Irssi:',
        x=100             , y=51          ,
        txt_weight=0        , txt_size=12 ,
        txt_fg_colour=theme , txt_fg_alpha=fga ,
    };display_text(settings)
   
    settings = {--IRSSI STATE
        txt=state,
        x=160             , y=51          ,
        txt_weight=1        , txt_size=12 ,
        txt_fg_colour=color , txt_fg_alpha=fga ,
    };display_text(settings)

    settings = {--IRSSI MESSAGE
        txt=message,
        x=207             , y=51          ,
        txt_weight=0        , txt_size=10 ,
        txt_fg_colour=theme , txt_fg_alpha=fga ,
    };display_text(settings)

	--ICINGA STATE
    IcingaState=conky_parse("${execpi 53 ~/PATH/TO/icinga.sh | awk '{for (i=2; i<NF; i++) printf $i \" \"; print $NF}'}")
    IcingaTitle=conky_parse("${execpi 53 ~/PATH/TO/icinga.sh | awk {'print $1'}}")

    if IcingaState == 'OK' then
        color = theme
    elseif IcingaState == 'WARN' then
        color = theme
    else
        color = theme
    end

    settings = {--ICINGA TITLE
        txt='Icinga:',
        x=100             , y=65          ,
        txt_weight=0        , txt_size=12 ,
        txt_fg_colour=theme , txt_fg_alpha=fga ,
    };display_text(settings)

    settings = {--ICINGA STATE
        txt=IcingaState,
        x=160             , y=65          ,
        txt_weight=1        , txt_size=12 ,
        txt_fg_colour=color , txt_fg_alpha=fga ,
    };display_text(settings)
 
    -- MIDDLE  
    settings = {--HOUR
        txt="88:88",
        x=(w/2)-140             , y=50          ,
        txt_weight=1        , txt_size=50,
        txt_fg_colour=fgc , txt_fg_alpha=bga ,
        font = "Digital Readout Thick Upright",
    };display_text(settings)
    settings = {--HOUR
        txt=conky_parse("${time %H:}"),
        x=(w/2)-140            , y=50          ,
        txt_weight=1        , txt_size=50,
        txt_fg_colour=theme , txt_fg_alpha=fga ,
        font = "Digital Readout Thick Upright"
    };display_text(settings)
    settings = {--MINUTES
        txt=conky_parse("${time %M}"),
        x=(w/2)-84             , y=50          ,
        txt_weight=1        , txt_size=50 ,
        txt_fg_colour=theme , txt_fg_alpha=fga ,
        font = "Digital Readout Thick Upright"
    };display_text(settings)

    settings = {--MAILS
        txt=conky_parse("Mails: ${new_mails /PATH/TO/MAILDIR}"),
        x=(w/2)-160             , y=65          ,
        txt_weight=0        , txt_size=12 ,
        txt_fg_colour=fgc , txt_fg_alpha=fga ,
    };display_text(settings)

    if unit =='f' then
        unitChar = 'F°'
    else
        unitChar = 'C°'
    end

    settings = {--DATA
        txt=conky_parse("${time %d}") .. " " .. conky_parse("${time %b}") .. " " .. conky_parse("${time %Y}"),
        x=(w/2)+60               , y=20            ,
        txt_weight=1        , txt_size=12 ,
        txt_fg_colour=theme , txt_fg_alpha=fga    ,
    };display_text(settings)

    settings = {--NAME WEEK
        txt=conky_parse("${time %A}"),
        x=(w/2)+60               , y=35           ,
        txt_weight=1        , txt_size=12 ,
        txt_fg_colour=fgc , txt_fg_alpha=fga    ,
    };display_text(settings)

    settings = {--DAY TEMP
        txt="Temp: " .. get_yahoo_weather_info("cur", area_code, unit) .. unitChar,
        x=(w/2)+60               , y=50            ,
        txt_weight=1        , txt_size=12 ,
        txt_fg_colour=theme , txt_fg_alpha=fga    ,
    };display_text(settings)

    settings = {--SPOTIFY MUSIC SYMBOL
        txt=conky_parse("${if_running spotify}z${endif}"),
        x=(w/2)+60             , y=83          ,
        txt_weight=0        , txt_size=10 ,
	txt_fg_colour=theme , txt_fg_alpha=fga ,
        font="musicelements"
    };display_text(settings)

    settings = {--SPOTIFY
        txt=conky_parse("${if_running spotify}${exec spotify-nowplaying}${endif}"),
        x=(w/2)+67             , y=83          ,
        txt_weight=0        , txt_size=10 ,
        txt_fg_colour=theme , txt_fg_alpha=fga ,
    };display_text(settings)

	settings = {--DAYS GRAPH
		value=tonumber(conky_parse("${time %d}")),
		value_max=31               ,
		x=w/2                     , y=yp                        ,
		graph_radius=33            ,
		graph_thickness=5          ,
		graph_start_angle=215      ,
		graph_unit_angle=3.6       , graph_unit_thickness=2.6    ,
		graph_bg_colour=bgc        , graph_bg_alpha=bga          ,
		graph_fg_colour=theme      , graph_fg_alpha=fga          ,
		hand_fg_colour=theme       , hand_fg_alpha=0.0           ,
		txt_radius=42              ,
		txt_weight=1               , txt_size=8.0                ,
		txt_fg_colour=fgc          , txt_fg_alpha=fga            ,
		graduation_radius=28       ,
		graduation_thickness=0     , graduation_mark_thickness=1 ,
		graduation_unit_angle=27   ,
		graduation_fg_colour=theme , graduation_fg_alpha=0.4     ,
		caption=''                 ,
		caption_weight=1           , caption_size=10.0           ,
		caption_fg_colour=fgc      , caption_fg_alpha=fga        ,
	};draw_gauge_ring(settings)

	settings = {--MONTHS GRAPH
		value=tonumber(conky_parse("${time %m}")),
		value_max=12               ,
		x=w/2                     , y=yp                        ,
		graph_radius=33            ,
		graph_thickness=5          ,
		graph_start_angle=34       ,
		graph_unit_angle=9.2       , graph_unit_thickness=8.2    ,
		graph_bg_colour=bgc        , graph_bg_alpha=bga          ,
		graph_fg_colour=theme      , graph_fg_alpha=fga          ,
		hand_fg_colour=theme       , hand_fg_alpha=0.0           ,
		txt_radius=42              ,
		txt_weight=1               , txt_size=8.0                ,
		txt_fg_colour=fgc          , txt_fg_alpha=fga            ,
		graduation_radius=28       ,
		graduation_thickness=0     , graduation_mark_thickness=1 ,
		graduation_unit_angle=27   ,
		graduation_fg_colour=theme , graduation_fg_alpha=0.3     ,
		caption=''                 ,
		caption_weight=1           , caption_size=10.0           ,
		caption_fg_colour=fgc      , caption_fg_alpha=fga        ,
	};draw_gauge_ring(settings)

	settings = {--SECONDS
		value=tonumber(conky_parse("${time %S}")),
		value_max = 60    ,
		x = w/2          , y = yp          ,
		bg_colour = bgc   , bg_alpha = bga  ,
		fg_colour = theme , fg_alpha = fga  ,
		radius =25        , thickness = 10  ,
		start_angle = 0   , end_angle = 360 ,
		lr = 0            ,
	};draw_ring(settings)

	settings = {--CLOCK HANDS
		xc = w/2          ,
		yc = yp          ,
		colour = bgc     ,
		alpha = 1        ,
		show_secs = true ,
		size = 40        ,
	};clock_hands(settings)

	xp = ((w/2)/2.6) - posfix

	settings = {--CPU GRAPH CPU1
		value=tonumber(conky_parse("${cpu cpu1}")),
		value_max=100              ,
		x=xp                       , y=yp                        ,
		graph_radius=22            ,
		graph_thickness=5          ,
		graph_start_angle=180      ,
		graph_unit_angle=2.7       , graph_unit_thickness=2.7    ,
		graph_bg_colour=bgc        , graph_bg_alpha=bga          ,
		graph_fg_colour=theme      , graph_fg_alpha=fga          ,
		hand_fg_colour=theme       , hand_fg_alpha=0.0           ,
		txt_radius=35              ,
		txt_weight=1               , txt_size=8.0                ,
		txt_fg_colour=fgc          , txt_fg_alpha=fga            ,
		graduation_radius=28       ,
		graduation_thickness=0     , graduation_mark_thickness=1 ,
		graduation_unit_angle=27   ,
		graduation_fg_colour=theme , graduation_fg_alpha=0.3     ,
		caption='CPU'              ,
		caption_weight=1           , caption_size=10.0           ,
		caption_fg_colour=fgc      , caption_fg_alpha=fga        ,
	};draw_gauge_ring(settings)

	settings = {--CPU GRAPH CPU2
		value=tonumber(conky_parse("${cpu cpu2}")) ,
		value_max=100              ,
		x=xp                       , y=yp                        ,
		graph_radius=17            ,
		graph_thickness=5          ,
		graph_start_angle=180      ,
		graph_unit_angle=2.7       , graph_unit_thickness=2.7    ,
		graph_bg_colour=bgc        , graph_bg_alpha=bga          ,
		graph_fg_colour=theme      , graph_fg_alpha=fga          ,
		hand_fg_colour=theme       , hand_fg_alpha=0.0           ,
		txt_radius=9               ,
		txt_weight=1               , txt_size=8.0                ,
		txt_fg_colour=fgc          , txt_fg_alpha=fga            ,
		graduation_radius=28       ,
		graduation_thickness=0     , graduation_mark_thickness=1 ,
		graduation_unit_angle=27   ,
		graduation_fg_colour=theme , graduation_fg_alpha=0.3     ,
		caption=''                 ,
		caption_weight=1           , caption_size=10.0           ,
		caption_fg_colour=fgc      , caption_fg_alpha=fga        ,
	};draw_gauge_ring(settings)

        settings = {--CPU GRAPH CPU3
                value=tonumber(conky_parse("${cpu cpu3}")) ,
                value_max=100              ,
                x=xp                       , y=yp                        ,
                graph_radius=17            ,
                graph_thickness=5          ,
                graph_start_angle=180      ,
                graph_unit_angle=2.7       , graph_unit_thickness=2.7    ,
                graph_bg_colour=bgc        , graph_bg_alpha=bga          ,
                graph_fg_colour=theme      , graph_fg_alpha=fga          ,
                hand_fg_colour=theme       , hand_fg_alpha=0.0           ,
                txt_radius=0               ,
                txt_weight=1               , txt_size=8.0                ,
                txt_fg_colour=fgc          , txt_fg_alpha=fga            ,
                graduation_radius=28       ,
                graduation_thickness=0     , graduation_mark_thickness=1 ,
                graduation_unit_angle=27   ,
                graduation_fg_colour=theme , graduation_fg_alpha=0.3     ,
                caption=''                 ,
                caption_weight=1           , caption_size=10.0           ,
                caption_fg_colour=fgc      , caption_fg_alpha=fga        ,
        };draw_gauge_ring(settings)

        settings = {--CPU GRAPH CPU4
                value=tonumber(conky_parse("${cpu cpu4}")) ,
                value_max=100              ,
                x=xp                       , y=yp                        ,
                graph_radius=17            ,
                graph_thickness=5          ,
                graph_start_angle=180      ,
                graph_unit_angle=2.7       , graph_unit_thickness=2.7    ,
                graph_bg_colour=bgc        , graph_bg_alpha=bga          ,
                graph_fg_colour=theme      , graph_fg_alpha=fga          ,
                hand_fg_colour=theme       , hand_fg_alpha=0.0           ,
                txt_radius=-9              ,
                txt_weight=1               , txt_size=8.0                ,
                txt_fg_colour=fgc          , txt_fg_alpha=fga            ,
                graduation_radius=28       ,
                graduation_thickness=0     , graduation_mark_thickness=1 ,
                graduation_unit_angle=27   ,
                graduation_fg_colour=theme , graduation_fg_alpha=0.3     ,
                caption=''                 ,
                caption_weight=1           , caption_size=10.0           ,
                caption_fg_colour=fgc      , caption_fg_alpha=fga        ,
        };draw_gauge_ring(settings)

        settings = {--LOAD 
		txt=conky_parse("${loadavg}"),
                x=xp+10             , y=yp+38,
                txt_weight=0        , txt_size=10 ,
                txt_fg_colour=theme , txt_fg_alpha=fga ,
        };display_text(settings)

	xp = xp + hori_space
	settings = {--MEMPERC GRAPH
		value=tonumber(conky_parse("${memperc}")),
		value_max=100              ,
		x=xp                       , y=yp                        ,
		graph_radius=22            ,
		graph_thickness=5          ,
		graph_start_angle=180      ,
		graph_unit_angle=2.7       , graph_unit_thickness=2.7    ,
		graph_bg_colour=bgc        , graph_bg_alpha=bga          ,
		graph_fg_colour=theme      , graph_fg_alpha=fga          ,
		hand_fg_colour=theme       , hand_fg_alpha=0.0           ,
		txt_radius=0               ,
		txt_weight=1               , txt_size=8.0                ,
		txt_fg_colour=fgc          , txt_fg_alpha=fga            ,
		graduation_radius=22       ,
		graduation_thickness=4     , graduation_mark_thickness=2 ,
		graduation_unit_angle=27   ,
		graduation_fg_colour=theme , graduation_fg_alpha=0.5     ,
		caption='MEM'              ,
		caption_weight=1           , caption_size=10.0           ,
		caption_fg_colour=fgc      , caption_fg_alpha=fga        ,
	};draw_gauge_ring(settings)

        settings = {--FREE MEMORY 
                txt=conky_parse("${memfree} free"),
                x=xp+10             , y=yp+38,
                txt_weight=0        , txt_size=10 ,
                txt_fg_colour=theme , txt_fg_alpha=fga ,
        };display_text(settings)

        xp = xp + hori_space
	settings = {--SWAP FILESYSTEM USED GRAPH
		value=tonumber(conky_parse("${swapperc}")),
		value_max=100              ,
		x=xp                       , y=yp                        ,
		graph_radius=22            ,
		graph_thickness=5          ,
		graph_start_angle=180      ,
		graph_unit_angle=2.7       , graph_unit_thickness=2.7    ,
		graph_bg_colour=bgc        , graph_bg_alpha=bga          ,
		graph_fg_colour=theme      , graph_fg_alpha=fga          ,
		hand_fg_colour=theme       , hand_fg_alpha=0.0           ,
		txt_radius=0               ,
		txt_weight=1               , txt_size=8.0                ,
		txt_fg_colour=fgc          , txt_fg_alpha=fga            ,
		graduation_radius=22       ,
		graduation_thickness=4     , graduation_mark_thickness=2 ,
		graduation_unit_angle=27   ,
		graduation_fg_colour=theme , graduation_fg_alpha=0.5     ,
		caption='SWAP'             ,
		caption_weight=1           , caption_size=10.0           ,
		caption_fg_colour=fgc      , caption_fg_alpha=fga        ,
	};draw_gauge_ring(settings)

        settings = {--FREE SWAP 
                txt=conky_parse("${swapfree} free"),
                x=xp+10             , y=yp+38,
                txt_weight=0        , txt_size=10 ,
                txt_fg_colour=theme , txt_fg_alpha=fga ,
        };display_text(settings)
        
        xp = xp + hori_space
        settings = {--TEMP GRAPH
                value=tonumber(conky_parse("${acpitemp}")),
                value_max=100              ,
                x=xp                       , y=yp                        ,
                graph_radius=22            ,
                graph_thickness=5          ,
                graph_start_angle=180      ,
                graph_unit_angle=2.7       , graph_unit_thickness=2.7    ,
                graph_bg_colour=bgc        , graph_bg_alpha=bga          ,
                graph_fg_colour=theme      , graph_fg_alpha=fga          ,
                hand_fg_colour=theme       , hand_fg_alpha=0.0           ,
                txt_radius=0               ,
                txt_weight=1               , txt_size=8.0                ,
                txt_fg_colour=fgc          , txt_fg_alpha=fga            ,
                graduation_radius=22       ,
                graduation_thickness=4     , graduation_mark_thickness=2 ,
                graduation_unit_angle=27   ,
                graduation_fg_colour=theme , graduation_fg_alpha=0.5     ,
                caption='TEMP'              ,
                caption_weight=1           , caption_size=10.0           ,
                caption_fg_colour=fgc      , caption_fg_alpha=fga        ,
        };draw_gauge_ring(settings)

	xp = w/2 + 250
	disks = {'/', '/home'}
	disksLabel = {'ROOT', 'HOME'}
	for i, partitions in ipairs(disks) do
		settings = {--ROOT FILESYSTEM USED GRAPH
			value=tonumber(conky_parse("${fs_used_perc " .. partitions .. "}")),
			value_max=100              ,
			x=xp                       , y=yp                        ,
			graph_radius=22            ,
			graph_thickness=5          ,
			graph_start_angle=180      ,
			graph_unit_angle=2.7       , graph_unit_thickness=2.7    ,
			graph_bg_colour=bgc        , graph_bg_alpha=bga          ,
			graph_fg_colour=theme      , graph_fg_alpha=fga          ,
			hand_fg_colour=theme       , hand_fg_alpha=0.0           ,
			txt_radius=0               ,
			txt_weight=1               , txt_size=8.0                ,
			txt_fg_colour=fgc          , txt_fg_alpha=fga            ,
			graduation_radius=23       ,
			graduation_thickness=0     , graduation_mark_thickness=2 ,
			graduation_unit_angle=27   ,
			graduation_fg_colour=theme , graduation_fg_alpha=0.5     ,
			caption=disksLabel[i]      ,
			caption_weight=1           , caption_size=10.0           ,
			caption_fg_colour=fgc      , caption_fg_alpha=fga        ,
 		};draw_gauge_ring(settings)
         
                settings = {--FREE SPACE
          	       txt=conky_parse("${fs_free " ..  partitions .. "} free"),
                	x=xp+10             , y=yp+38,
	                txt_weight=0        , txt_size=10 ,
        	        txt_fg_colour=theme , txt_fg_alpha=fga ,
	        };display_text(settings)

		xp = xp + hori_space
	end

	iface = conky_parse("${exec ip n | awk {'print $3'} | head -1}")        
	if iface == 'em1' then
        	ifaceCaption = 'EM1'
        else
   		ifaceCaption = 'WLAN0'
        end

 	settings = {--NETWORK GRAPH UP
		value=tonumber(conky_parse("${upspeedf " .. iface .. "}")),
		value_max=100              ,
		x=xp                       , y=yp                        ,
		graph_radius=17            ,
		graph_thickness=5          ,
		graph_start_angle=180      ,
		graph_unit_angle=2.7       , graph_unit_thickness=2.7    ,
		graph_bg_colour=bgc        , graph_bg_alpha=bga          ,
		graph_fg_colour=theme      , graph_fg_alpha=fga          ,
		hand_fg_colour=theme       , hand_fg_alpha=0.0           ,
		txt_radius=0               ,
		txt_weight=1               , txt_size=8.0                ,
		txt_fg_colour=fgc          , txt_fg_alpha=fga            ,
		graduation_radius=28       ,
		graduation_thickness=0     , graduation_mark_thickness=1 ,
		graduation_unit_angle=27   ,
		graduation_fg_colour=theme , graduation_fg_alpha=0.3     ,
		caption=''                 ,
		caption_weight=1           , caption_size=10.0           ,
		caption_fg_colour=fgc      , caption_fg_alpha=fga        ,
	};draw_gauge_ring(settings)

        settings = {--NETWORK GRAPH DOWN
                value=tonumber(conky_parse("${downspeedf " .. iface .. "}")),
                value_max=100              ,
                x=xp                       , y=yp                        ,
                graph_radius=22            ,
                graph_thickness=5          ,
                graph_start_angle=180      ,
                graph_unit_angle=2.7       , graph_unit_thickness=2.7    ,
                graph_bg_colour=bgc        , graph_bg_alpha=bga          ,
                graph_fg_colour=theme      , graph_fg_alpha=fga          ,
                hand_fg_colour=theme       , hand_fg_alpha=0.0           ,
                txt_radius=35              ,
                txt_weight=1               , txt_size=8.0                ,
                txt_fg_colour=fgc          , txt_fg_alpha=fga            ,
                graduation_radius=28       ,
                graduation_thickness=0     , graduation_mark_thickness=1 ,
                graduation_unit_angle=27   ,
                graduation_fg_colour=theme , graduation_fg_alpha=0.3     ,
                caption=ifaceCaption              ,
                caption_weight=1           , caption_size=10.0           ,
                caption_fg_colour=fgc      , caption_fg_alpha=fga        ,
        };draw_gauge_ring(settings)

        if iface =='em1' then
	        ip = conky_parse("${addr em1}")
	        if ip == 'IP.WORK.LOCATION.ONE' then
        	   conky_parse("${exec setsmtp -b}")
                   todo='work'
		elseif ip == 'IP.WORK.LOCATION.TWO' then
                   todo='work'
	        else
        	   conky_parse("${exec setsmtp -t}")
                   todo='personal'
        	end

	        settings = {--IP ADDRESS
        	        txt=ip,
                	x=xp+10             , y=83,
	                txt_weight=0        , txt_size=10 ,
	                txt_fg_colour=theme , txt_fg_alpha=fga ,
	        };display_text(settings)

        elseif iface == 'wlan0' then

	        ssid = conky_parse("${wireless_essid wlan0}")
        	if ssid == 'SSID.WORK.LOCATION.ONE' then
	           conky_parse("${exec setsmtp -b}")
                   todo='work'
        	elseif ssid == 'SSID HOME' then
	           conky_parse("${exec shares -a}")
	           conky_parse("${exec setsmtp -t}")
                   todo='personal'
	        else
	           conky_parse("${exec setsmtp -t}")
                   todo='personal'
	        end
	
	        settings = {--WIRELESS INFO
        	        txt=conky_parse("${wireless_link_qual wlan0} %"),
	                x=xp+10             , y=83,
	                txt_weight=1        , txt_size=10 ,
	                txt_fg_colour=theme , txt_fg_alpha=fga ,
	        };display_text(settings)

	else
		iface=''
        end
 
	xp = xp + hori_space

        settings = {--BATTERY GRAPH
                value=tonumber(conky_parse("${battery_percent}")),
                value_max=100              ,
                x=xp                       , y=yp                        ,
                graph_radius=22            ,
                graph_thickness=5          ,
                graph_start_angle=180      ,
                graph_unit_angle=2.7       , graph_unit_thickness=2.7    ,
                graph_bg_colour=bgc        , graph_bg_alpha=bga          ,
                graph_fg_colour=theme      , graph_fg_alpha=fga          ,
                hand_fg_colour=theme       , hand_fg_alpha=0.0           ,
                txt_radius=0               ,
                txt_weight=1               , txt_size=8.0                ,
                txt_fg_colour=fgc          , txt_fg_alpha=fga            ,
                graduation_radius=22       ,
                graduation_thickness=4     , graduation_mark_thickness=2 ,
                graduation_unit_angle=27   ,
                graduation_fg_colour=theme , graduation_fg_alpha=0.5     ,
                caption='BATTERY'              ,
                caption_weight=1           , caption_size=10.0           ,
                caption_fg_colour=fgc      , caption_fg_alpha=fga        ,
        };draw_gauge_ring(settings)

        settings = {--BATTERY CHARGING STATE
		txt=conky_parse("${acpiacadapter} ${battery_time}"),
		x=xp-25             , y=83,
        	txt_weight=0        , txt_size=10 ,
	        txt_fg_colour=theme , txt_fg_alpha=fga ,
        };display_text(settings)

        -- TODO COLUMN
	conky_parse("${execpi 53 ~/.conky/scripts/tracks-" .. todo .. ".sh}")
        arrayYfactors={'20', '35', '51', '65'}

	for i, Yfactor in ipairs(arrayYfactors) do
	        firstchar=conky_parse("${exec head -" .. i .. " ~/.conky/scripts/todo-" .. todo .. ".bak | tail -1 | sed -r 's/^  //' | cut -d ' ' -f 1}")
                if firstchar == '*' then
                        tmpweight='0'
                        tmpcolour=fgc
                elseif firstchar == '-' then
			tmpweight='0'
			tmpcolour=fgc
		else
                        tmpweight='1'
                        tmpcolour=theme
                end

		settings = { --TODO column
			txt=conky_parse("${exec head -" .. i .. " ~/.conky/scripts/todo-" .. todo .. ".bak | tail -1 | sed -r 's/^  //' | cut -d '(' -f 1}"),
	                x=xp+80             , y=Yfactor,
 	                txt_weight=tmpweight        , txt_size=12,
                        txt_fg_colour=tmpcolour , txt_fg_alpha=fga ,
        	};display_text(settings)
	end
       settings = { --JENKINS TITLE 
                txt=conky_parse("${exec ~/PATH/TO/hudson/conkyhudson.py -t ~/PATH/TO/hudson/" .. todo .. ".template | cut -d '|' -f 1 | head -1}"),
                x=xp+80             , y=80,
                txt_weight=1       , txt_size=9,
                txt_fg_colour=theme , txt_fg_alpha=fga ,
        };display_text(settings)

        settings = { --JENKINS line 
                txt=conky_parse("${exec ~/PATH/TO/hudson/conkyhudson.py -t ~/PATH/TO/hudson/" .. todo .. ".template | cut -d '|' -f 2 | sed 's/_/ /' | head -1}"),
                x=xp+178             , y=80,
                txt_weight=0        , txt_size=10,
                txt_fg_colour=fgc , txt_fg_alpha=fga ,
        };display_text(settings)


	end-- if updates>5
	cairo_destroy(cr)
	cairo_surface_destroy(cs)
	cr=nil
end-- end main function
