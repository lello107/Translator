module Translator

	class Commercial

		VERTIGO_PREROLL="00:00:00:00"
		LAYOUT_COMM="COMM"
		LAYER_COMM=2
		HIDE_CMD="hide"
		SHOW_CMD="show"

		attr_accessor :applyed, :playlist,:commercials

		def initialize( playlist,v12 )#PlaylistStructure
			@applyed=false
			@playlist=playlist
			@commercials=[]
			@v12=v12

		end

		def generate_commercials()
		  
		  @playlist.select{|p| p.event_type=="COMM"}.chunk_while { |x, y| y.position == x.position + 1}.select { |a| a.size >= 1}.each do |gruppo_commercials|
		  	position=1	
		  	evento_da_contrassegnare=0
			
			
			puts "COMMERCIAL --- Iizio ---"
			conta_eventi_per_blocco=0
			gruppo_commercials.each do |comm|
				puts "##{conta_eventi_per_blocco} #{comm.title} #{comm.schedule_event_type}"
				if(comm.schedule_event_type == "FRAME_SPOT_IT" || comm.schedule_event_type == "BILLBOARD_IT")
					## vedi import_lst.rb row: 205 per dettagli
					#
					evento_da_contrassegnare=conta_eventi_per_blocco
					break		
				end
				conta_eventi_per_blocco+=1
			end
			puts "COMMERCIAL --- Fine --- evento da contrassegnare:#{evento_da_contrassegnare}"


			load=Translator::NEW_LOGO.clone
		  	load["local_tx_time"]=VERTIGO_PREROLL
		  	load["event_type"]="sCOM"
		  	load["position_secondary"]=1
		  	load["position"]=gruppo_commercials[evento_da_contrassegnare].position-1
		  	#load["title"]="LOADI:3 commercial_bug"
		  	if(@v12)
		  		load["title"]="LoadLayout:#{LAYOUT_COMM},#{LAYER_COMM}"
		  	else
		  		load["title"]="LOADI:#{LAYER_COMM} #{LAYOUT_COMM}"
		  	end		  	
		  	@commercials.push(PlaylistStructure.new(load))  	

		  	cup=Translator::NEW_LOGO.clone
		  	cup["local_tx_time"]=VERTIGO_PREROLL
		  	cup["event_type"]="sCOM"
		  	cup["position_secondary"]=position
		  	cup["position"]=gruppo_commercials[evento_da_contrassegnare].position
		  	#cup["title"]="CUP:3"
		  	if(@v12)
		  		cup["title"]="FireSalvo:#{SHOW_CMD},#{LAYER_COMM}"
		  	else
		  		cup["title"]="CUP:#{LAYER_COMM}"
		  	end		 		  	
		  	position+=1
		  	@commercials.push(PlaylistStructure.new(cup))

		  	cdn=Translator::NEW_LOGO.clone
		  	cdn["position_secondary"]=position
		  	cdn["position"]=gruppo_commercials[evento_da_contrassegnare].position
		  	cdn["event_type"]="sCOM"
		  	#cdn["title"]="CDN:3"
		  	if(@v12)
		  		cdn["title"]="FireSalvo:#{HIDE_CMD},#{LAYER_COMM}"
		  	else
		  		cdn["title"]="CDN:#{LAYER_COMM}"
		  	end			  	
		  	cdn["local_tx_time"]=Timecode.add_timecode("00:00:05:00",VERTIGO_PREROLL)
		  	position+=1
			@commercials.push(PlaylistStructure.new(cdn))


			
		  end
		  @applyed=true
		end


	end

end 