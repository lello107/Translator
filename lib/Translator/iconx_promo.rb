module Translator

	class IconxPromo

		VERTIGO_PREROLL="00:00:00:00"
		LAYOUT_PROMO="promo_bug"
	 

		attr_accessor :applyed, :playlist,:promos, :template, :show_cmd

		def initialize( playlist)#PlaylistStructure
			@applyed=false
			@playlist=playlist
			@promos=[]
			#options
			#
			@template="FASCIA"
		 	@show_cmd="PROMO"
		 	@layer=3

		end

		def generate_promos()
		  #byebug
		  @playlist.select{|p| p.event_type=="PRES"}.chunk_while { |x, y| y.position == x.position + 1}.select { |a| a.size >= 1}.each do |gruppo_promo|
		  	position=1	


		  			
#			load=Translator::NEW_LOGO.clone
#		  	load["local_tx_time"]=VERTIGO_PREROLL
#		  	load["event_type"]="sPRO"
#		  	load["position_secondary"]=position
#		  	load["position"]=(gruppo_promo[0].position) -1
#		  	load["title"]="LoadLayout:#{LAYOUT_PROMO},#{LAYER_PROMO}"
# 
#		  	position+=1
#
#		  	@promos.push(PlaylistStructure.new(load))  	
		  	
		  	#cup=Translator::NEW_LOGO.clone
		  	cup=Translator::SVIDEO.clone
		  	cup["local_tx_time"]=VERTIGO_PREROLL
		  	cup["event_type"]="sPRO"
		  	cup["tx_duration"]="00:00:05:00"
		  	cup["position_secondary"]=position
		  	cup["position"]=gruppo_promo[0].position
		  	cup["title"]="ProgSalvo:#{@template},#{@show_cmd},#{@layer}"
  	
		  	position+=1

		  	@promos.push(PlaylistStructure.new(cup))

#		  	cdn=Translator::NEW_LOGO.clone
#		  	cdn["position_secondary"]=position
#		  	cdn["position"]=gruppo_promo[0].position
#			cdn["title"]="FireSalvo:#{HIDE_CMD},#{LAYER_PROMO}"		  	
#		  	cdn["event_type"]="sPRO"
#		  	cdn["local_tx_time"]=Timecode.add_timecode("00:00:05:00",VERTIGO_PREROLL)
#		  	position+=1
#
#			@promos.push(PlaylistStructure.new(cdn))
			
		  end

		  @applyed=true

		end


	end

end 