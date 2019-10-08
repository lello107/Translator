
Translator.debug_path="/Users/lello107/GEMME/Translator/bin/public/dump/"
Translator.list_stored_class()
pl = Translator.load_class(Translator.list_stored_class[1][:playlist])
pl.branding = Translator::Branding.new(pl.playlist, true, false)
pl.generate_iconx()
pl.generate_promos()
pl.generate_commercials()
pl.generate_brandings()
pl.generate_lst_events()
pl_out = HarrisV12::Louthinterface.new(:rows=>pl.lst_rows)
pl_out.crc32=HarrisV12.calc_crc32(pl_out)
file = "peppa6.lst"
File.open(file,"wb") { |fi| pl_out.write(fi)}
