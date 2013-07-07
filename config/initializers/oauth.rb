GithubClient = OAuth2::Client.new ENV['GITHUB_TOKEN'], 
                                  ENV['GITHUB_SECRET'],
                                  site: 'https://github.com', 
                                  authorize_url: '/login/oauth/authorize',
                                  token_url: '/login/oauth/access_token'
