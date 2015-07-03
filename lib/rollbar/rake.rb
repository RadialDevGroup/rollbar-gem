require 'rake'

module Rollbar
  module Rake
    def self.patch!
      skip_patch && return unless patch?

      ::Rake::Application.class_eval do
        if respond_to? :display_error_message
          alias_method :orig_display_error_message, :display_error_message
        else
          def orig_display_error_message; end
        end

        def display_error_message(ex)
          Rollbar.error(ex, :use_exception_level_filters => true)
          orig_display_error_message(ex)
        end
      end
    end

    def self.skip_patch
      warn('[Rollbar] Rollbar is disabled for Rake tasks since your Rake version is under 0.9.x. Please upgrade to 0.9.x or higher.')
    end

    def self.patch?
      major, minor, *_ = rake_version.split('.').map(&:to_i)

      major > 0 || major == 0 && minor > 8
    end

    def self.rake_version
      if Object.const_defined?('RAKEVERSION')
        return RAKEVERSION
      elsif Rake.const_defined?('VERSION')
        return Rake::VERSION
      end
    end
  end
end

Rollbar::Rake.patch!
