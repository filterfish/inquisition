spec = Gem::Specification.new do |s|
  s.name = 'inquisition'
  s.version = '0.1'
  s.date = '2009-11-03'
  s.summary = 'Extensible monitoring tool'
  s.email = "filterfish@roughage.com.au"
  s.homepage = "http://github.com/filterfish/inquisition/"
  s.description = "Extensible monitoring tool"
  s.has_rdoc = false

  s.authors = ["Richard Heycock"]
  s.add_dependency('ohai', '>= 0.3.4')
  s.add_dependency('amqp', '>= 0.6.5')
  s.add_dependency("extlib")
  s.add_dependency("open4")

  s.executables = Dir::glob("bin/*").map{|exe| File::basename exe}

  s.files = Dir.glob("{bin,lib,config}/**/*")
end
