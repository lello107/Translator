# Or wrap things up in your own class
module Translator

  class BrandingOnline
    include HTTParty
    
    attr_accessor :base_uri, :path

    def initialize()
      @base_uri = '192.168.57.153:3000'
      @path="/work_playlist_effects/gem_generate_branding.json"
    end

    def effetti(recon_uid)
       options = { body: { recon_uid: recon_uid } }
      self.class.post("http://#{@base_uri}#{path}", options)
    end

  end

end
  