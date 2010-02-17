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
        status = File.read("/proc/#{pid}/stat").split
        status[23].to_i * PAGE_SIZE
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
  },
  'http/get' => lambda { |config_item|
    uri = URI.parse(config_item[:uri])

    begin
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new((uri.query.nil?) ? uri.path : "#{uri.path}?#{uri.query}")
      response = http.request(request)
      (response.code.to_i == 200) ? true : false
    rescue Errno::ECONNREFUSED,Errno::ECONNRESET => e
      Inquisition::Logging.error("http/get #{uri}: #{e.message}")
      false
    end
  }
}
