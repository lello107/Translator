module Translator

	class Iconx

		VERTIGO_PREROLL="00:00:02:15"
		BUG_OFF= "BUG OFF"
		BOTTOM_RIGHT= "BUG BOTTOM RIGHT"
		BOTTOM_RIGHT_BUG= "bug_dx"
		OPZIONE_LOGO_CDN_NEXT_EVENT=true

		attr_accessor :applyed, :playlist, :iconx

		def initialize( playlist )#PlaylistStructure
			@applyed=false
			@playlist=playlist
			@iconx=[]
			

		end

		def generate_iconx()
		  
		  @playlist.select {|x| x.event_type.match(/PROG/)}.each do |programma|	

		  	position=1
		  	priority=100

		  	#byebug

		  	if programma.title_2 == BUG_OFF
		  		next
		  	end

		  	if programma.title_2 == BOTTOM_RIGHT
		  		load=Translator::NEW_LOGO.clone
		  		load["event_type"]="sBUG"
		  		load["local_tx_time"]=VERTIGO_PREROLL
		  		load["title"]="LoadLayout:LOGO_XD,"
		  		load["position_secondary"]=1
		  		load["position"]=programma.position-1
		  		 
		  		@iconx.push(PlaylistStructure.new(load))
		  	end

		  	logo_cdn_on_next=OPZIONE_LOGO_CDN_NEXT_EVENT 
		  	logo_cdn_time=Timecode.add_timecode(programma.tx_duration,VERTIGO_PREROLL)
		  	opzione_logo_next=0
		  	if(logo_cdn_on_next and programma != @playlist.last)
		  		opzione_logo_next=1
		  		logo_cdn_time=VERTIGO_PREROLL
		  		priority=0
		  	end
	
		  	
		  	cup=Translator::NEW_LOGO.clone
		  	cup["event_type"]="sBUG"
		  	cup["local_tx_time"]=VERTIGO_PREROLL
		  	cup["title"]="FireSalvo:show,1"
		  	cup["priority"]=0
		  	cup["position_secondary"]=position
		  	cup["position"]=programma.position
		  	position+=1

		  	@iconx.push(PlaylistStructure.new(cup))

		  	cdn=Translator::NEW_LOGO.clone
		  	cdn["position_secondary"]=(position)+100
		  	cdn["position"]=programma.position + opzione_logo_next
		  	cdn["priority"]=priority
		  	cdn["event_type"]="sBUG"
		  	cdn["title"]="FireSalvo:kill,1"
		  	cdn["local_tx_time"]=logo_cdn_time
		  	position+=1

			@iconx.push(PlaylistStructure.new(cdn))


			
		  end #end loop
		  @applyed=true 
		end #end generate loop


	end #end class

end #end module