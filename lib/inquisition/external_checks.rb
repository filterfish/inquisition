checks = {
  'filesystem/size' => lambda { |ohai,target|
    file_system(ohai, target['device'])[:kb_size]
  },
  'filesystem/percent_used' => lambda {|ohai,target|
    file_system(ohai, target['device'])[:percent_used]
  },
  'memory/free' => lambda { |ohai,target|
    ohai[:memory]['free']
  },
  'process/rss' => lambda { |ohai,target|
    pid = File.read(target['pid_file']).strip
    status = File.read("/proc/#{pid}/stat")
    status[24] * PAGE_SIZE
  },
  'process/exists' => lambda { |ohai,target|
    pid = File.read(target['pid_file']).strip
    File.exists?(File.join('/proc', pid))
  },
  'amqp/depth' => lambda { |ohai, queue_name|
    res = nil
    popen4("/usr/sbin/rabbitmqctl list_queues") do |pid, stdin, stdout, stderr|
      res = stdout.each_line.map { |line| line.split}.detect do |fields|
        fields[0].strip == queue_name['queue_name']
      end[1]
    end
    res
  }
}
