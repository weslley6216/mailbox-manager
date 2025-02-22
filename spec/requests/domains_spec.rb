# frozen_string_literal: true

require 'rails_helper'

describe 'Domains', type: :request do
  context 'GET /domains' do
    it 'returns a success response when there are domains' do
      Domain.create!(name: 'example.com', password_expiration_frequency: 30)

      get '/domains'

      json_response = JSON.parse(response.body)

      expect(response).to be_successful
      expect(response.body).to include('example.com')
      expect(json_response.size).to eq(1)
    end

    it 'returns a success response when there are no domains' do
      get '/domains'

      json_response = JSON.parse(response.body)

      expect(response).to be_successful
      expect(json_response).to be_empty
    end
  end

  context 'POST /domains' do
    context 'with valid parameters' do
      let(:params) { { domain: { name: 'example.com', password_expiration_frequency: 30 } } }

      it 'creates a new domain' do
        expect {
          post '/domains', params:
        }.to change(Domain, :count).by(1)

        json_response = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(201)
        expect(json_response[:name]).to eq('example.com')
        expect(json_response[:password_expiration_frequency]).to eq(30)
      end
    end

    context 'with invalid parameters' do
      let(:params) { { domain: { name: nil } } }

      it 'does not create a new domain' do
        post('/domains', params:)

        expect(response).to have_http_status(422)
      end
    end
  end

  context 'GET /domains/:id' do
    context 'when the domain exists' do
      let(:domain) { Domain.create(name: 'example.com', password_expiration_frequency: 30) }

      it 'returns the domain' do
        get "/domains/#{domain.id}"

        expect(response).to be_successful
        expect(response.body).to include(domain.name)
        expect(response.body).to include(domain.password_expiration_frequency.to_s)
      end
    end

    context 'when the domain does not exist' do
      it 'returns a not found response' do
        get '/domains/9999'

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  context 'PUT /domains/:id' do
    let(:domain) { Domain.create(name: 'example.com', password_expiration_frequency: 30) }

    context 'with valid parameters' do
      it 'updates the domain' do
        put "/domains/#{domain.id}", params: { domain: { name: 'new-example.com', password_expiration_frequency: 60 } }

        expect(response).to have_http_status(200)
        expect(domain.reload.name).to eq('new-example.com')
        expect(domain.reload.password_expiration_frequency).to eq(60)
      end
    end

    context 'with invalid parameters' do
      it 'does not update the domain' do
        put "/domains/#{domain.id}", params: { domain: { name: nil } }

        expect(response).to have_http_status(422)
      end
    end
  end

  context 'DELETE /domains/:id' do
    let!(:domain) { Domain.create(name: 'example.com', password_expiration_frequency: 30) }

    it 'destroys the domain' do
      expect {
        delete "/domains/#{domain.id}"
      }.to change(Domain, :count).by(-1)

      expect(response).to have_http_status(204)
    end
  end
end
