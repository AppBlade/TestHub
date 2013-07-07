class OauthController < ApplicationController

  # POST /oauth/:client
  def start
    redirect_to client.auth_code.authorize_url(redirect_uri: oauth_callback_url(client: 'github'), scope: 'repo')
  end

  # GET /oauth/:client
  def callback
    access_token = client.auth_code.get_token(params[:code], redirect_uri: oauth_callback_url(client: 'github'))
    stored_access_token = AccessToken.where(token_digest: Digest::SHA1.hexdigest(access_token.token)).first_or_create
    user = stored_access_token.user || nil
    github_profile_request = access_token.get 'https://api.github.com/user', headers: {'If-None-Match' =>  user.try(:github_etag).to_s}
    if github_profile_request.status == 200
      parsed_github_profile = MultiJson.load(github_profile_request.response.body)
      user ||= User.where(github_id: parsed_github_profile['id']).first_or_create
      user.update_attributes github_id:    parsed_github_profile['id'],
                             github_login: parsed_github_profile['login'],
                             name:         parsed_github_profile['name'],
                             email:        parsed_github_profile['email'],
                             avatar_url:   parsed_github_profile['avatar_url'],
                             github_etag:  github_profile_request.response['ETag']
    end
    stored_access_token.update_attributes token: DatabaseKey.public_encrypt(access_token.token),
                                          expires_at:    access_token.expires_at,
                                          refresh_token: access_token.refresh_token && DatabaseKey.public_encrypt(access_token.refresh_token),
                                          options:       access_token.options,
                                          user:          user
    redirect_to root_url
  end

private

  def client
    @client ||= OAuth2::Client.new ENV['GITHUB_TOKEN'], 
                                   ENV['GITHUB_SECRET'],
                                   site: 'https://github.com', 
                                   authorize_url: '/login/oauth/authorize',
                                   token_url: '/login/oauth/access_token'
  end

end
