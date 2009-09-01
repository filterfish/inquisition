checks = {
  'filesystem/size' => lambda { |ohai,target| file_system(ohai, target['device'])[:kb_size] },
  'filesystem/percent_used' => lambda {|ohai,target| file_system(ohai, target['device'])[:percent_used] }
}
