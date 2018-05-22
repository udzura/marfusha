require "serverengine"

module Marfusha
  class Subscriber
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
        loop do
          sleep 1
        end
      end
    end
  end
end
