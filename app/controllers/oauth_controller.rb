class OauthController < ApplicationController

  # POST /oauth/:client
  def start
    redirect_to client.auth_code.authorize_url(redirect_uri: oauth_callback_url(client: 'github'), scope: 'repo')
  end

  # GET /oauth/:client
  def callback
    access_token = client.auth_code.get_token(params[:code], redirect_uri: oauth_callback_url(client: 'github'))
    stored_access_token = AccessToken.where(token: DatabaseKey.public_encrypt(access_token.token)).first_or_create
    stored_access_token.update_attributes expires_at:    access_token.expires_at,
                                          refresh_token: access_token.refresh_token && DatabaseKey.public_encrypt(access_token.refresh_token),
                                          options:       access_token.options
    github_user_request = access_token.get 'https://api.github.com/user'
    Rails.logger.info MultiJson.load(github_user_request.response.body)
    render :nothing => true
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
