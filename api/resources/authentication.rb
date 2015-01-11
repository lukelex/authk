module RestInMe
  class Resources::Authentication < ::Grape::API
    before { authenticate_app! }

    desc 'Authentication test endpoint' do
      failure [401, 'Unauthorized']
      headers [
        'PublicKey' => {
          description: 'Identifies the Application',
          required: true
        },
        'Hmac' => {
          description: 'A hashed composed by the private key and the query string',
          required: true
        }
      ]
    end
    get :authenticate do
      status 200
      { app: current_app.name }
    end
  end
end
