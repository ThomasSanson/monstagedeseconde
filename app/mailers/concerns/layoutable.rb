module Layoutable
  extend ActiveSupport::Concern

  included do
    layout 'mailer'

    # email attachements for inline image
    before_action :set_logo_attachment
    def set_logo_attachment
      attachments.inline["logo.png"] = File.read("#{Rails.root}/public/assets/logo.png")
    end

    # for consistent email formatting accross email reader,
    # ensure <p> styles are always style with p style={p_styles}
    helper_method :p_styles
    def p_styles
      "font-family: -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica Neue, Arial, Noto Sans, sans-serif, Apple Color Emoji, Segoe UI Emoji, Segoe UI Symbol, Noto Color Emoji; font-size: 15px; font-weight: normal; margin: 0; Margin-bottom: 15px;"
    end
  end
end
