require 'spec_helper'

module Moodle::Api
  RSpec.describe TokenGenerator do
    let(:configuration) do
      configuration = Configuration.new
      configuration.configure do |c|
        c.host = 'http://my_moodle_instance.com'
        c.username = 'ryan.mes@email.co.za'
        c.password = 'mypassword'
        c.service = 'phoenix_integration'
      end
      configuration
    end

    it 'generates a token' do
      VCR.use_cassette('token_service/token_service') do
        token = TokenGenerator.new(configuration).call
        expect(token).to eq('072556801bf07076fff6bff2a463b7c5')
      end
    end

    it 'raises a moodle error when an invalid service is used' do
      configuration.service = 'invalidservice'

      VCR.use_cassette('token_service/invalid_service_token_service') do
        expect {
          TokenGenerator.new(configuration).call
        }.to raise_error(Moodle::Api::MoodleError, 'Web service is not available (it doesn\'t exist or might be disabled)')
      end
    end

    it 'raises a moodle error when an invalid user is used' do
      configuration.username = 'invalidusername'

      VCR.use_cassette('token_service/invalid_username_token_service') do
        expect {
          TokenGenerator.new(configuration).call
        }.to raise_error(Moodle::Api::MoodleError, 'The username was not found in the database')
      end
    end

    it 'raises a moodle error when an invalid password is used' do
      VCR.use_cassette('token_service/invalid_password_token_service') do
        configuration.password = 'invalidpassword'

        expect {
          TokenGenerator.new(configuration).call
        }.to raise_error(Moodle::Api::MoodleError, 'The username was not found in the database')
      end
    end

    it 'raises an argument error when username is not passed in' do
      configuration.username = nil

      expect {
        TokenGenerator.new(configuration).call
      }.to raise_error(ArgumentError, 'Username and password are required to generate a token')
    end

    it 'raises an argument error when password is not passed in' do
      configuration.password = nil

      expect {
        TokenGenerator.new(configuration).call
      }.to raise_error(ArgumentError, 'Username and password are required to generate a token')
    end
  end
end
