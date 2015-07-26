require_relative '../spec_helper'

RSpec.describe API, 'listing collection records' do
  include Rack::Test::Methods

  before { create :tier, :free }

  let(:ultra_pod) { create :api, :podcast }

  context 'for another api' do
    let(:new_api) { create :api }

    before do
      set_auth_headers_for!(new_api, 'GET', {})
      get '/podcasts'
    end

    it do
      expect(last_response.status).to eql 404
      expect(last_json.errors).to eql ['Not Found']
    end
  end

  describe 'for the current api' do
    context 'with existing entries' do
      before do
        5.times do |index|
          params = {
            data: {
              name: "NerdCast-#{index}",
              episodes: 400,
              website: "something-#{index}"
            }
          }
          set_auth_headers_for!(ultra_pod, 'POST', params)
          post '/podcasts', params
        end
        set_auth_headers_for!(ultra_pod, 'GET', {})
        get '/podcasts'
      end

      it 'should contain all defined fields' do
        expect(last_response.status).to eql 200
        expect(last_json['count']).to eql 5

        last_json.items.each_with_index do |item, index|
          expect(last_json.items[index].keys)
            .to match_array %w(id name episodes website created_at updated_at)
          expect(last_json.items[index].name)
            .to eql "NerdCast-#{index}"
        end
      end
    end

    context 'without entries' do
      before do
        set_auth_headers_for!(ultra_pod, 'GET', {})
        get '/podcasts'
      end

      it do
        expect(last_response.status).to eql 200
        expect(last_json['count']).to eql 0
      end
    end
  end
end
