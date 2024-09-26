module ThirdPartyTestHelpers
  def bitly_stub
    stub_request(:post, "https://api-ssl.bitly.com/v4/shorten").
        with(
          body: "{\"long_url\":\"http://example.com/dashboard/248/internship_applications/1520\"}",
          headers: {
                'Accept'=>'application/json',
                'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                'Authorization'=>'Bearer ',
                'Content-Type'=>'application/json',
                'User-Agent'=>'Ruby Bitly/2.0.1'
          }).
        to_return(status: 200, body: "", headers: {})
  end

  def sms_stub
    stub_request(:get, "https://europe.ipx.com/restapi/v1/sms/send?destinationAddress=33606060606&messageText=Multipliez%20vos%20chances%20de%20trouver%20un%20stage%20!%20Envoyez%20au%20moins%203%20candidatures%20sur%20notre%20site%20:%20http://example.com/c/vwb94/o%20.%20L'%C3%A9quipe%20Mon%20stage%20de%20troisieme%20&originatingAddress=Mon%20stage&originatorTON=1&password=#{ENV.fetch("LINK_MOBILITY_SECRET")}&username=#{ENV.fetch("LINK_MOBILITY_SECRET")}").
      with(
        headers: {
              'Accept'=>'application/json',
              'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Host'=>'europe.ipx.com',
              'User-Agent'=>'Ruby'
        }).
      to_return(status: 200, body: "", headers: {})
  end

  def sms_bitly_stub
    stub_request(:get, "https://europe.ipx.com/restapi/v1/sms/send?campaignName=&destinationAddress=33611223944&messageText=Bienvenue%20sur%20Mon%20stage%20de%202de.%20Commencez%20votre%20recherche%20ici%20:%20https://bit.ly/4athP2e&originatingAddress=MonStage2de&originatorTON=1&password=Phig9NUK&username=dinumM-fr").
    with(
      headers: {
            'Accept'=>'application/json',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Host'=>'europe.ipx.com',
            'User-Agent'=>'Ruby'
      }).
    to_return(status: 200, body: "", headers: {})
  end

  def google_storage_stub
    stub_request(:get, "https://storage.googleapis.com/chrome-for-testing-public/121.0.6167.184/mac-arm64/chromedriver-mac-arm64.zip").
    with(
      headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Host'=>'storage.googleapis.com',
            'User-Agent'=>'Ruby'
      }).
    to_return(status: 200, body: "", headers: {})
  end

  def captcha_stub
    stub_request(:post, "https://oauth.piste.gouv.fr/api/oauth/token").
    with(
      body: {
        "client_id"=> ENV['CAPTCHA_CLIENT_ID'], 
        "client_secret"=>ENV['CAPTCHA_CLIENT_SECRET'], 
        "grant_type"=>"client_credentials", 
        "scope"=>"piste.captchetat"
      },
      headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Content-Type'=>'application/x-www-form-urlencoded',
            'Host'=>'oauth.piste.gouv.fr',
            'User-Agent'=>'Ruby'
      }).
    to_return(status: 200, body: "", headers: {})
  end
end