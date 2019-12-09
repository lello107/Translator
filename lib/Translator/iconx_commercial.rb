module Translator

	class IconxCommercial

		VERTIGO_PREROLL="00:00:00:00"
		LAYOUT_COMM="comm_bug"


		attr_accessor :applyed, :playlist,:commercials

		def initialize( playlist,v12 )#PlaylistStructure
			@applyed=false
			@playlist=playlist
			@commercials=[]
			@v12=v12
 
			@template="FASCIA"
		 	@show_cmd="COMM"
		 	@layer=3
		end

		def generate_commercials()
		  
		  @playlist.select{|p| p.event_type=="COMM"}.chunk_while { |x, y| y.position == x.position + 1}.select { |a| a.size >= 1}.each do |gruppo_commercials|
		  	position=1	
			
			
		
		  	#cup=Translator::NEW_LOGO.clone
		  	cup=Translator::SVIDEO.clone
		  	cup["local_tx_time"]=VERTIGO_PREROLL
		  	cup["event_type"]="sCOM"
		  	cup["tx_duration"]="00:00:05:00"
		  	cup["position_secondary"]=position
		  	cup["position"]=gruppo_commercials[0].position
		  	cup["title"]="ProgSalvo:#{@template},#{@show_cmd},#{@layer}"	 		  	
		  	position+=1
		  	@commercials.push(PlaylistStructure.new(cup))
			
		  
		    @applyed=true
		end
	end


	end

end 