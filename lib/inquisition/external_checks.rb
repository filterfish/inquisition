checks = {
  'filesystem/size' => lambda { |target|
    k = file_system(target[:device])
    if k
      Convertor.parse(k[:kb_size])
    else
      -1
    end
  },
  'filesystem/percent_used' => lambda {|target|
    p = file_system(target[:device])
    if p
      Convertor.parse(p[:percent_used])
    else
      -1
    end
  },
  'memory/free' => lambda { |target|
    Convertor.parse(memory(:memory)[:free])
  },
  'process/rss' => lambda { |target|
    if File.exists?(target[:pid_file])
      pid = File.read(target[:pid_file]).strip
      if File.exists?(File.join('/proc', pid))
        status = File.read("/proc/#{pid}/stat")
        status[24] * PAGE_SIZE
      else
        status = -1
      end
    else
      -1
    end
  },
  'process/exists' => lambda { |target|
    if File.exists?(target[:pid_file])
      pid = File.read(target[:pid_file]).strip
      File.exists?(File.join('/proc', pid))
    else
      -1
    end
  },
  'amqp/depth' => lambda { |queue_name|
    result = nil
    ret = popen4("/usr/sbin/rabbitmqctl list_queues") do |pid, stdin, stdout, stderr|
      result = stdout.each_line.map { |line| line.split }.detect do |fields|
        (fields[0].strip == queue_name[:queue_name]) unless fields.empty?
      end
    end

    if ret.exitstatus == 0
      Convertor.parse(result[1])
      (result) ? Convertor.parse(result[1]) : -1
    else
      -1
    end
  }
}
