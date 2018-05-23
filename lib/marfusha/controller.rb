require "serverengine"
require "ffi-rzmq"

module Marfusha
  class Controller
    def initialize(opt)
    end

    def run
      options = {
        daemonize: false,
        supervisor: true,
        log: '/dev/stdout',
        pid_path: './conrtoller.pid',
        worker_type: 'process',
        workers: 1,
        bind: '0.0.0.0',
        port: 8311,
        worker_process_name: 'marfusha: controller worker'
      }
      s = ServerEngine.create(nil, Worker, options)
      s.run
      return 0
    end

    module Worker
      def run
        logger.info("This is controller!!")
        @running = true
        @ctx = ZMQ::Context.new
        @socket = @ctx.socket(ZMQ::REP)
        zmq_assert(@socket.setsockopt(ZMQ::LINGER, 100))
        zmq_assert(@socket.bind("tcp://127.0.0.1:8311"))

        while @running
          msg = ""
          if @socket.recv_string(msg, ZMQ::DONTWAIT) > 0
            logger.info("Got message!! #{msg.inspect}")
            zmq_assert(@socket.send_string("OK", ZMQ::DONTWAIT))
          end
          sleep 1
        end
      end

      def stop
        @running = false
      end

      private
      def zmq_assert(rc)
        raise "Last API call failed at #{caller(1)}" unless rc >= 0
      end
    end
  end
end
