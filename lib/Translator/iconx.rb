module Translator

	class Iconx

		VERTIGO_PREROLL="00:00:02:15"
		BUG_OFF= "BUG OFF"
		BOTTOM_RIGHT= "BUG BOTTOM RIGHT"
		BOTTOM_RIGHT_BUG= "bug_dx"
		OPZIONE_LOGO_CDN_NEXT_EVENT=true

		attr_accessor :applyed, :playlist, :iconx, :plus_one, :plus_one_title, :plus_one_id

		def initialize( playlist )#PlaylistStructure
			@applyed=false
			@playlist=playlist
			@iconx=[]
			@plus_one=false
			@plus_one_id="USD2"
			@plus_one_title="LOGO"			

		end

		def generate_iconx()
		  
		  @playlist.select {|x| x.event_type.match(/PROG/)}.each do |programma|	

		  	position=1
		  	priority=100


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

		  	if(@plus_one)
		  		plus=Translator::NEW_LOGO.clone
		  		plus["event_type"]="sBUG"
		  		plus["local_tx_time"]=VERTIGO_PREROLL
		  		plus["tx_id"][0] = @plus_one_id
		  		plus["title"]=@plus_one_title
		  		plus["priority"]=0
		  		plus["position_secondary"]=position
		  		plus["position"]=programma.position

		  		position+=1
		  		@logos.push(PlaylistStructure.new(plus))
		  	end



		  	cdn=Translator::NEW_LOGO.clone
		  	cdn["position_secondary"]=(position)+100
		  	cdn["position"]=programma.position + opzione_logo_next
		  	cdn["priority"]=priority
		  	cdn["event_type"]="sBUG"
		  	cdn["title"]="FireSalvo:kill,1"
		  	cdn["local_tx_time"]=logo_cdn_time
		  	position+=1

			@iconx.push(PlaylistStructure.new(cdn))

			if(@plus_one)
		  		plus=Translator::NEW_LOGO.clone
		  		plus["event_type"]="sBUG"
		  		plus["local_tx_time"]=VERTIGO_PREROLL
		  		plus["tx_id"][0] = @plus_one_id
		  		plus["title"]=@plus_one_title
		  		plus["priority"]=0
		  		plus["position_secondary"]=position
		  		plus["position"]=programma.position
		  		
		  		position+=1
		  		@logos.push(PlaylistStructure.new(plus))
		  	end
			

			
		  end #end loop
		  @applyed=true 
		end #end generate loop


	end #end class

end #end module