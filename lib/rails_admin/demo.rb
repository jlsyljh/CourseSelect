require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

module RailsAdmin
  module Config
    module Actions
      class Demo < RailsAdmin::Config::Actions::Base
        RailsAdmin::Config::Actions.register(self)
        register_instance_option :root do
          true
        end
        def xuanke
          if $XUANKE
            $XUANKE = false
          else
            $XUANKE = true
          end
        end
      end
    end
  end
end