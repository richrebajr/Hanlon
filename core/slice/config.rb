require "json"
require "yaml"

# Root ProjectHanlon namespace
module ProjectHanlon
  class Slice

    # ProjectHanlon Slice Config
    # Used to retrieve the current Hanlon configuration and the
    # defined iPXE-boot script for the Hanlon server
    class Config < ProjectHanlon::Slice

      # Initializes ProjectHanlon::Slice::Model including #slice_commands, #slice_commands_help
      # @param [Array] args
      def initialize(args)
        super(args)
        @hidden = true
        #@engine = ProjectHanlon::Engine.instance
        @uri_string = ProjectHanlon.config.hanlon_uri + ProjectHanlon.config.websvc_root + '/config'
      end

      def slice_commands
        # Here we create a hash of the command string to the method it
        # corresponds to for routing.
        { :read    => "read_config",
          :dbcheck => "db_check",
          :ipxe    => "generate_ipxe_script",
          :default => :read,
          :else    => :read }
      end

      def db_check
        raise ProjectHanlon::Error::Slice::MethodNotAllowed, "This method cannot be invoked via REST" if @web_command
        puts get_data.persist_ctrl.is_connected?
      end

      def read_config
        uri = URI.parse @uri_string
        config = hnl_http_get_hash_response(uri)
        puts "ProjectHanlon Config:"
        config.each { |key,val|
            print "\t#{key.sub("@","")}: ".white
            print "#{val} \n".green
        }
      end

      def generate_ipxe_script
        uri = URI.parse @uri_string + '/ipxe'
        ipxe_script = hnl_http_get_text(uri)
        puts ipxe_script
      end

    end
  end
end
