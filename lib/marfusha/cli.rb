require "slop"
require "marfusha/controller"

module Marfusha
  class Cli
    def initialize(argv=ARGV.dup)
      @argv = argv
      @subcommand = @argv.shift
    end

    def run
      case @subcommand
      when "controller"
        opt = Slop.parse(@argv) do |o|
          o.string '--loglevel', 'log level', default: 'warn'
        end
        Controller.new(opt).run
      when "worker"
      when "provisioner"
      else
        $stderr.puts <<~USAGE
          #{$0}: valid subbcommands:
              controller
              provisionewr
              worker
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
