require "serverengine"

module Marfusha
  module PublisherProvisioner
    def before_run
    end
  end

  class PublisherServer
    include Celluloid::IO
    finalizer :finalize
    def initialize(host, port)
      puts "*** Starting echo server on #{host}:#{port}"

      # Since we included Celluloid::IO, we're actually making a
      # Celluloid::IO::TCPServer here
      @server = TCPServer.new(host, port)
      async.run
    end

    def finalize
      @server.close if @server
    end

    def run
      loop { async.handle_connection @server.accept }
    end

    def handle_connection(socket)
      _, port, host = socket.peeraddr
      puts "*** Received connection from #{host}:#{port}"
      socket.write "I am publisher!!1"
      loop do
        p = socket.readpartial(4096)
        socket.write p
        if p.end_with? "\n"
          puts "*** #{host}:#{port} closed connection"
          socket.close
          break
        end
      end
    rescue EOFError
      puts "*** #{host}:#{port} disconnected"
      socket.close
    end
  end

  module PublisherWorker
    def initialize
      require "celluloid/autostart"
    end

    def run
      puts "Run Server!!!1"
      @runner = PublisherServer.new(config[:bind], config[:port])
      @alive = true
      puts "Server is now listening"
      while @alive
        sleep 0.01
      end
    end

    def stop
      puts "Accept stop"
      @runner.terminate if @runner
    rescue ::Celluloid::DeadActorError => e
      puts "Detect error #{e.inspect} and skip"
    ensure
      @alive = false
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
    workers: 1,
    bind: '0.0.0.0',
    port: 8310,
    server_process_name: 'marfusha: publisher',
    worker_process_name: 'marfusha: publisher worker',
  }
  eng = ServerEngine.create(Marfusha::PublisherProvisioner, Marfusha::PublisherWorker, options)
  eng.run
when "subscriber"
  options = {
    daemonize: true,
    supervisor: true,
    log: '/tmp/sub.log',
    pid_path: '/tmp/sub.pid',
    worker_type: 'process',
    workers: 1,
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
