module Translator
	     #    recon_uid: object.records[i].recon_uid,
         #    tx_id: object.records[i].tx_id,
         #    title: object.records[i].title,
         #    title2: object.records[i].title2,
         #    local_tx_time: object.records[i].local_tx_time,
         #    prog_type: object.records[i].prog_type,
         #    schedule_event_type: object.records[i].schedule_event_type,
         #    tx_duration: object.records[i].tx_duration,
         #    timecode_in: object.records[i].timecode_in,

		#hash = [{"recon_uid"=>"140623666", "tx_id"=>["SV82054-HDTX", "SV82054-HDTX-AU-ENG", "SV82054-HDTX-AU-POL", "SV82054-HDTX-EC-POL"], "title"=>"Lolirock Episode 20", "local_tx_time"=>"06:00:05:00", "prog_type"=>"Series", "schedule_event_type"=>"PROG", "tx_duration"=>"00:01:56:20", "timecode_in"=>["10:00:00:00", "00:00:00:00", "00:00:00:00", "00:00:00:00"],"component_type"=>["Video"]}]


	class PlaylistStructure

		attr_accessor :video_timecode_in, :position_secondary, :video_tx_id,:tipo,:position,:recon_uid,:event_type,:tx_id,:title,:title_2,:local_tx_time,:prog_type,:schedule_event_type,:tx_duration,:timecode_in

		def initialize(hash) 
			convert_to_obj(hash)
			add_extra_info()
		end


	    def convert_to_obj(h)
	      @tipo=1	
	      @position=0
	      @position_secondary=0
	      @priority=1
	      
	      h.each do |k,v|
	        self.class.send(:attr_accessor, k)
	        instance_variable_set("@#{k}", v) 
	        convert_to_obj(v) if v.is_a? Hash
	      end
	    end




	    ## create video_timecode_in attribute from timecode_in array
		#
		##
		def add_extra_info
			raise "Missing local_tx_time! Fatal error! row: #{@position}" 								if @local_tx_time == nil
			raise "Missing recon_uid! Fatal error! row: #{@position}" 									if @recon_uid == nil
			raise "Missing tx_duration! Fatal error! row: #{@position}" 								if @tx_duration == nil
			raise "Missing Component Video! Fatal error! row: #{@position} time: #{@local_tx_time}" 	if @component_type.index("Video") == nil
	 		raise "Missing Video timecode_in! Fatal error! row: #{@position} time: #{@local_tx_time}" 	if @timecode_in[@component_type.index("Video")] == nil
	 		raise "Missing Video tx_id! Fatal error! row: #{@position} time: #{@local_tx_time}" 		if @tx_id[@component_type.index("Video")] == nil

	 		#Rails.logger.info("@component_type: #{@component_type} - #{@component_type.class}  - #{@title}")


	 		#if(@component_type.class != Array)
	 		#	@component_type=[@component_type]
	 		#end

	 		#if @tx_id.class !=  Array
	 		#	@tx_id = [@tx_id]
	 		#end
	 		#if @timecode_in.class !=  Array
	 		#	@timecode_in=[@timecode_in]
	 		#end

	 		#Rails.logger.info("@component_type: #{@component_type} - #{@component_type.class}  - #{@title}")


	 		raise "Video Component is not an array!! lello bug!, #{@tx_id}" 										if @timecode_in.class !=  Array
	 		raise "Video Component tx_id is not an array!! lello bug!" 										if @tx_id.class !=  Array

				@video_timecode_in=@timecode_in[@component_type.index("Video")]
				@video_tx_id=@tx_id[@component_type.index("Video")]


	 
		end

	end
 

end 