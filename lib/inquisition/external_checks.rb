checks = {
  'filesystem/size' => lambda { |target|
    Convertor.parse(file_system(target['device'])[:kb_size])
  },
  'filesystem/percent_used' => lambda {|target|
    Convertor.parse(file_system(target['device'])[:percent_used])
  },
  'memory/free' => lambda { |target|
    Convertor.parse(memory(:memory)['free'])
  },
  'process/rss' => lambda { |target|
    pid = File.read(target['pid_file']).strip
    status = File.read("/proc/#{pid}/stat")
    status[24] * PAGE_SIZE
  },
  'process/exists' => lambda { |target|
    pid = File.read(target['pid_file']).strip
    File.exists?(File.join('/proc', pid))
  },
  'amqp/depth' => lambda { |queue_name|
    res = nil
    popen4("/usr/sbin/rabbitmqctl list_queues") do |pid, stdin, stdout, stderr|
      res = stdout.each_line.map { |line| line.split}.detect do |fields|
        fields[0].strip == queue_name['queue_name']
      end
    end
    Convertor.parse(res[1])
    (res) ? Convertor.parse(res[1]) : -1
  }
}
