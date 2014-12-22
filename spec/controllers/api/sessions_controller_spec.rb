# encoding: UTF-8
require 'spec_helper'

describe Api::V1::SessionsController, type: :controller do
  let(:session)  { FactoryGirl.create(:session, keyword_list: %w(fake tags tags.success)) }

  describe 'show' do
    context 'with pt locale' do
      before do
        get :show, id: session.id.to_s, format: :json, locale: 'pt'
      end

      it { should respond_with(:success) }

      it 'should return session JSON parseable representation' do
        gravatar_id = Digest::MD5::hexdigest(session.author.email).downcase
        expect(JSON.parse(response.body)).to eq({
          'id' => session.id,
          'title' => session.title,
          'authors' => [{ 'name' => session.author.full_name,
            'gravatar_url' => gravatar_url(gravatar_id)}],
          'prerequisites' => session.prerequisites,
          'tags' => ['fake', 'tags', 'Casos de Sucesso'],
          'session_type' => 'Palestra',
          'audience_level' => 'Iniciante',
          'track' => 'Engenharia',
          'audience_limit' => nil,
          'summary' => session.summary
        })
      end

      it 'should return session raw JSON with 2 authors' do
        session.second_author = FactoryGirl.create(:author, email: 'dtsato@dtsato.com')
        session.save

        get :show, id: session.id.to_s, format: :json, locale: 'pt'

        expect(unescape_utf8_chars(response.body)).to eq(%Q{
          {
            "id":#{session.id},
            "title":"#{session.title}",
            "authors":[
              {
                "name":"#{session.author.full_name}",
                "gravatar_url":"#{gravatar_url(Digest::MD5::hexdigest(session.author.email).downcase)}"
              },
              {
                "name":"#{session.second_author.full_name}",
                "gravatar_url":"#{gravatar_url('9681863a56f1e1ac9562c72b297f6c2d')}"
              }
            ],
            "prerequisites":"#{session.prerequisites}",
            "tags":["fake","tags","Casos de Sucesso"],
            "session_type":"Palestra",
            "audience_level":"Iniciante",
            "track":"Engenharia",
            "audience_limit":null,
            "summary":"#{session.summary}"}
        }.gsub(/\s*\n\s*/,''))
      end
    end

    context 'using en locale' do
      before do
        get :show, id: session.id.to_s, format: :json, locale: 'en'
      end
      it 'should respect locale on session type, audience level, track and tags if possible' do
        gravatar_id = Digest::MD5::hexdigest(session.author.email).downcase
        expect(JSON.parse(response.body)).to eq({
          'id' => session.id,
          'title' => session.title,
          'authors' => [{ 'name' => session.author.full_name,
            'gravatar_url' => gravatar_url(gravatar_id)}],
          'prerequisites' => session.prerequisites,
          'tags' => ['fake', 'tags', 'Success Cases'],
          'session_type' => 'Lecture',
          'audience_level' => 'Beginner',
          'track' => 'Engineering',
          'audience_limit' => nil,
          'summary' => session.summary
        })
      end
    end

    it 'should respond with 404 for unexisting session' do
      get :show, id: ((Session.last.try(:id) || 0) + 1), format: :json

      expect(response.code).to eq('404')
      expect(response.body).to eq('{"error":"not-found"}')
    end

    it 'should respond to js as JS object as well' do
      xhr :get, :show, format: :js, id: session.id.to_s,
        locale: 'pt'

      gravatar_id = Digest::MD5::hexdigest(session.author.email).downcase
      expect(JSON.parse(response.body)).to eq({
        'id' => session.id,
        'title' => session.title,
        'authors' => [{ 'name' => session.author.full_name,
          'gravatar_url' => gravatar_url(gravatar_id)}],
        'prerequisites' => session.prerequisites,
        'tags' => ['fake', 'tags', 'Casos de Sucesso'],
        'session_type' => 'Palestra',
        'audience_level' => 'Iniciante',
        'track' => 'Engenharia',
        'audience_limit' => nil,
        'summary' => session.summary
      })
    end

    it 'should respond to js with callback as JSONP if callback is provided' do
      xhr :get, :show, format: :js, id: session.id.to_s,
        locale: 'pt', callback: 'test'

      gravatar_id = Digest::MD5::hexdigest(session.author.email).downcase
      expect(response.body).to match(/test\((.*)\)$/)
      expect(JSON.parse(response.body.match(/test\((.*)\)$/)[1])).to eq({
        'id' => session.id,
        'title' => session.title,
        'authors' => [{ 'name' => session.author.full_name,
          'gravatar_url' => gravatar_url(gravatar_id)}],
        'prerequisites' => session.prerequisites,
        'tags' => ['fake', 'tags', 'Casos de Sucesso'],
        'session_type' => 'Palestra',
        'audience_level' => 'Iniciante',
        'track' => 'Engenharia',
        'audience_limit' => nil,
        'summary' => session.summary
      })
    end

    it 'should respond to js with audience limit' do
      session.audience_limit = 100
      session.save

      xhr :get, :show, format: :js, id: session.id.to_s,
        locale: 'pt', callback: 'test'

      gravatar_id = Digest::MD5::hexdigest(session.author.email).downcase
      expect(response.body).to match(/test\((.*)\)$/)
      expect(JSON.parse(response.body.match(/test\((.*)\)$/)[1])).to eq({
        'id' => session.id,
        'title' => session.title,
        'authors' => [{ 'name' => session.author.full_name,
          'gravatar_url' => gravatar_url(gravatar_id)}],
        'prerequisites' => session.prerequisites,
        'tags' => ['fake', 'tags', 'Casos de Sucesso'],
        'session_type' => 'Palestra',
        'audience_level' => 'Iniciante',
        'track' => 'Engenharia',
        'audience_limit' => 100,
        'summary' => session.summary
      })
    end
  end
  def gravatar_url(gravatar_id)
    "http://gravatar.com/avatar/#{gravatar_id}.png?s=48&d=mm"
  end
  def unescape_utf8_chars(text)
    text.gsub(/\\u([0-9a-z]{4})/) {|s| [$1.to_i(16)].pack("U")}
  end
end
