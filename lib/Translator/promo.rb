module Translator

	class Promo

		VERTIGO_PREROLL="00:00:00:00"
		LAYOUT_PROMO="promo_bug"
		LAYER_PROMO=3
		HIDE_CMD="hide"
		SHOW_CMD="show"

		attr_accessor :applyed, :playlist,:promos

		def initialize( playlist, v12 )#PlaylistStructure
			@applyed=false
			@playlist=playlist
			@promos=[]
			@v12 = v12

		end

		def generate_promos()
		  #byebug
		  @playlist.select{|p| p.event_type=="PRES"}.chunk_while { |x, y| y.position == x.position + 1}.select { |a| a.size >= 1}.each do |gruppo_promo|
		  	position=1	


		  	
			
			load=Translator::NEW_LOGO.clone
		  	load["local_tx_time"]=VERTIGO_PREROLL
		  	load["event_type"]="sPRO"
		  	load["position_secondary"]=position
		  	load["position"]=(gruppo_promo[0].position) -1
		  	if(@v12)
		  		load["title"]="LoadLayout:#{LAYOUT_PROMO},#{LAYER_PROMO}"
		  	else
		  		load["title"]="LOADI:#{LAYER_PROMO} #{LAYOUT_PROMO}"
		  	end
		  	position+=1

		  	@promos.push(PlaylistStructure.new(load))  	
		  	
		  	cup=Translator::NEW_LOGO.clone
		  	cup["local_tx_time"]=VERTIGO_PREROLL
		  	cup["event_type"]="sPRO"
		  	cup["position_secondary"]=position
		  	cup["position"]=gruppo_promo[0].position
		  	
		  	if(@v12)
		  		cup["title"]="FireSalvo:#{SHOW_CMD},#{LAYER_PROMO}"
		  	else
		  		cup["title"]="CUP:#{LAYER_PROMO}"
		  	end		  	
		  	position+=1

		  	@promos.push(PlaylistStructure.new(cup))

		  	cdn=Translator::NEW_LOGO.clone
		  	cdn["position_secondary"]=position
		  	cdn["position"]=gruppo_promo[0].position
		  	
		  	if(@v12)
		  		cdn["title"]="FireSalvo:#{HIDE_CMD},#{LAYER_PROMO}"
		  	else
		  		cdn["title"]="CDN:3"
		  	end			  	
		  	cdn["event_type"]="sPRO"
		  	cdn["local_tx_time"]=Timecode.add_timecode("00:00:05:00",VERTIGO_PREROLL)
		  	position+=1

			@promos.push(PlaylistStructure.new(cdn))
			
		  end

		  @applyed=true

		end


	end

end 