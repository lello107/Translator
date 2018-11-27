module Translator

	class IconxLogo

	
		#VERTIGO_PREROLL="00:00:00:00"
		BUG_OFF= "BUG OFF"
		BOTTOM_RIGHT= "BUG BOTTOM RIGHT"
		BOTTOM_RIGHT_BUG= "bug_dx"
		#OPZIONE_LOGO_CDN_NEXT_EVENT=false
		#OPZIONE_ONE_COMMAND=false
		#OPZIONE_CDN_SDATA = false

		attr_accessor :applyed, :playlist,
					  :iconxlogos, :vertigo_preroll, 
					  :opzione_one_command, :opzione_cdn_sdata,
					  :opzione_logo_cdn_next_event, :vertigo_preroll_out

		def initialize( playlist )#PlaylistStructure
			@applyed=false
			@playlist=playlist
			@iconxlogos=[]

			@vertigo_preroll="00:00:00:00"
			@vertigo_preroll_out="00:00:00:00"
			@opzione_one_command=false
			@opzione_cdn_sdata=false
			@opzione_logo_cdn_next_event=false
		end

		def generate_iconx_logos()
		  
		  @playlist.select {|x| x.event_type.match(/PROG/)}.each do |programma|	

		  	position=1
		  	priority=100


		  	if programma.title_2 == BUG_OFF
		  		next
		  	end





		  	if(@opzione_one_command)
		  		tx_duration=Timecode.add_timecode(programma.tx_duration,@vertigo_preroll)
			  	cup=Translator::SVIDEO.clone
			  	cup["event_type"]="sBUG"
			  	cup["local_tx_time"]=@vertigo_preroll
			  	cup["title"]="ProgSalvo:BUG,START,1"
			  	cup["priority"]=0
			  	cup["position_secondary"]=position
			  	cup["tx_duration"]=tx_duration
			  	cup["position"]=programma.position
			  	position+=1

			  	if(programma.position==0)
			  		@iconxlogos.push(PlaylistStructure.new(cup))
			  	else
				  	unless(playlist[programma.position-1].event_type.match(/PROG/))
				  		@iconxlogos.push(PlaylistStructure.new(cup))
				  	end
				end	
				
				next	  		
		  	end




		  	logo_cdn_on_next=@opzione_logo_cdn_next_event 
		  	logo_cdn_time=Timecode.add_timecode(programma.tx_duration,@vertigo_preroll)
		  	opzione_logo_next=0
		  	if(logo_cdn_on_next and programma != @playlist.last)
		  		opzione_logo_next=1
		  		logo_cdn_time=@vertigo_preroll
		  		priority=0
		  	end
		  	

		  	cup=Translator::SVIDEO.clone
		  	cup["event_type"]="sBUG"
		  	cup["local_tx_time"]=@vertigo_preroll
		  	cup["title"]="ProgSalvo:BUG,START,1"
		  	cup["priority"]=0
		  	cup["position_secondary"]=position
		  	cup["tx_duration"]="00:00:03:00"
		  	cup["position"]=programma.position
		  	position+=1

		  	if(programma.position==0)
		  		@iconxlogos.push(PlaylistStructure.new(cup))
		  	else
			  	unless(playlist[programma.position-1].event_type.match(/PROG/))
			  		@iconxlogos.push(PlaylistStructure.new(cup))
			  	end
			end
		  	#
		  	#byebug
		  	if(opzione_cdn_sdata)
		  		
			  	cdn=Translator::NEW_LOGO.clone
			  	cdn["position_secondary"]=(position)+100
			  	cdn["position"]=programma.position + opzione_logo_next
			  	cdn["priority"]=priority
			  	cdn["tx_duration"]="00:00:03:00"
			  	cdn["event_type"]="sBUG"
			  	cdn["title"]="FireSalvo:hide,1"
			  	cdn["local_tx_time"]=Timecode.diff_timecode(logo_cdn_time, @vertigo_preroll_out)
			  	position+=1		  		
		  	else

			  	cdn=Translator::SVIDEO.clone
			  	cdn["position_secondary"]=(position)+100
			  	cdn["position"]=programma.position + opzione_logo_next
			  	cdn["priority"]=priority
			  	cdn["tx_duration"]="00:00:00:00"
			  	cdn["event_type"]="sBUG"
			  	cdn["title"]="ProgSalvo:BUG,STOP,1"
			  	cdn["local_tx_time"]=Timecode.diff_timecode(logo_cdn_time, @vertigo_preroll_out)
			  	position+=1
		  	end

		  	unless(playlist[programma.position+1].event_type.match(/PROG/))
				@iconxlogos.push(PlaylistStructure.new(cdn))
			end

			#byebug
			
		  end #end loop
		  @applyed=true 
		end #end generate loop



	end

end 