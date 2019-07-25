module Mutations
  module Articles
    class ArticleSettingsUpdate < Mutations::BaseMutation
      
      field :settings, Types::ArticleSettingsType, null: false
      field :errors, Types::JsonType, null: true
      argument :app_key, String, required: true
      argument :settings, Types::JsonType, required: true

      def resolve(app_key:, settings:)
        app = App.find_by(key: app_key)
     
        # TODO: set specific permitted fields! 
        settings.permit! 

        settings.merge!(id: app.article_settings.id) if app.article_settings.present?
  
        # ugly, dry
        if(settings[:logo])
          app.article_settings.logo.attach(settings[:logo])
        elsif(settings[:header_image])
          app.article_settings.header_image.attach(settings[:header_image])
        end

        app.article_settings_attributes = settings

        app.save

        {
          settings: app.article_settings, 
          errors: app.errors
        }
      end

      def current_user
        context[:current_user]
      end
    end
  end
end