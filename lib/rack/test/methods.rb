require "forwardable"

module Rack
  module Test

    # This module serves as the primary integration point for using Rack::Test
    # in a testing environment. It depends on an app method being defined in the
    # same context, and provides the Rack::Test API methods (see Rack::Test::Session
    # for their documentation).
    #
    # Example:
    #
    #   class HomepageTest < Test::Unit::TestCase
    #     include Rack::Test::Methods
    #
    #     def app
    #       MyApp.new
    #     end
    #   end
    module Methods
      extend Forwardable

      def method_missing(methId, *argv)
        if methId == :app
          if defined?(CONFIG_RU)
            config_ru = CONFIG_RU
          else
            calling_file = caller.first.split(":").first
            config_ru = ::File.dirname(calling_file) + '/../config.ru'
          end
          eval "Rack::Builder.new {( " +::File.read(config_ru) + "\n )}"
        else
          super
        end
      end

      def rack_mock_session(name = :default) # :nodoc:
        return build_rack_mock_session unless name

        @_rack_mock_sessions ||= {}
        @_rack_mock_sessions[name] ||= build_rack_mock_session
      end

      def build_rack_mock_session # :nodoc:
        Rack::MockSession.new(app)
      end

      def rack_test_session(name = :default) # :nodoc:
        return build_rack_test_session(name) unless name

        @_rack_test_sessions ||= {}
        @_rack_test_sessions[name] ||= build_rack_test_session(name)
      end

      def build_rack_test_session(name) # :nodoc:
        Rack::Test::Session.new(rack_mock_session(name))
      end

      def current_session # :nodoc:
        rack_test_session(_current_session_names.last)
      end

      def with_session(name) # :nodoc:
        _current_session_names.push(name)
        yield rack_test_session(name)
        _current_session_names.pop
      end

      def _current_session_names # :nodoc:
        @_current_session_names ||= [:default]
      end

      METHODS = [
        :request,
        :get,
        :post,
        :put,
        :delete,
        :head,
        :follow_redirect!,
        :header,
        :set_cookie,
        :clear_cookies,
        :authorize,
        :basic_authorize,
        :digest_authorize,
        :last_response,
        :last_request
      ]

      def_delegators :current_session, *METHODS
    end
  end
end
