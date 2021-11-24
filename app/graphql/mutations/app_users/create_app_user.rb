# frozen_string_literal: true

module Mutations
  module AppUsers
    class CreateAppUser < Mutations::BaseMutation
      field :app_user, Types::AppUserType, null: false
      argument :app_key, String, required: true
      argument :options, Types::JsonType, required: true

      def resolve(app_key:, options:)
        app = current_user.apps.find_by(key: app_key)

        permitted_options = options.require(:app).permit(
          %w[name email first_name last_name company]
        )

        case options[:app][:contact_kind]
        when "AppUser"
          app_user = app.add_user(permitted_options)
        when "Lead"
          app_user = app.add_lead(permitted_options)
        end

        { app_user: app_user, errors: app_user.errors }
      end

      def current_user
        context[:current_user]
      end
    end
  end
end