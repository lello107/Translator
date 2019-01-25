require "Translator/version"
require "timecode"
require 'HarrisV12'
require 'HarrisLouth'
require 'fileutils'


module Translator
	require "Translator/playlist_structure"
	require "Translator/iconx_logo"
	require "Translator/iconx"
	require "Translator/iconx_promo"
	require "Translator/iconx_commercial"
	require "Translator/branding"
	require "Translator/branding_online"
	require "Translator/commercial"	
	require "Translator/logo"
	require "Translator/import_lst"

	
	@playlist=nil


	NEW_LOGO={
		"recon_uid"=>"100",
		"tx_id"=>["ICONX", "SV82054-HDTX-AU-ENG", "SV82054-HDTX-AU-POL", "SV82054-HDTX-EC-POL"],
		"title"=>"CUP:1",
		"title_2"=>"Lolirock",
		"local_tx_time"=>"00:00:02:15",
		"prog_type"=>"Series",
		"schedule_event_type"=>"LOG",
		"event_type"=>"LOGO",
		"component_type"=>["Video", "Audio", "Audio", "Subtitles"],
		"tx_duration"=>"00:00:02:00",
		"timecode_in"=>["00:00:00:00", "00:00:00:00", "00:00:00:00", "00:00:00:00"],
		"tipo"=> 160
	}

	SVIDEO={
		"recon_uid"=>"100",
		"tx_id"=>["ICONX", "SV82054-HDTX-AU-ENG", "SV82054-HDTX-AU-POL", "SV82054-HDTX-EC-POL"],
		"title"=>"CUP:1",
		"title_2"=>"Lolirock",
		"local_tx_time"=>"00:00:02:15",
		"prog_type"=>"Series",
		"schedule_event_type"=>"LOG",
		"event_type"=>"LOGO",
		"component_type"=>["Video", "Audio", "Audio", "Subtitles"],
		"tx_duration"=>"00:00:02:00",
		"timecode_in"=>["00:00:00:00", "00:00:00:00", "00:00:00:00", "00:00:00:00"],
		"tipo"=> 128
	}

	MANDATARY_FIELDS={
		:recon_uid=>"140623669",
 		:event_type=>"PRES",
 		:schedule_event_type=>"NAV",
 		:title_2=>"Dc4 Dc2898 January Now Next Laters Corrected",
 		:media_id=>"FO23870-HDTX",
 		:tx_duration=>"00:00:05:00",
 		:prog_type=>"",
 		:title=>"Dc4 Dc2898 January Now Next Laters Corrected",
 		:num_of_pe_components=>"2",
 		:timecode_in=>["10:00:00:00", "00:00:00:00"],
 		:component_type=>["Video", "Audio"],
 		:tx_id=>["FO23870-HDTX", "FO23870-HDTX-AU-POL"]
	}

	OPTIONS = {
	  	# set 1 to all programs in playlist 
	  	# => Enable/Disable
	    :segment_programs => false,
	    :segment_programs_identify=>"PROG",
	    :segment_programs_val => 1,
	    #ABOX <-- tipo2
	    :abox_converted=> true,
	    #BBOX <-- tipo
	    :bbox_converted=>true,
	    # => WRITE destination as json
	    :to_json=>false
	  }

	  @debug_path = "/public/dump/"

	  class << self; attr_accessor :debug_path; end


	  	def self.list_stored_class()
	  		playlists = Dir.glob("#{@debug_path}*.playlist")
	  		arr_playlists=[]

	  		playlists.each do |pl|
	  			result= {:playlist=>File.basename(pl), :created_at=>File.ctime(pl) }
	  			arr_playlists.push(result)
	  		end
	  		return arr_playlists.sort! {|a,b| b[:created_at]<=> a[:created_at]}

	  	end

	  	def self.debug_last()
	  		arr= self.list_stored_class()
	  		return arr.first[:playlist]
	  	end

	  	def self.load_class(destination_file)
			 
			File.open("#{@debug_path}#{destination_file}") do |f|
				@playlist = Marshal.load(f)
			end

		end

		def self.load_last()
			arr= self.list_stored_class()
			destination_file = arr.first[:playlist]
			File.open("#{@debug_path}#{destination_file}") do |f|
				@playlist = Marshal.load(f)
			end		
		end

	class Playlist# < Hash
		 
		attr_accessor :playlist,:size,:hash
		

		# Class Translator::Logo
		attr_accessor :logo
		# Class Translator::Iconx
		attr_accessor :iconx

		attr_accessor :lst_rows
		# Class Translator::Commercial
		attr_accessor :commercial
		# Class Translator::Commercial
		attr_accessor :promo
		# Class Translator::Branding
		attr_accessor :branding

		attr_accessor :logo_active,:commercial_active,:promo_active, :branding_active,:iconx,:v12, :debug_path

		def initialize(array: [], branding_active: true, logo_active: true, promo_active: true, commercial_active: true, iconx: true,v12: false, local_branding: false)
			@playlist=[]
			@lst_rows=[]
			position=0
			array.each do |hash|
				hash[:position]=position
				hash[:position_secondary]=0
				hash[:priority]=0
				@playlist.push(Translator::PlaylistStructure.new(hash))
				position+=1
			end
			
			@logo_active=logo_active
			@commercial_active = commercial_active
			@promo_active = promo_active
			@branding_active = branding_active
			@iconx = iconx
			@v12=v12
			@local_branding = local_branding


			@debug_path = Translator.debug_path

			@logo = Translator::Logo.new(@playlist) if @logo_active
			@iconx = Translator::IconxLogo.new(@playlist) if @iconx
			
			if(@v12)
				@promo = Translator::IconxPromo.new(@playlist) if @promo_active
				@commercial = Translator::IconxCommercial.new(@playlist,@v12) if @commercial_active
			else
				@promo = Translator::Promo.new(@playlist,@v12) if @promo_active
				@commercial = Translator::Commercial.new(@playlist,@v12) if @commercial_active
			end
			@branding = Translator::Branding.new(@playlist, @v12, @local_branding) if @branding_active 


		end

		## Genereta harris lst format using gem HarrisLouth
		#
		#
		##
		def generate_lst_events()
			#new_playlist=[]
			@playlist.sort_by!{|x| [x.position, x.position_secondary, x.priority]}
			#hash = @playlist.group_by{|x| x.position}
			#hash.each do |k,v|
			# v.reject { |n| n.position_secondary < 1}.sort_by!(&:local_tx_time)
			#end
			#hash.each do |k,v|
			# 	v.each do |row|
			# 		new_playlist.push(row)
			# 	end
			#end
			## reoder playlist based on position tag
			#@playlist.sort_by!{|x,y| x.position <=> y.position}
			## create harris formatted playlist
			@playlist.each do |row|
				if(@v12)
			    	if(row.tipo==1)
			    		row.tipo=0
			    	end
			    end
			    tipo = row.event_type
			    tipo2 = row.schedule_event_type
			    segment = tipo ==	OPTIONS[:segment_programs_identify] ? OPTIONS[:segment_programs_val] : 255		 


			    line = {
			    	:type_			=>		row.tipo,
			    	:id 			=>		row.video_tx_id,
			    	:onair_tc		=>		row.local_tx_time,
			    	:som 			=>		row.video_timecode_in,
			    	:dur 			=>		row.tx_duration,
			    	:title 			=>		row.title,
	          		:reconcile_key	=>		row.recon_uid#row.recon_uid.to_i.to_s(20)
			    }

				if row.tipo == 1 
			    	line.merge!({:segment=>segment})				if OPTIONS[:segment_programs]
			    	line.merge!({:box_aid=>tipo2.ljust(8)}) 		if OPTIONS[:abox_converted]
			    	line.merge!({:b_id=>tipo.ljust(8)}) 			if OPTIONS[:bbox_converted]
				end
				if(@v12)
					@lst_rows.push(line)
				else
			    	@lst_rows.push(HarrisLouth.create_row(line))
				end

			    puts "ROW: #{row.position};#{row.position_secondary};#{row.priority} --> #{row.title} #{row.tipo} "
			end
		end

		## Generate logo secondary event to playlist
		#
		# 
		def generate_logos()
			#@logo = Translator::Logo.new()
			@logo.generate_logo
			@logo.iconxlogos.each do |logo|
				@playlist.push(logo)
			end

		end

		## Generate logo secondary event to playlist
		#
		# 
		def generate_iconx()
			#@logo = Translator::Logo.new()
			@iconx.generate_iconx_logos
			@iconx.iconxlogos.each do |logox|
				#byebug
				@playlist.push(logox)
			end

		end

		## Generate commercials secondary event to playlist
		#
		# 
		def generate_commercials()
			#@logo = Translator::Logo.new()
			@commercial.generate_commercials
			@commercial.commercials.each do |commercial|
				@playlist.push(commercial)
			end

		end		

		## Generate promo secondary event to playlist
		#
		# 
		def generate_promos()
			#@logo = Translator::Logo.new()
			@promo.generate_promos
			@promo.promos.each do |promo|
				@playlist.push(promo)
			end

		end		

		## Generate branding secondary event to playlist
		#
		# 
		def generate_brandings()
			#@logo = Translator::Logo.new()
			@branding.generate_brandings
			@branding.brandings.each do |brand|
				@playlist.push(brand)
			end

		end		

		def store_class(destination_file)
			dump_file=File.basename(destination_file,'.xml.lst')
			File.open("#{@debug_path}#{dump_file}.playlist","w") do |f|
					Marshal.dump(self,f)
			end

		end

		## export playlist as lst file
		#
		#
		def export_lst(destination_file)
			#debug
			store_class("#{destination_file}_init")

			self.generate_iconx() if @iconx
			self.generate_logos() if @logo_active
			self.generate_promos() if @promo_active
			self.generate_commercials() if @commercial_active
			self.generate_brandings() if @branding_active
			

			generate_lst_events()
			#debug
			store_class(destination_file)
			unless(@v12)
				pl = HarrisLouth::Louthinterface.new(:rows=>@lst_rows)
			else
				pl = HarrisV12::Louthinterface.new(:rows=>@lst_rows)
				pl.crc32=HarrisV12.calc_crc32(pl)
			end
			#byebug
			
			file = "#{destination_file}"
			File.open(file,"wb") { |fi| pl.write(fi)}
		end

	end


end 
