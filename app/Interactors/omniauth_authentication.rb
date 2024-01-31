class OmniauthAuthentication
  include Interactor

  # 認証データに対応するSNS authが存在するか確認し、
  # なければnew、すでにUserがついていればあるものを返す。
  #
  # @param [Hash] authentication hash
  # @return [Context]
  #
  def call
    validate_provider!
    find_or_initialize_auth
    context.user = context.authentication.user || nil

    context
  end

  private

    def validate_provider!
      return if User::Authentication::PROVIDERS.map(&:to_s).include?(context.provider)

      context.fail!(message: "authenticate_user.failure")
    end

    def find_or_initialize_auth
      context.authentication =
        User::Authentication.find_or_initialize_by(
          provider: context.provider,
          uid: context.uid,
        ) do |authentication|
          convert_attrs_by(authentication)
        end
    end

    def convert_attrs_by(auth)
      case context.provider
      when "twitter2"
        auth.username = context.info.nickname
        auth.display_name = context.info.name
        auth.url = context.info.urls.Twitter
        auth.image_url = context.info.image
      else
        context.fail!(message: "authenticate_user.failure")
      end
    end
end
