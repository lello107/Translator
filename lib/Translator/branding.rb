module Translator

	class Branding


		ANTICIPO_LOGOS="00:00:01:00"
		#VERTIGO_PREROLL="00:00:02:15"
		HIDE_CMD="hide"
		SHOW_CMD="show"

		attr_accessor :applyed, :playlist,:brandings,:iconx,:branding_online, :v12,
					  :vertigo_preroll, :vertigo_preroll_out

		def initialize( playlist, v12,local_branding )#PlaylistStructure
			@applyed=false
			@playlist=playlist
			@brandings=[]
			@v12 = v12
			@local_branding = local_branding

			@vertigo_preroll="00:00:00:00"
			@vertigo_preroll_out="00:00:00:00"
 

			unless(@local_branding)
				@branding_online = Translator::BrandingOnline.new() 
				@branding_online.base_uri ="192.168.57.153:3000"
			else

			end


		end

		def generate_brandings()
			@playlist.select {|x| x.event_type.match(/PROG/)}.each do |programma|	
				unless (@local_branding)
					effetti = @branding_online.effetti(programma.recon_uid)
				else
					effetti = WorkPlaylistEffect.where(recon_uid: programma.recon_uid).where(active: true).order(:tx_time)
				end
				## 	
				#
				position=1
			 	load_template=""
				global_template_layer=[]
				effetti.each do |effetto|

					load_position=1
					load_tx_time=@vertigo_preroll
					load_position_priority=1
					load_same_template=false

					unless (@local_branding)
						gestione_logo 	= effetto["effect"]["effect_type"]["logo"]
						layer			= effetto["effect"]["effect_type"]["layer"]
						tipo_effetto	= effetto["effect"]["effect_type"]["name"]
						template		= effetto["effect"]["name"]
						durata			= effetto["real_tx_duration"]
						tx_time			= effetto["tx_time"]
						preroll_in		= effetto["effect"]["preroll_in"]
						preroll_out		= effetto["effect"]["preroll_out"]						
					else
						gestione_logo 	= effetto.effect.effect_type.logo
						layer			= effetto.effect.effect_type.layer
						tipo_effetto	= effetto.effect.effect_type.name
						template		= effetto.effect.template
						durata			= effetto.real_tx_duration
						tx_time			= effetto.tx_time
						preroll_in		= effetto.effect.preroll_in
						preroll_out		= effetto.effect.preroll_out						
					end

									
					if(global_template_layer.include?("#{layer}"))
						load_position=0
						load_tx_time=Timecode.diff_timecode(tx_time,"00:00:02:00")
						load_position_priority=position
						position+=1
						if(load_template=="#{template}")
							load_same_template=true
						else
							load_same_template=false
						end
					end
					global_template_layer.push("#{layer}")
					load_template=template
					 


					#override bug control if program is bug_of
					if(programma.title_2 == Translator::Logo::BUG_OFF)
				  		gestione_logo = false
				  	end



				   if(load_same_template==false)
				  		#load template on prev event
				  		load=Translator::NEW_LOGO.clone
			  			load["event_type"]="sBRA"
			  			load["local_tx_time"]=load_tx_time
			  			if(@v12 == true)
			  				load["title"]="LoadLayout:#{template},#{layer}"
			  			else
			  				load["title"]="LOADI:#{layer} #{template}"
			  			end
		  				load["position_secondary"]=load_position_priority
		  				load["position"]=(programma.position) - load_position
			  			@brandings.push(PlaylistStructure.new(load))
			  		end

			


					#NOTA
					nota=Translator::NEW_LOGO.clone
				  	nota["event_type"]="sBRA"
				  	nota["local_tx_time"]=tx_time
				  	nota["title"]="- #{tipo_effetto} -"
		  			nota["position_secondary"]=position
		  			nota["position"]=programma.position
		  			nota["tipo"]=224
		  			position+=1 
		  			#cup_template["priority"]=2
		  			@brandings.push(PlaylistStructure.new(nota))

			  		#cut down bug
				  	cdn=Translator::NEW_LOGO.clone
		  			cdn["position_secondary"]=position
		  			cdn["position"]=programma.position
				  	cdn["event_type"]="sBUG"
				  	#cdn["tx_duration"]="00:00:02:00"
				  	if(@v12 == true)
				  		cdn["title"]="FireSalvo:#{HIDE_CMD},1"
				  	else
				  		cdn["title"]="CDN:1"
				  	end
				  	tmp_time_in = Timecode.add_timecode(tx_time,durata)
				  	cdn["local_tx_time"]= Timecode.add_timecode(tmp_time_in, @vertigo_preroll)
				  	position+=1 if gestione_logo
					@brandings.push(PlaylistStructure.new(cdn)) if gestione_logo




				    if(tipo_effetto=="ENDCREDITS")
						#cup template effect
						cup_template_load=Translator::NEW_LOGO.clone
					  	cup_template_load["event_type"]="sBRA"
					  	cup_time_in_load = Timecode.add_timecode(tx_time,@vertigo_preroll)
					  	cup_template_load["local_tx_time"]=Timecode.diff_timecode(cup_time_in_load, "00:00:03:00")		  	
					  	cup_template_load["title"]="FireSalvo:carica,#{layer}"	  	
			  			cup_template_load["position_secondary"]=position
			  			cup_template_load["position"]=programma.position
			  			cup_template_load["priority"]=2
					  	position+=1
					  	@brandings.push(PlaylistStructure.new(cup_template_load))
				    end


					#cup template effect
					cup_template=Translator::NEW_LOGO.clone
				  	cup_template["event_type"]="sBRA"
				  	cup_time_in = Timecode.add_timecode(tx_time,@vertigo_preroll)
				  	cup_template["local_tx_time"]=Timecode.add_timecode(cup_time_in, preroll_in)
				  	
				  	if(@v12 == true)
				  		cup_template["title"]="FireSalvo:#{SHOW_CMD},#{layer}"
				  	else
				  		cup_template["title"]="CUP:#{layer}"
				  	end				  	
		  			cup_template["position_secondary"]=position
		  			cup_template["position"]=programma.position
		  			cup_template["priority"]=2

				  	position+=1
				  	@brandings.push(PlaylistStructure.new(cup_template))


					#cut down template effect
					cdn_template=Translator::NEW_LOGO.clone
				  	cdn_template["event_type"]="sBRA"
				  	tmp_time_out=Timecode.add_timecode(cup_time_in, durata)
				  	tmp_time=Timecode.diff_timecode(tmp_time_out,preroll_out)
				  	cdn_template["local_tx_time"]=tmp_time
				  	if(@v12 == true)
				  		cdn_template["title"]="FireSalvo:#{HIDE_CMD},#{layer}"
				  	else
				  		cdn_template["title"]="CDN:#{layer}"
				  	end
				  	
		  			cdn_template["position_secondary"]=position
		  			cdn_template["position"]=programma.position
		  			cdn_template["priority"]=3
				  	position+=1
				  	@brandings.push(PlaylistStructure.new(cdn_template))

				  	#cut up bug after template
				  	cup=Translator::NEW_LOGO.clone
				  	cup["event_type"]="sBUG"
				  	cup["local_tx_time"]=Timecode.add_timecode(Timecode.add_timecode(tx_time,@vertigo_preroll),Timecode.add_timecode(durata,ANTICIPO_LOGOS))
				  	if(@v12 == true)
				  		cup["title"]="FireSalvo:#{SHOW_CMD},1"
				  	else
				  		cup["title"]="CUP:1"
				  	end
		  			cup["position_secondary"]=position
		  			cup["position"]=programma.position
		  			cup["priority"]=4
				  	position+=1 if gestione_logo
				  	@brandings.push(PlaylistStructure.new(cup)) if gestione_logo
				end #end effects loop
			end #end program loop
				@applyed=true

		  			

		end #end def

	end #end class


end #end module