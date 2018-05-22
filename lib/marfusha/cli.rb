require "slop"

module Marfusha
  class Cli
    def initialize(argv=ARGV.dup)
      @argv = argv
      @subcommand = @argv.shift
    end

    def run
      case @subcommand
      when "controller"
        require "marfusha/controller"
        opt = Slop.parse(@argv) do |o|
          o.string '--loglevel', 'log level', default: 'warn'
        end
        Controller.new(opt).run
      when "subscriber"
        require "marfusha/subscriber"
        opt = Slop.parse(@argv) do |o|
          o.string '--loglevel', 'log level', default: 'warn'
        end
        Subscriber.new(opt)
      when "provisioner"
        require "marfusha/provisioner"
        opt = Slop.parse(@argv) do |o|
          o.string '--loglevel', 'log level', default: 'warn'
        end
        Provisioner.new(opt)
      else
        $stderr.puts <<~USAGE
          #{$0}: valid subbcommands:
              controller
              provisionewr
              subscriber
          Showing more info with --help option with each subcommand
          ---
        USAGE
        raise "Invalid subcommand: #{ARGV.inspect}"
        # TODO: usage
      end
    end
  end
end

exit Marfusha::Cli.new.run
