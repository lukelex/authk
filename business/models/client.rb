module RestInMe
  class Models::Client
    include ::Mongoid::Document
    include ::Mongoid::Timestamps
    include Extensions::Passwordable

    store_in collection: 'clients'

    field :email, type: ::String

    validates :email, presence: true

    has_many :apps

    def self.authenticate(params)
      client = find_by(email: params[:email])
      client.password_checks?(params[:password])
      client
    end

    def signed_in?
      true
    end
  end
end