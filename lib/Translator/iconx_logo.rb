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
					  :opzione_logo_cdn_next_event, :vertigo_preroll_out,
					  :plus_one, :plus_one_title, :plus_one_id, :iconx_id, :plus_one_preroll, :plus_one_preroll_out

		def initialize( playlist )#PlaylistStructure
			@applyed=false
			@playlist=playlist
			@iconxlogos=[]

			@iconx_id = "ICONX"

			@vertigo_preroll="00:00:00:00"
			@vertigo_preroll_out="00:00:00:00"
			@opzione_one_command=false
			@opzione_cdn_sdata=false
			@opzione_logo_cdn_next_event=false

			@plus_one=false
			@plus_one_id="LGK1P"
			@plus_one_title="UP&DOWN"	
			@plus_one_up="CUP:0"
			@plus_one_down="CDN:0"	
			@plus_one_preroll="00:00:00:00"
			@plus_one_preroll_out="00:00:00:00"				
		end

		def deep_copy(o)
		  Marshal.load(Marshal.dump(o))
		end

		def generate_iconx_logos()
		  all = @playlist.select {|x| x.event_type.match(/PROG/)}
		  counter = 0
		  #@playlist.select {|x| x.event_type.match(/PROG/)}.each do |programma|	
		  all.each do |programma| 
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
		  	
		  	if(opzione_cdn_sdata)
		  		puts "tx_id in cup: #{programma.tx_id[0].to_s}"



		  		cup=Translator::NEW_LOGO.clone
		  		cup["event_type"]="sBUG"
		  		cup["tx_id"][0] = @iconx_id
		  		cup["local_tx_time"]=@vertigo_preroll
		  		cup["title"]="FireSalvo:show,1"
		  		cup["priority"]=0
		  		cup["position_secondary"]=position
		  		cup["tx_duration"]="00:00:03:00"
		  		cup["position"]=programma.position
		  		position+=1	

			  	if(@plus_one)
			  		plus = deep_copy(Translator::NEW_LOGO.clone)
			  		plus["event_type"]="sBUG"
			  		plus["local_tx_time"]=@plus_one_preroll
			  		plus["tx_id"][0] = @plus_one_id
			  		plus["title"]= @plus_one_title == "" ? @plus_one_up : @plus_one_title
			  		plus["priority"]=0
			  		plus["tx_duration"]="00:00:02:00"
			  		plus["position_secondary"]=position
			  		plus["position"]=programma.position

			  		position+=1
			  		@iconxlogos.push(PlaylistStructure.new(plus))
			  	end


		  	else

		  		cup=Translator::SVIDEO.clone
		  		cup["event_type"]="sBUG"
		  		cup["local_tx_time"]=@vertigo_preroll
		  		cup["title"]="ProgSalvo:BUG,START,1"
		  		cup["priority"]=0
		  		cup["position_secondary"]=position
		  		cup["tx_duration"]="00:00:03:00"
		  		cup["position"]=programma.position
		  		position+=1
		  	end

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
			  	cdn["tx_id"][0] = @iconx_id
			  	cdn["position"]=programma.position + opzione_logo_next
			  	cdn["priority"]=priority
			  	cdn["tx_duration"]="00:00:03:00"
			  	cdn["event_type"]="sBUG"
			  	cdn["title"]="FireSalvo:hide,1"
			  	cdn["local_tx_time"]=Timecode.diff_timecode(logo_cdn_time, @vertigo_preroll_out)
			  	position+=1		


			  	if(@plus_one)
			  		plus = deep_copy(Translator::NEW_LOGO.clone)
			  		plus["event_type"]="sBUG"
			  		plus["local_tx_time"]=Timecode.diff_timecode(logo_cdn_time, @plus_one_preroll_out)
			  		plus["tx_id"][0] = @plus_one_id
			  		plus["title"]= @plus_one_title == "" ? @plus_one_down : @plus_one_title
			  		plus["priority"]=priority
			  		plus["position_secondary"]=(position)+101
			  		plus["position"]=programma.position + opzione_logo_next

			  		position+=1
			  		@iconxlogos.push(PlaylistStructure.new(plus))
			  	end

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


		  	#puts "counter: #{counter} all.size: #{all.size}"
		  	#byebug if (programma.tx_id[0] == "SV10041" or programma.tx_id[0] == "SV39687")
		  	if(counter <= all.size-1)
		  		#byebug if (programma.tx_id[0] == "SV10041")
			  	unless(playlist[programma.position+1].event_type.match(/PROG/))
			  		#byebug if (programma.tx_id[0] == "SV10041" or programma.tx_id[0] == "SV39687")
					@iconxlogos.push(PlaylistStructure.new(cdn))
				end
			end
			counter+=1
			
			
		  end #end loop
		  @applyed=true 
		end #end generate loop



	end

end 