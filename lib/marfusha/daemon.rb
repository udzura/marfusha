require 'serverengine'

module Marfusha
  module Publisher
    def before_run
      @sock = TCPServer.new(config[:bind], config[:port])
    end

    attr_reader :sock
  end

  module PublisherWorker
    def run
      until @stop
        # you should use Cool.io or EventMachine actually
        c = server.sock.accept
        c.write "This is publisher!\n"
        c.close
      end
    end

    def stop
      @stop = true
    end
  end

  module Subscriber
    def before_run
      @sock = TCPServer.new(config[:bind], config[:port])
    end

    attr_reader :sock
  end

  module SubscriberWorker
    def run
      until @stop
        # you should use Cool.io or EventMachine actually
        c = server.sock.accept
        c.write "This is subscriber!\n"
        c.close
      end
    end

    def stop
      @stop = true
    end
  end
end

case ARGV[0]
when "publisher"
  options = {
    daemonize: true,
    supervisor: true,
    log: '/tmp/pub.log',
    pid_path: '/tmp/pub.pid',
    worker_type: 'process',
    workers: 4,
    bind: '0.0.0.0',
    port: 8310,
    server_process_name: 'marfusha: publisher',
    worker_process_name: 'marfusha: publisher worker',
  }
  eng = ServerEngine.create(Marfusha::Publisher, Marfusha::PublisherWorker, options)
  eng.run
when "subscriber"
  options = {
    daemonize: true,
    supervisor: true,
    log: '/tmp/sub.log',
    pid_path: '/tmp/sub.pid',
    worker_type: 'process',
    workers: 4,
    bind: '0.0.0.0',
    port: 8311,
    daemon_process_name: 'marfusha: subscriber',
    worker_process_name: 'marfusha: subscriber worker',
  }
  eng = ServerEngine.create(Marfusha::Subscriber, Marfusha::SubscriberWorker, options)
  eng.run
else
  raise "Invalid arg: #{ARGV.inspect}"
end
