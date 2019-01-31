module Translator

	class ImportLst

		attr_accessor :builder, :lst_list,:xml_path

		def initialize(lst_path) #PlaylistStructure
		
		Rails.logger.info("Translator::ImportLst Importing lst file: #{lst_path}")
		#@lst_list = HarrisLouth.read_lst("#{Rails.root}/public/test_dj.lst")
		@lst_list = HarrisLouth.read_lst(lst_path)

		after_midnight=false

		@builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
		  xml.playlist("num_of_primary_events"=> @lst_list.rows.size) {
		      
		      @lst_list.rows.each do |o|

		      	#next if(o.extended_type !=1 || o.extended_type != 0 || o.type_ != 0)

		      	next if( o.type_ != 0)
		      	next if( o.id.delete(' ').empty?)

		      	puts "#{o.louth_id} #{o.louth_title.encode!('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')}"

		      	recon_uid = rand(1000000000)
		      	material_uid = rand(9000000)
		      	tx_id = o.louth_id.rstrip
		      	duration = o.dur
		      	som = o.som
		      	begin
		      		title = o.louth_title.encode!('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: ' ').rstrip
		      	rescue Exception=>e
		      		puts e
		      	end

		      	on_air = o.onair_tc
		      	on_air_30h = o.onair_tc
		      	if(after_midnight)
		      		on_air_30h += Timecode.convert_from_frames(2160000)
		      	end
		      	event_type, schedule_event_type, title_2 = get_event_type(o)
		  

		  		plan_event_date = DateTime.now.strftime("%d/%m/%Y")
		  		tx_date = DateTime.now.strftime("%d/%m/%Y")

		      	#puts o.louth_title

		      	#puts "#{tx_id} #{title}"

		      
		      	xml.primary_event {
		      		xml.recon_uid  recon_uid
		      		xml.external_spot_id
		      		xml.event_type event_type
		      		xml.schedule_event_type schedule_event_type
		      		xml.tx_source
		      		xml.plan_event_date "28/11/2016"
		      		xml.plan_event_time "06:00:00:00"
		      		xml.plan_duration duration
		      		xml.media_id  tx_id
		      		xml.tx_date  "28/11/2016"
		      		xml.tx_time  on_air
		      		xml.tx_duration duration
		      		xml.local_tx_time  on_air
		      		xml.local_tx_time_30hr_clock on_air_30h
		      		xml.season_name
		      		xml.season_number
		      		xml.production_type
		      		xml.production_companies
		      		xml.deal_sub_type
		      		xml.country  "IT"
		      		xml.title title
		      		xml.title_uid rand(9000000)
		      		xml.version_uid rand(9000000)
		      		xml.version_type "Standard"
		      		xml.ratio  "16:9"
		      		xml.resolution  "HD"
		      		xml.episode_number
		      		xml.premiere 
		      		xml.max_parts 1
		      		xml.title_2 title_2
		      		xml.epg_title ""
		      		xml.genre
		      		xml.sub_genre


		      		xml.pe_components{
		      			xml.component{
		      				xml.material_uid material_uid
		      				xml.parent_event_uid recon_uid
		      				xml.parent_event_type "PROG"
		      				xml.component_type "Video"
		      				xml.material_type "Video"
		      				xml.tx_id tx_id
		      				xml.barcode tx_id
		      				xml.language
		      				xml.tracks("num_of_tracks"=>0)
		      				xml.status "RFTX"
		      				xml.part_num 1
		      				xml.segment_num 1
		      				xml.timecode_in som
		      				xml.duration duration
		      				xml.timecode_out Timecode.add_timecode(som,duration)


		      			}
			      		xml.component{
		      				xml.material_uid material_uid
		      				xml.parent_event_uid recon_uid
		      				xml.parent_event_type "PROG"
		      				xml.component_type "Audio"
		      				xml.material_type "Audio"
		      				xml.tx_id tx_id
		      				xml.barcode tx_id
		      				xml.language
		      				xml.tracks("num_of_tracks"=>1)
		      				xml.status "RFTX"
		      				xml.part_num 1
		      				xml.segment_num 1
		      				xml.timecode_in som
		      				xml.duration duration
		      				xml.timecode_out Timecode.add_timecode(som,duration)


		      			}	      			
		      		}
		        	#xml.object(:type => o, :class => o.class, :id => o.object_id)
		        }

		      end
		
		  }
		end
		#puts @builder.to_xml
		#File.write("#{Rails.root}/public/test4.xml",@builder.to_xml)

		basename= File.basename(lst_path,".lst")
		@xml_path = "#{Rails.root}/public/exlst/#{basename}.xml"
		File.open(@xml_path,"w") do |f|
		  f.write @builder.to_xml
		end
		#File.write(@xml_path,@builder.to_xml)
		Rails.logger.info("Translator::ImportLst created xml file: #{@xml_path}")
		end

		def get_event_type(row)
			event_type = "PROG"
			schedule_event_type = ""
			title = ""

			event_type = "PROG" if(row.type_ == 0)
			event_type = "NOTA" if(row.type_ == 224)
			if(row.type_ ==0)
				## PROGRAMMS ##
				#
				#
				if(row.louth_title =~ /(DX#)/)
					event_type = "PROG"
					schedule_event_type = "PROG"
					title_2 = "BUG BOTTOM RIGHT"
				end

				##  PRESENTATION ##
				#
				#
				if(row.louth_title =~ /(^F00)/)
					event_type = "PROM"

				end
				if(row.louth_title =~ /^L00/)
					event_type = "PRES"
					if(row.louth_title =~ /(DC CROSS|XD CROSS|DJ CROSS|DE CROSS)/)
						schedule_event_type = "DISX"
					end
				end
				

				## SKYXPROM_IT ##
				#
				#
				if(row.louth_title =~ /(^F00 SKY#)/)
					event_type = "PRES"
					schedule_event_type = "SKYX"
				end					

				## COMMERCIAL ##
				#
				#
				if(row.louth_title =~ /(^YPM|^YCC)/)
					event_type = "COMM"
					schedule_event_type = "COMMERCIAL_IT"
				end		

				if(row.louth_title =~ /(^YFM|^ACC)/)
					event_type = "COMM"
					schedule_event_type ="FRAME_SPOT_IT"
				end		
				if(row.louth_title =~ /(^YSN|^YSS)/)
					event_type = "COMM"
					schedule_event_type ="BILLBOARD_IT"
				end						

			end
			return event_type, schedule_event_type, title_2
		end

		def get_schedule_event_type(row)
			event_type = "PROG"
			return row.box_aid
		end

	end #end class

end #end module