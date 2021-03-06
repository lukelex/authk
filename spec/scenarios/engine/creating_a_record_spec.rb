require 'spec_helper'

RSpec.describe Engine do
  include Rack::Test::Methods

  context 'for the current api' do
    before do
      create :tier, :free
      params = {
        data: {
          name: 'Nerdcast',
          episodes: 352,
          website: 'jovemnerd.com.br'
        }
      }
      ultra_pod = create :api, :podcast
      set_auth_headers_for!(ultra_pod, 'POST', params)
      post '/engine/podcasts', params
    end

    it 'should create the record' do
      expect(last_response.status).to eql 201
      last_json.tap do |json|
        expect(json.id).to_not be_nil
        expect(json.created_at).to_not be_nil
        expect(json.updated_at).to_not be_nil
        expect(json.name).to eql 'Nerdcast'
        expect(json.episodes).to eql '352.0'
      end
    end

    context 'without the required data' do
      before do
        ultra_pod = create :api, :podcast
        set_auth_headers_for!(ultra_pod, 'POST', {})
        post '/engine/podcasts', {}
      end

      it 'should return validations errors' do
        expect(last_response.status).to eql 400
        expect(last_json.errors).to eql \
          'name' => ["can't be blank"],
          'episodes' => ["can't be blank"],
          'website' => ["can't be blank"]
      end
    end

    context 'with duplicate data' do
      before do
        params = {
          data: {
            name: 'Nerdcast',
            episodes: 352,
            website: 'jovemnerd.com.br'
          }
        }
        ultra_pod = create :api, :podcast

        2.times do
          set_auth_headers_for!(ultra_pod, 'POST', params)
          post '/engine/podcasts', params
        end
      end

      it "should not add the second record" do
        expect(last_response.status).to eql 400
        expect(last_json.errors).to eql \
          "name" => ["has already been taken"],
          "website" => ["has already been taken"]
      end
    end
  end

  context 'for another api' do
    before do
      create :tier, :free
      create :api, :podcast
      set_auth_headers_for!(create(:api), 'POST', {})
      post '/podcasts', {}
    end

    it 'should not be found' do
      expect(last_response.status).to eql 404
    end
  end
end
