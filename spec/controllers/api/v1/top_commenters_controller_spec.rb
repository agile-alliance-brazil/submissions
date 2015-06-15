# encoding: UTF-8
require 'spec_helper'

describe Api::V1::TopCommentersController, type: :controller do
  let(:session){FactoryGirl.create(:session)}
  describe 'index' do
    def simplify(user)
      gravatar_id = Digest::MD5::hexdigest(user.email).downcase
      picture = "https://gravatar.com/avatar/#{gravatar_id}.png?s=normal&d=mm"
      { user: user.username, name: user.full_name, picture: picture, comment_count: user.comments.count }
    end
    def create_commenter_with_number_of_comments_as(number, session = session)
      commenter = FactoryGirl.create(:user)
      number.times do
        FactoryGirl.create(:comment, user: commenter, commentable: session)
      end
      commenter
    end

    context 'without comments' do
      before do
        # curl "http://localhost:3000/api/top_commenters.json" -i -H "Accept: application/json"
        get :index, format: 'json'
      end

      it 'should respond with success' do
        expect(response.status).to eq(200)
      end

      it 'should return nobody' do
        expect(response.body).to eq('[]')
      end
    end

    context 'with less commenters than requested' do
      before do
        @winner = create_commenter_with_number_of_comments_as(3)
        @second = create_commenter_with_number_of_comments_as(2)
        @third = create_commenter_with_number_of_comments_as(1)

        get :index, format: 'json'
      end

      it 'should return top 3' do
        expected_result = [@winner, @second, @third].map{|u| simplify(u)}.to_json
        expect(response.body).to eq(expected_result)
      end
    end

    context 'with more commenters than requested' do
      before do
        commenters = (1..6).to_a.reverse.map do |number_of_comments|
          create_commenter_with_number_of_comments_as(number_of_comments)
        end
        @top_commenters = commenters.take(5)

        get :index, format: 'json'
      end

      it 'should return top 5' do
        expected_result = @top_commenters.map{|u| simplify(u)}.to_json
        expect(response.body).to eq(expected_result)
      end
    end

    context 'when commenters tie' do
      before do
        commenters = (1..6).to_a.reverse.map do |number_of_comments|
          create_commenter_with_number_of_comments_as([number_of_comments, 2].max)
        end
        @top_commenters = commenters.take(4) + [commenters.last]

        get :index, format: 'json'
      end

      it 'should return top 5 with most recent user to untie' do
        expected_result = @top_commenters.map{|u| simplify(u)}.to_json
        expect(response.body).to eq(expected_result)
      end
    end

    context 'regarding limit' do
      context 'with invalid limit should default to 5' do
        before do
          commenters = (1..6).to_a.reverse.map do |number_of_comments|
            create_commenter_with_number_of_comments_as(number_of_comments)
          end
          @top_commenters = commenters.take(5)
        end

        it 'should ignore negative limit' do
          get :index, format: 'json', limit: -1

          expected_result = @top_commenters.map{|u| simplify(u)}.to_json
          expect(response.body).to eq(expected_result)
        end

        it 'should ignore zero limit' do
          get :index, format: 'json', limit: 0

          expected_result = @top_commenters.map{|u| simplify(u)}.to_json
          expect(response.body).to eq(expected_result)
        end

        it 'should ignore nil limit' do
          get :index, format: 'json', limit: nil

          expected_result = @top_commenters.map{|u| simplify(u)}.to_json
          expect(response.body).to eq(expected_result)
        end
      end

      context 'with provided limit' do
        it 'should return that many commenters' do
          commenters = (1..10).to_a.reverse.map do |number_of_comments|
            create_commenter_with_number_of_comments_as(number_of_comments)
          end

          # curl "http://localhost:3000/api/top_commenters.json?limit=10" -i -H "Accept: application/json"
          get :index, format: 'json', limit: 10

          expected_result = commenters.map{|u| simplify(u)}.to_json
          expect(response.body).to eq(expected_result)
        end
      end

      context 'with above maximum limit' do
        it 'should cap limit to 20' do
          commenters = (1..30).to_a.reverse.map do |number_of_comments|
            create_commenter_with_number_of_comments_as(number_of_comments)
          end
          top_commenters = commenters.take(20)

          get :index, format: 'json', limit: 30

          expected_result = top_commenters.map{|u| simplify(u)}.to_json
          expect(response.body).to eq(expected_result)
        end
      end
    end

    context 'filtering' do
      context 'by year' do
        let(:new_conference){FactoryGirl.create(:conference)}

        before do
          create_commenter_with_number_of_comments_as(1)
        end

        it 'should ignore comments from other conferences' do
          get :index, format: 'json', filter: {year: [new_conference.year.to_s]}

          expect(response.body).to eq('[]')
        end

        it 'should show commenters from specified conference' do
          new_session = FactoryGirl.create(:session, conference: new_conference)
          top_commenters = [create_commenter_with_number_of_comments_as(5, new_session)]

          # curl "http://localhost:3000/api/top_commenters.json?filter%5Byear%5D=2015" -i -H "Accept: application/json"
          get :index, format: 'json', filter: {year: [new_conference.year.to_s]}

          expected_result = top_commenters.map{|u| simplify(u)}.to_json
          expect(response.body).to eq(expected_result)
        end

        it 'should show comments from specified conference' do
          new_session = FactoryGirl.create(:session, conference: new_conference)
          top_commenters = [create_commenter_with_number_of_comments_as(5, new_session)]
          top_commenter = top_commenters.first
          expected_result = top_commenters.map{|u| simplify(u)}.to_json #When only have 5 comments
          FactoryGirl.create(:comment, user: top_commenter, commentable: session)

          get :index, format: 'json', filter: {year: [new_conference.year.to_s]}

          expect(response.body).to eq(expected_result)
        end
      end
    end
  end
end
