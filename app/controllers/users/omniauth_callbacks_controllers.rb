class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def twitter
    auth_hash = request.env['omniauth.auth']
    uid = auth_hash['uid']
    name = auth_hash['info']['name']
    auth = Authorization.find_by_provider_and_uuid('twitter',uid)
    if auth
      user = auth.user
    else
      unless current_user
        unless user = User.find_by_name  name
          user = User.create({name: name,
           password: Devise.friendly_token[0,8],
           email: "#{UUIDTools::UUID.random_create}@shareup.com"})
        end
      else
        user = current_user
      end
      unless auth = user.authorizations.find_by_provider('twitter')
        auth = user.authorizations.build(provider: 'twitter',uid: uid)
        user.authorizations << auth
      end
      auth.update_attributes({
        uid: uid,
        token: auth_hash['credentials']['token'],
        secret: auth_hash['credentials']['secret'],
        name: name,
        url: "http://twitter.com/#{name}"
        })
    end
    if user
      sign_in_and_redirect user, :event => :authentication
    else
      redirect_to :new_user_registration
    end
  end
end