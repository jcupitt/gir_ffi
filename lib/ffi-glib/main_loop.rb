require 'singleton'

GLib.load_class :MainLoop

module GLib
  # Overrides for GMainLoop, GLib's event loop
  class MainLoop
    # Class encapsulationg logic for running an idle handler to make Ruby code
    # run during GLib's event loop.
    class ThreadEnabler
      include Singleton

      FRAMERATE = 25
      DEFAULT_TIMEOUT = 1000 / FRAMERATE

      def initialize timeout = DEFAULT_TIMEOUT
        @timeout = timeout
      end

      def setup_idle_handler
        @handler_id ||= GLib.timeout_add(GLib::PRIORITY_DEFAULT,
                                         @timeout, handler_proc,
                                         nil, nil)
      end

      private

      def handler_proc
        proc do
          Thread.pass
          true
        end
      end
    end

    def run_with_thread_enabler
      case RUBY_ENGINE
      when 'jruby'
      when 'rbx'
      else # 'ruby' most likely
        ThreadEnabler.instance.setup_idle_handler
      end
      run_without_thread_enabler
    end

    alias_method :run_without_thread_enabler, :run
    alias_method :run, :run_with_thread_enabler
  end
end
