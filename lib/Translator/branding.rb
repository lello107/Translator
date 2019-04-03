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

			@vertigo_preroll="00:00:02:15"
			@vertigo_preroll_out="00:00:00:00"
 

			unless(@local_branding)
				@branding_online = Translator::BrandingOnline.new() 
				@branding_online.base_uri ="192.168.167.145:3000"
			else

			end


		end

		def deep_copy(o)
		  Marshal.load(Marshal.dump(o))
		end

		def generate_brandings()
			@playlist.select {|x| x.event_type.match(/PROG/)}.each do |programma|	
				unless (@local_branding)
					#byebug
					effetti = @branding_online.effetti(programma.recon_uid)
				else
					#byebug
					effetti = WorkPlaylistEffect.where(recon_uid: programma.recon_uid).where(active: true).order(:tx_time)
				end
				## 	
				##
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
						tipo_effetto_sh	= effetto["effect"]["effect_type"]["short_name"]
						template		= effetto["effect"]["name"]
						durata			= effetto["real_tx_duration"]
						tx_time			= effetto["tx_time"]
						preroll_in		= effetto["effect"]["preroll_in"]
						preroll_out		= effetto["effect"]["preroll_out"]	
						fulltime		= effetto["effect"]["fulltime"]
						#prendo i dynamics da effetto quindi da quello applicato 
						#e non da effetto.effect cioè il default
						dynamic			= effetto["dynamics"].size > 0 ? true : false	
						if(dynamic)
							dynamics = []
							effetto["dynamics"].each do |dyn|
								dynamics.push(OpenStruct.new(dyn))
							end	
						end

					else
						gestione_logo 	= effetto.effect.effect_type.logo
						layer			= effetto.effect.effect_type.layer
						tipo_effetto	= effetto.effect.effect_type.name
						tipo_effetto_sh	= effetto.effect.effect_type.short_name
						template		= effetto.effect.template
						durata			= effetto.real_tx_duration
						tx_time			= effetto.tx_time
						preroll_in		= effetto.effect.preroll_in
						preroll_out		= effetto.effect.preroll_out
						fulltime		= effetto.effect.fulltime
						#prendo i dynamics da effetto quindi da quello applicato 
						#e non da effetto.effect cioè il default
						dynamic			= effetto.dynamics.present?	
						dynamics		= effetto.dynamics					
					end

									
					if(global_template_layer.include?("#{layer}"))
						load_position=0
						load_tx_time = Timecode.diff_timecode(tx_time, preroll_in) if(Timecode.convert_to_frames(tx_time)>0)
						load_tx_time=Timecode.diff_timecode(tx_time,"00:00:02:00")
						load_position_priority=position
						position+=1
						if(load_template=="#{template}")
							load_same_template=true
						else
							load_same_template=false
						end
					else
						load_tx_time  = "00:00:00:00"
					end
					global_template_layer.push("#{layer}")
					load_template=template
					 


					#override bug control if program is bug_of
					if(programma.title_2 == Translator::Logo::BUG_OFF)
				  		gestione_logo = false
				  	end



				   if(load_same_template==false)
				  		#load template on prev event
				  		load=deep_copy(Translator::NEW_LOGO.clone)#Translator::NEW_LOGO.clone
			  			load["event_type"]="sBRA"
			  			load["local_tx_time"]=Timecode.add_timecode(load_tx_time,@vertigo_preroll)
			  			load["title"]="LoadLayout:#{template},#{layer}"
		  				load["position_secondary"]=load_position_priority
		  				load["position"]=(programma.position) - load_position
			  			@brandings.push(PlaylistStructure.new(load))
			  		end

					#NOTA
					nota=deep_copy(Translator::NEW_LOGO.clone)#Translator::NEW_LOGO.clone
				  	nota["event_type"]="sBRA"
				  	nota["tx_id"][0]="NOTA"
				  	nota["local_tx_time"]=tx_time
				  	
				  	if(dynamic)
				  		dyn_txt = "#{tipo_effetto_sh} "
				  		dynamics.each do |dyn|
				  			begin
						  		if(dyn.comand=="UpdateText:")
						  			dyn_txt += "- #{dyn.param3.param3.gsub('\\','')}"
						  		end
						  		if(dyn.comand=="SetGraphic:")

						  			dyn_txt += "- #{dyn.param1.split('\\')[-1]} "
						  		end
					  		rescue 
					  			nota["title"]="- #{tipo_effetto} - dynamics"
					  		end
				  		end
				  		nota["title"]=dyn_txt
				  	else
				  		nota["title"]="- #{tipo_effetto} -"
				  	end
				  	
		  			nota["position_secondary"]=position
		  			nota["position"]=programma.position
		  			nota["tipo"]=224
		  			position+=1 
		  			#cup_template["priority"]=2
		  			@brandings.push(PlaylistStructure.new(nota))



				    ##
				    # se l'effetto ha dei dynimic le metto in playlist 
				    # prima dell'evento
				    # 
				    if(dynamic)

				    	dynamics.each do |dyn|
				    		if(dyn.comand=="UpdateText:")
				    			cmd = "UpdateText:#{dyn.template},#{dyn.region},RTObject,#{dyn.param2}\\,#{dyn.param3}"
								updateText=deep_copy(Translator::NEW_LOGO.clone)#Translator::NEW_LOGO.clone
							  	updateText["event_type"]="sBRA"

							  	if(fulltime)
			  						updateText["local_tx_time"]=Timecode.add_timecode("00:00:00:00",@vertigo_preroll)
		  							updateText["position_secondary"]=1
		  							updateText["position"]= (programma.position) -1
		  						else
		  							cup_time_in_load = Timecode.add_timecode(tx_time,@vertigo_preroll)
		  							
		  							if(Timecode.convert_to_frames(cup_time_in_load)<125)
		  								updateText["local_tx_time"]="00:00:00:00"
		  							else
		  								updateText["local_tx_time"]=Timecode.diff_timecode(cup_time_in_load, "00:00:05:00")
		  							end
		  							updateText["position"]=programma.position	
		  							updateText["position_secondary"]=position
		  							position+=1
		  						end

							  	updateText["extended_data"]="#{cmd}"				 
							  	updateText["title"]=""	  			  		 
					  			updateText["tx_duration"]="00:00:01:00"
					  			updateText["priority"]=2
					  			updateText["tipo"]=416
							  	 
							  	@brandings.push(PlaylistStructure.new(updateText))
				    		end
				    		if(dyn.comand=="SetGraphic:")
				    			cmd = "SetGraphic:#{dyn.template},#{dyn.region},#{dyn.param1}"
								setGraphic=deep_copy(Translator::NEW_LOGO.clone)#Translator::NEW_LOGO.clone
							  	setGraphic["event_type"]="sBRA"

								if(fulltime)
			  						setGraphic["local_tx_time"]=Timecode.add_timecode("00:00:00:00",@vertigo_preroll)
		  							setGraphic["position_secondary"]=1
		  							setGraphic["position"]= (programma.position) -1
		  						else
		  							cup_time_in_load = Timecode.add_timecode(tx_time, @vertigo_preroll)
		  							if(Timecode.convert_to_frames(cup_time_in_load)<125)
		  								setGraphic["local_tx_time"]="00:00:00:00"
		  							else
		  								setGraphic["local_tx_time"]=Timecode.diff_timecode(cup_time_in_load, "00:00:05:00")
		  							end
		  							setGraphic["position_secondary"]=position
					  			    setGraphic["position"]=programma.position
					  			    position+=1
		  						end

							  	setGraphic["extended_data"]="#{cmd}" 
							  	setGraphic["title"]="" 	
					  			setGraphic["tx_duration"]="00:00:01:00"
					  			setGraphic["priority"]=2
					  			setGraphic["tipo"]=416
							  	
							  	@brandings.push(PlaylistStructure.new(setGraphic))
				    		end				    		
				    	end
				    end
			




			  		### BUG CUT DOWN ##
			  		#
			  		#
				  	cdn=deep_copy(Translator::NEW_LOGO.clone)#Translator::NEW_LOGO.clone
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




				    if(tipo_effetto=="ENDCREDITS" || tipo_effetto == "TRAPOCO")
						#cup template effect
						cup_template_load=deep_copy(Translator::NEW_LOGO.clone)#Translator::NEW_LOGO.clone
					  	cup_template_load["event_type"]="sBRA"
					  	cup_time_in_load = Timecode.add_timecode(tx_time,@vertigo_preroll)
					  	cup_template_load["local_tx_time"]=Timecode.diff_timecode(cup_time_in_load, "00:00:05:00")		  	
					  	cup_template_load["title"]="SetupAll:#{layer}"	  	
			  			cup_template_load["position_secondary"]=position
			  			cup_template_load["position"]=programma.position
			  			cup_template_load["tx_duration"]="00:00:01:00"
			  			cup_template_load["priority"]=2
					  	position+=1
					  	@brandings.push(PlaylistStructure.new(cup_template_load))
				    end



					### CUT UP TEMPLATE
					#
					#
					cup_template=deep_copy(Translator::NEW_LOGO.clone)#Translator::NEW_LOGO.clone
				  	cup_template["event_type"]="sBRA"
				  	# set timecode of cutup!
				  	cup_time_in = Timecode.add_timecode(tx_time,@vertigo_preroll)
				  	cup_time_in = Timecode.diff_timecode(cup_time_in, preroll_in) if(Timecode.convert_to_frames(cup_time_in)>0)
				  	cup_template["local_tx_time"]=cup_time_in
				  	cup_template["title"]="FireSalvo:#{SHOW_CMD},#{layer}"		  	
		  			cup_template["position_secondary"]=position
		  			cup_template["position"]=programma.position
		  			cup_template["priority"]=2
				  	position+=1
				  	@brandings.push(PlaylistStructure.new(cup_template))


					### CUT DOWN TEMPLATE
					#
					#
					cdn_template=deep_copy(Translator::NEW_LOGO.clone)#Translator::NEW_LOGO.clone
				  	cdn_template["event_type"]="sBRA"
				  	tmp_time_out=Timecode.add_timecode(cup_time_in, durata)
				  	tmp_time_out=Timecode.add_timecode(tmp_time_out, @vertigo_preroll)
				  	tmp_time=Timecode.diff_timecode(tmp_time_out,preroll_out)
				  	cdn_template["local_tx_time"]=tmp_time
				  	cdn_template["title"]="FireSalvo:#{HIDE_CMD},#{layer}"
		  			cdn_template["position_secondary"]=position
		  			cdn_template["position"]=programma.position
		  			cdn_template["priority"]=3
				  	position+=1
				  	@brandings.push(PlaylistStructure.new(cdn_template))

			  		### BUG CUT UP ##
			  		#
			  		#
				  	cup=deep_copy(Translator::NEW_LOGO.clone)#Translator::NEW_LOGO.clone
				  	cup["event_type"]="sBUG"
				  	cup["local_tx_time"]=Timecode.add_timecode(Timecode.add_timecode(tx_time,@vertigo_preroll),Timecode.add_timecode(durata,ANTICIPO_LOGOS))
				  	cup["title"]="FireSalvo:#{SHOW_CMD},1"
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